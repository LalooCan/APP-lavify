import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../models/wash_models.dart';
import 'notification_service.dart';

class AuthService {
  static const _webClientId =
      '66350788000-vrkk9hflkn0m4e6gha4d7q3bbslaaae8.apps.googleusercontent.com';

  // Almacena el rol elegido antes de que Firebase dispare el auth state change,
  // evitando que _AuthGate cree el perfil con el rol equivocado (race condition).
  static AppRole? _pendingRegistrationRole;

  static AppRole? consumePendingRegistrationRole() {
    final role = _pendingRegistrationRole;
    _pendingRegistrationRole = null;
    return role;
  }

  // Cache del perfil recién cargado. signInWithGoogle y createUserWithEmailAndPassword
  // lo escriben para que _AuthGate no tenga que hacer una segunda llamada a Firestore.
  static UserProfile? _recentlyLoadedProfile;

  static UserProfile? consumeRecentlyLoadedProfile() {
    final profile = _recentlyLoadedProfile;
    _recentlyLoadedProfile = null;
    return profile;
  }

  // Future del perfil iniciado en signInWithEmailAndPassword. _AuthGate lo
  // reutiliza para no hacer una segunda lectura Firestore en paralelo.
  static Future<UserProfile>? _inflightProfileFuture;

  static Future<UserProfile>? consumeInflightProfileFuture() {
    final f = _inflightProfileFuture;
    _inflightProfileFuture = null;
    return f;
  }

