import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/wash_models.dart';
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
    this.collectionPath = 'orders',
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  final String collectionPath;

  CollectionReference<Map<String, dynamic>> get _ordersCollection =>
      _firestore.collection(collectionPath);

  @override
  Stream<List<WashOrder>> watchOrders() {
    try {
      return _ordersCollection
          .orderBy('createdAt', descending: true)
          .snapshots()
          .asyncMap((snapshot) async {
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
  WashOrder updateOrder(WashOrder order) {
    try {
      unawaited(
        _ordersCollection
            .doc(order.id)
            .set(_toFirestore(order), SetOptions(merge: true)),
      );
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
      'customerEmail': order.customerEmail,
      'assignedWasherName': order.assignedWasherName,
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
      customerEmail: data['customerEmail'] as String? ?? '',
      assignedWasherName:
          data['assignedWasherName'] as String? ?? 'Por asignar',
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
}
