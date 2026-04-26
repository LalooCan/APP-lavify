import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/wash_models.dart';
import '../services/session_service.dart';
import 'order_repository.dart';

class FirestoreOrderRepositoryException implements Exception {
  const FirestoreOrderRepositoryException({
    required this.message,
    this.code,
    this.cause,
  });

  final String message;
  final String? code;
  final Object? cause;

  @override
  String toString() => message;
}

class FirestoreOrderRepository implements OrderRepository {
  FirestoreOrderRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    SessionService? sessionService,
    this.collectionPath = 'orders',
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance,
       _sessionService = sessionService ?? SessionService();

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final SessionService _sessionService;
  final String collectionPath;

  CollectionReference<Map<String, dynamic>> get _ordersCollection =>
      _firestore.collection(collectionPath);

  @override
  Stream<List<WashOrder>> watchOrders() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream<List<WashOrder>>.value(const <WashOrder>[]);
    }

    final role = _sessionService.currentSession.value?.role ?? AppRole.client;
    if (role == AppRole.worker) {
      return _watchWorkerOrders(user.uid);
    }

    return _watchClientOrders(user.uid);
  }

  Stream<List<WashOrder>> _watchClientOrders(String clientId) {
    try {
      return _ordersCollection
          .where('clientId', isEqualTo: clientId)
          .snapshots()
          .asyncMap((snapshot) async {
            try {
              final orders = snapshot.docs
                  .map((doc) => _fromFirestore(doc.id, doc.data()))
                  .toList(growable: false);
              return _sortByCreatedAt(orders);
            } catch (error) {
              throw FirestoreOrderRepositoryException(
                message: 'No se pudieron interpretar los pedidos de Firestore.',
                cause: error,
              );
            }
          });
    } on FirebaseException catch (error) {
      return Stream<List<WashOrder>>.error(
        FirestoreOrderRepositoryException(
          message: 'No se pudo observar la coleccion de pedidos.',
          code: error.code,
          cause: error,
        ),
      );
    } catch (error) {
      return Stream<List<WashOrder>>.error(
        FirestoreOrderRepositoryException(
          message: 'Ocurrio un error al iniciar la lectura de pedidos.',
          cause: error,
        ),
      );
    }
  }

  Stream<List<WashOrder>> _watchWorkerOrders(String workerId) {
    final controller = StreamController<List<WashOrder>>();
    StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? searchingSub;
    StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? assignedSub;
    var searchingOrders = const <WashOrder>[];
    var assignedOrders = const <WashOrder>[];

    void emit() {
      final merged = <String, WashOrder>{};
      for (final order in searchingOrders) {
        merged[order.id] = order;
      }
      for (final order in assignedOrders) {
        merged[order.id] = order;
      }
      controller.add(_sortByCreatedAt(merged.values.toList(growable: false)));
    }

    List<WashOrder> parse(QuerySnapshot<Map<String, dynamic>> snapshot) {
      try {
        return snapshot.docs
            .map((doc) => _fromFirestore(doc.id, doc.data()))
            .toList(growable: false);
      } catch (error) {
        throw FirestoreOrderRepositoryException(
          message: 'No se pudieron interpretar los pedidos de Firestore.',
          cause: error,
        );
      }
    }

    void handleError(Object error, StackTrace stack) {
      if (error is FirebaseException) {
        controller.addError(
          FirestoreOrderRepositoryException(
            message: 'No se pudo observar la coleccion de pedidos.',
            code: error.code,
            cause: error,
          ),
          stack,
        );
        return;
      }

      controller.addError(
        FirestoreOrderRepositoryException(
          message: 'Ocurrio un error al iniciar la lectura de pedidos.',
          cause: error,
        ),
        stack,
      );
    }

    controller.onListen = () {
      searchingSub = _ordersCollection
          .where('status', isEqualTo: OrderStatus.searching.apiValue)
          .snapshots()
          .listen((snapshot) {
            try {
              searchingOrders = parse(snapshot);
              emit();
            } catch (error, stack) {
              handleError(error, stack);
            }
          }, onError: handleError);

      assignedSub = _ordersCollection
          .where('workerId', isEqualTo: workerId)
          .snapshots()
          .listen((snapshot) {
            try {
              assignedOrders = parse(snapshot);
              emit();
            } catch (error, stack) {
              handleError(error, stack);
            }
          }, onError: handleError);
    };

    controller.onCancel = () async {
      await searchingSub?.cancel();
      await assignedSub?.cancel();
    };

    return controller.stream;
  }

  @override
  List<WashOrder> getOrders() => const <WashOrder>[];

  @override
  Future<WashOrder> createOrder(WashOrder order) async {
    try {
      await _ordersCollection.doc(order.id).set(_toFirestore(order));
      return order;
    } on FirebaseException catch (error) {
      throw FirestoreOrderRepositoryException(
        message: 'No se pudo guardar el pedido en Firestore.',
        code: error.code,
        cause: error,
      );
    } catch (error) {
      throw FirestoreOrderRepositoryException(
        message: 'Ocurrio un error inesperado al crear el pedido.',
        cause: error,
      );
    }
  }

  @override
  Future<WashOrder> updateOrder(WashOrder order) async {
    try {
      await _ordersCollection
          .doc(order.id)
          .set(_toFirestore(order), SetOptions(merge: true));
      return order;
    } on FirebaseException catch (error) {
      throw FirestoreOrderRepositoryException(
        message: 'No se pudo actualizar el pedido en Firestore.',
        code: error.code,
        cause: error,
      );
    } catch (error) {
      throw FirestoreOrderRepositoryException(
        message: 'Ocurrio un error inesperado al actualizar el pedido.',
        cause: error,
      );
    }
  }

  Map<String, dynamic> _toFirestore(WashOrder order) {
    return {
      'request': order.request.toMap(),
      'status': order.status.apiValue,
      'clientId': order.clientId.trim().isNotEmpty
          ? order.clientId
          : _auth.currentUser?.uid,
      'customerEmail': order.customerEmail,
      'assignedWasherName': order.assignedWasherName,
      'workerId': order.workerId,
      'assignedWorkerEmail': order.assignedWorkerEmail,
      'assignedVehicleLabel': order.assignedVehicleLabel,
      'createdAt': order.createdAt.toIso8601String(),
      'etaMinutes': order.etaMinutes,
    };
  }

  WashOrder _fromFirestore(String orderId, Map<String, dynamic> data) {
    final requestData = Map<String, dynamic>.from(
      (data['request'] as Map?) ?? const <String, dynamic>{},
    );

    return WashOrder(
      id: orderId,
      request: WashRequest.fromMap(requestData),
      status: OrderStatusX.fromValue(data['status'] as String? ?? 'searching'),
      clientId: data['clientId'] as String? ?? '',
      customerEmail: data['customerEmail'] as String? ?? '',
      assignedWasherName:
          data['assignedWasherName'] as String? ?? 'Por asignar',
      workerId: data['workerId'] as String?,
      assignedWorkerEmail: data['assignedWorkerEmail'] as String?,
      assignedVehicleLabel: data['assignedVehicleLabel'] as String? ?? '',
      createdAt: _parseDateTime(data['createdAt']),
      etaMinutes: (data['etaMinutes'] as num?)?.toInt() ?? 0,
    );
  }

  DateTime _parseDateTime(Object? value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is String && value.trim().isNotEmpty) {
      return DateTime.parse(value);
    }
    return DateTime.now().toUtc();
  }

  List<WashOrder> _sortByCreatedAt(List<WashOrder> orders) {
    final sorted = List<WashOrder>.of(orders);
    sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return List<WashOrder>.unmodifiable(sorted);
  }
}