  AuthService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
  }) : _auth = auth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _googleSignIn =
           googleSignIn ?? GoogleSignIn(clientId: kIsWeb ? _webClientId : null);

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  CollectionReference<Map<String, dynamic>> get _profilesCollection =>
      _firestore.collection('profiles');

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<User?> signInWithGoogle({
    AppRole fallbackRole = AppRole.client,
  }) async {
    _pendingRegistrationRole = fallbackRole;
    try {
      UserCredential userCredential;

      if (kIsWeb) {
        final provider = GoogleAuthProvider();
        provider.addScope('email');
        provider.addScope('profile');
        try {
          userCredential = await _auth.signInWithPopup(provider);
        } catch (e) {
          _pendingRegistrationRole = null;
          debugPrint('Error Google Sign-In (web popup): $e');
          return null;
        }
      } else {
        final googleUser = await _googleSignIn.signIn();
        if (googleUser == null) {
          _pendingRegistrationRole = null;
          return null;
        }

        final googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        try {
          userCredential = await _auth.signInWithCredential(credential);
        } catch (e) {
          _pendingRegistrationRole = null;
          debugPrint('Error Google Sign-In (credential): $e');
          return null;
        }
      }

      final user = userCredential.user;
      if (user == null) {
        _pendingRegistrationRole = null;
        return null;
      }

      final profile = await loadOrCreateUserProfile(
        user: user,
        fallbackRole: fallbackRole,
      );
      _recentlyLoadedProfile = profile;
      // Fire-and-forget: el token FCM no es crítico para mostrar la app.
      unawaited(NotificationService().refreshCurrentToken());
      return user;
    } catch (e) {
      // loadOrCreateUserProfile falló — el auth state ya disparó,
      // _AuthGate puede consumir el pending role si aún no lo hizo.
      debugPrint('Error Google Sign-In: $e');
      return null;
    }
  }

  Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password, {
    AppRole fallbackRole = AppRole.client,
  }) async {
    // Guardar el rol seleccionado antes de que dispare el auth state change.
    // Evita que _AuthGate use AppRole.client por defecto en usuarios nuevos
    // o en casos donde Firestore aún no tiene el campo role.
    _pendingRegistrationRole = fallbackRole;
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    // Inicia la carga del perfil inmediatamente. El auth state change se
    // disparará en el próximo microtask, y _AuthGate reutilizará este future
    // en lugar de lanzar una segunda lectura Firestore en paralelo.
    final user = credential.user;
    if (user != null) {
      _inflightProfileFuture = loadOrCreateUserProfile(
        user: user,
        fallbackRole: fallbackRole,
      );
    }
    unawaited(NotificationService().refreshCurrentToken());
    return credential;
  }

  Future<UserCredential> createUserWithEmailAndPassword(
    String email,
    String password, {
    AppRole fallbackRole = AppRole.client,
    String? displayName,
  }) async {
    _pendingRegistrationRole = fallbackRole;
    final UserCredential credential;
    try {
      credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      // A partir de aquí el auth state ya disparó — no limpiar _pendingRegistrationRole.
    } catch (e) {
      // Firebase Auth falló: ningún usuario creado, ningún auth state disparado.
      _pendingRegistrationRole = null;
      rethrow;
    }
    final user = credential.user;
    if (user != null) {
      final normalizedDisplayName = displayName?.trim() ?? '';
      if (normalizedDisplayName.isNotEmpty) {
        await user.updateDisplayName(normalizedDisplayName);
      }
      _recentlyLoadedProfile = await _createUserProfile(
        user: user,
        fallbackRole: fallbackRole,
        displayName: normalizedDisplayName,
      );
      unawaited(NotificationService().refreshCurrentToken());
    }
    return credential;
  }

  Future<AppRole> resolveUserRole({
    User? user,
    AppRole fallbackRole = AppRole.client,
  }) async {
    final current = user ?? currentUser;
    if (current == null) {
      return fallbackRole;
    }

    final snapshot = await _profilesCollection.doc(current.uid).get();
    final data = snapshot.data();
    if (data == null) {
      return fallbackRole;
    }

    final rawRole = (data['role'] as String? ?? '').trim().toLowerCase();
    return rawRole == 'worker' ? AppRole.worker : AppRole.client;
  }

  Future<Map<String, dynamic>?> loadProfileData({User? user}) async {
    final current = user ?? currentUser;
    if (current == null) {
      return null;
    }

    final snapshot = await _profilesCollection.doc(current.uid).get();
    return snapshot.data();
  }

  Future<UserProfile> loadOrCreateUserProfile({
    User? user,
    AppRole fallbackRole = AppRole.client,
    String? displayName,
  }) async {
    final current = user ?? currentUser;
    if (current == null) {
      throw StateError('No hay usuario autenticado.');
    }

    final doc = _profilesCollection.doc(current.uid);

    // Lee la cache offline de Firestore primero (disponible desde el 2do login).
    // Retorna casi al instante y sincroniza el servidor en background.
    try {
      final cached = await doc.get(const GetOptions(source: Source.cache));
      if (cached.exists) {
        final data = cached.data()!;
        final updates = _profileUpdatesForExisting(
          existing: data,
          user: current,
          fallbackRole: fallbackRole,
          displayName: displayName,
        );
        unawaited(_syncProfileFromServer(
          doc: doc,
          user: current,
          fallbackRole: fallbackRole,
          displayName: displayName,
        ));
        return UserProfile.fromMap(
          updates.isEmpty ? data : {...data, ...updates},
        );
      }
    } catch (_) {
      // Sin cache local — cae al fetch de servidor abajo.
    }

    final snapshot = await doc.get();
    final data = snapshot.data();

    if (data == null) {
      return _createUserProfile(
        user: current,
        fallbackRole: fallbackRole,
        displayName: displayName,
      );
    }

    final updates = _profileUpdatesForExisting(
      existing: data,
      user: current,
      fallbackRole: fallbackRole,
      displayName: displayName,
    );
    if (updates.isEmpty) {
      return UserProfile.fromMap(data);
    }

    unawaited(doc.set({
      ...updates,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true)));

    return UserProfile.fromMap({...data, ...updates});
  }

  Future<void> _syncProfileFromServer({
    required DocumentReference<Map<String, dynamic>> doc,
    required User user,
    required AppRole fallbackRole,
    String? displayName,
  }) async {
    try {
      final snapshot = await doc.get(const GetOptions(source: Source.server));
      if (!snapshot.exists) return;
      final data = snapshot.data()!;
      final updates = _profileUpdatesForExisting(
        existing: data,
        user: user,
        fallbackRole: fallbackRole,
        displayName: displayName,
      );
      if (updates.isNotEmpty) {
        unawaited(doc.set({
          ...updates,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true)));
      }
    } catch (_) {}
  }

  Future<void> sendPasswordResetEmail(String email) {
    return _auth.sendPasswordResetEmail(email: email.trim());
  }

  Future<void> signOut() async {
    _inflightProfileFuture = null;
    unawaited(NotificationService().clearToken());
    if (!kIsWeb) {
      await _googleSignIn.signOut();
    }
    await _auth.signOut();
  }

  Future<UserProfile> _createUserProfile({
    required User user,
    required AppRole fallbackRole,
    String? displayName,
  }) async {
    final doc = _profilesCollection.doc(user.uid);
    final profileData = _newProfileData(
      user: user,
      fallbackRole: fallbackRole,
      displayName: displayName,
    );

    await doc.set({
      ...profileData,
      'updatedAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    return UserProfile.fromMap(profileData);
  }

  Map<String, dynamic> _newProfileData({
    required User user,
    required AppRole fallbackRole,
    String? displayName,
  }) {
    final resolvedName = _resolveProfileName(
      user: user,
      displayName: displayName,
    );

    return {
      'uid': user.uid,
      'name': resolvedName,
      'displayName': resolvedName,
      'email': user.email?.trim() ?? '',
      'photoUrl': user.photoURL,
      'role': fallbackRole.name,
      'verificationStatus': WorkerVerificationStatus.unverified.apiValue,
      'onboardingComplete': false,
      'isAdmin': false,
      'cityId': 'cdmx',
    };
  }

  Future<UserProfile> submitVerificationRequest(UserProfile profile) async {
    final doc = _profilesCollection.doc(profile.uid);
    await doc.set({
      'verificationStatus': WorkerVerificationStatus.pending.apiValue,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    return profile.copyWith(
      verificationStatus: WorkerVerificationStatus.pending,
    );
  }

  Future<UserProfile> completeOnboarding(UserProfile profile) async {
    final doc = _profilesCollection.doc(profile.uid);
    await doc.set({
      'onboardingComplete': true,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    return profile.copyWith(onboardingComplete: true);
  }

  Map<String, dynamic> _profileUpdatesForExisting({
    required Map<String, dynamic> existing,
    required User user,
    required AppRole fallbackRole,
    String? displayName,
  }) {
    final updates = <String, dynamic>{};
    final explicitDisplayName = displayName?.trim() ?? '';
    final existingName = _stringValue(existing, 'name');
    final existingDisplayName = _stringValue(existing, 'displayName');
    final email = user.email?.trim() ?? '';
    final photoUrl = user.photoURL?.trim() ?? '';

    if (_stringValue(existing, 'uid') != user.uid) {
      updates['uid'] = user.uid;
    }
    if (email.isNotEmpty && _stringValue(existing, 'email') != email) {
      updates['email'] = email;
    }
    if (_stringValue(existing, 'role').isEmpty) {
      updates['role'] = fallbackRole.name;
    }
    if (photoUrl.isNotEmpty && _stringValue(existing, 'photoUrl') != photoUrl) {
      updates['photoUrl'] = photoUrl;
    }

    if (explicitDisplayName.isNotEmpty) {
      if (existingName != explicitDisplayName) {
        updates['name'] = explicitDisplayName;
      }
      if (existingDisplayName != explicitDisplayName) {
        updates['displayName'] = explicitDisplayName;
      }
      return updates;
    }

    if (existingName.isEmpty && existingDisplayName.isEmpty) {
      final resolvedName = _resolveProfileName(user: user, existing: existing);
      updates['name'] = resolvedName;
      updates['displayName'] = resolvedName;
    } else if (existingName.isEmpty) {
      updates['name'] = existingDisplayName;
    } else if (existingDisplayName.isEmpty) {
      updates['displayName'] = existingName;
    }

    return updates;
  }

  String _resolveProfileName({
    required User user,
    Map<String, dynamic>? existing,
    String? displayName,
  }) {
    final explicitDisplayName = displayName?.trim() ?? '';
    if (explicitDisplayName.isNotEmpty) {
      return explicitDisplayName;
    }

    final authDisplayName = user.displayName?.trim() ?? '';
    if (authDisplayName.isNotEmpty) {
      return authDisplayName;
    }

    final storedDisplayName = _stringValue(existing, 'displayName');
    if (storedDisplayName.isNotEmpty) {
      return storedDisplayName;
    }

    final storedName = _stringValue(existing, 'name');
    if (storedName.isNotEmpty) {
      return storedName;
    }

    return 'Usuario Lavify';
  }

  String _stringValue(Map<String, dynamic>? data, String key) {
    final value = data?[key];
    return value is String ? value.trim() : '';
  }
}
