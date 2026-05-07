import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../models/wash_models.dart';
import 'profile_service.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('FCM background: ${message.messageId}');
}

class NotificationService {
  NotificationService._internal();

  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() => _instance;

  static const AndroidNotificationChannel _workerOrdersChannel =
      AndroidNotificationChannel(
        'lavify_worker_orders',
        'Pedidos de Lavify',
        description: 'Avisos de nuevos pedidos y cambios de estado.',
        importance: Importance.high,
      );

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }
    _initialized = true;

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    await _initializeLocalNotifications();

    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      debugPrint('NotificationService: permisos denegados.');
      return;
    }

    await _saveCurrentToken();
    _messaging.onTokenRefresh.listen(_saveToken);
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
  }

  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
    );

    await _localNotifications.initialize(initializationSettings);

    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidPlugin?.createNotificationChannel(_workerOrdersChannel);
    await androidPlugin?.requestNotificationsPermission();
  }

  Future<void> _saveCurrentToken() async {
    try {
      final token = await _messaging.getToken();
      if (token != null) {
        await _saveToken(token);
      }
    } catch (e) {
      debugPrint('NotificationService._saveCurrentToken error: $e');
    }
  }

  Future<void> refreshCurrentToken() => _saveCurrentToken();

  Future<void> _saveToken(String token) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || uid.isEmpty) return;

    try {
      final profileRef = FirebaseFirestore.instance
          .collection('profiles')
          .doc(uid);

      // Escribir el token inmediatamente (bloqueante: es el objetivo principal).
      await profileRef.set({'fcmToken': token}, SetOptions(merge: true));

      // Sincronizar el token al documento de workers en background:
      // no necesita bloquear el flujo de login.
      _syncWorkerToken(uid, token, profileRef);
    } catch (e) {
      debugPrint('NotificationService._saveToken error: $e');
    }
  }

  void _syncWorkerToken(
    String uid,
    String token,
    DocumentReference<Map<String, dynamic>> profileRef,
  ) {
    // Usa el perfil en memoria si ya está cargado para evitar una lectura
    // Firestore extra. Si el perfil aún no tiene uid (placeholder inicial),
    // cae al read remoto como fallback.
    final cachedProfile = ProfileService().profile.value;
    if (cachedProfile.uid == uid) {
      if (cachedProfile.role != AppRole.worker) return;
      FirebaseFirestore.instance
          .collection('workers')
          .doc(uid)
          .set({'fcmToken': token}, SetOptions(merge: true))
          .catchError((Object e) {
            debugPrint('NotificationService._syncWorkerToken write error: $e');
          });
      return;
    }

    // Fallback: perfil no cargado todavía (ej. primera instalación).
    profileRef.get().then((doc) {
      final role = (doc.data()?['role'] as String? ?? '').toLowerCase();
      if (role != 'worker') return;
      FirebaseFirestore.instance
          .collection('workers')
          .doc(uid)
          .set({'fcmToken': token}, SetOptions(merge: true))
          .catchError((Object e) {
            debugPrint('NotificationService._syncWorkerToken write error: $e');
          });
    }).catchError((Object e) {
      debugPrint('NotificationService._syncWorkerToken read error: $e');
      return null;
    });
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    debugPrint(
      'FCM foreground: ${message.notification?.title} - ${message.notification?.body}',
    );

    final title = _messageText(
      message.notification?.title ?? message.data['title'],
    );
    final body = _messageText(
      message.notification?.body ?? message.data['body'],
    );
    if ((title == null || title.trim().isEmpty) &&
        (body == null || body.trim().isEmpty)) {
      return;
    }

    await _localNotifications.show(
      message.messageId.hashCode,
      title?.isNotEmpty == true ? title : 'Lavify',
      body?.isNotEmpty == true ? body : 'Tienes una actualizacion nueva.',
      NotificationDetails(
        android: AndroidNotificationDetails(
          _workerOrdersChannel.id,
          _workerOrdersChannel.name,
          channelDescription: _workerOrdersChannel.description,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
        macOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: _messageText(message.data['orderId'] ?? message.data['route']),
    );
  }

  String? _messageText(Object? value) {
    if (value == null) {
      return null;
    }
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  Future<void> clearToken() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      await Future.wait([
        FirebaseFirestore.instance.collection('profiles').doc(uid).set({
          'fcmToken': FieldValue.delete(),
        }, SetOptions(merge: true)),
        FirebaseFirestore.instance.collection('workers').doc(uid).set({
          'fcmToken': FieldValue.delete(),
        }, SetOptions(merge: true)),
      ]);
      await _messaging.deleteToken();
    } catch (e) {
      debugPrint('NotificationService.clearToken error: $e');
    }
  }
}
