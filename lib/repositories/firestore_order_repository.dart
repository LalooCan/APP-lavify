import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/wash_models.dart';
import 'order_repository.dart';

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
    return _ordersCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => _fromFirestore(doc.id, doc.data()))
              .toList(growable: false);
        });
  }

  @override
  List<WashOrder> getOrders() => const <WashOrder>[];

  @override
  Future<WashOrder> createOrder(WashOrder order) async {
    await _ordersCollection.doc(order.id).set(_toFirestore(order));
    return order;
  }

  @override
  WashOrder updateOrder(WashOrder order) {
    _ordersCollection
        .doc(order.id)
        .set(_toFirestore(order), SetOptions(merge: true));
    return order;
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
    return WashOrder(
      id: orderId,
      request: WashRequest.fromMap(
        Map<String, dynamic>.from(data['request'] as Map),
      ),
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
