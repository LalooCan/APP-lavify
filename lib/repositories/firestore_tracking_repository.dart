import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/wash_models.dart';
import 'tracking_repository.dart';

class FirestoreTrackingRepository implements TrackingRepository {
  FirestoreTrackingRepository({
    FirebaseFirestore? firestore,
    this.collectionPath = 'tracking',
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  final String collectionPath;

  CollectionReference<Map<String, dynamic>> get _trackingCollection =>
      _firestore.collection(collectionPath);

  @override
  Stream<OrderTrackingSnapshot?> watchTracking(String orderId) {
    return _trackingCollection.doc(orderId).snapshots().map((snapshot) {
      if (!snapshot.exists) {
        return null;
      }

      final data = snapshot.data();
      if (data == null) {
        return null;
      }

      return _snapshotFromMap(orderId, data);
    });
  }

  @override
  Future<void> publishTracking(OrderTrackingSnapshot snapshot) {
    return _trackingCollection.doc(snapshot.orderId).set(
          _snapshotToMap(snapshot),
          SetOptions(merge: true),
        );
  }

  @override
  Future<void> clearTracking(String orderId) {
    return _trackingCollection.doc(orderId).delete();
  }

  Map<String, dynamic> _snapshotToMap(OrderTrackingSnapshot snapshot) {
    return {
      'customerLocation': snapshot.customerLocation.toMap(),
      'workerLocation': snapshot.workerLocation == null
          ? null
          : {
              'location': snapshot.workerLocation!.location.toMap(),
              'updatedAt': snapshot.workerLocation!.updatedAt.toIso8601String(),
              'source': snapshot.workerLocation!.source.name,
              'heading': snapshot.workerLocation!.heading,
              'speedKph': snapshot.workerLocation!.speedKph,
            },
      'distanceKm': snapshot.distanceKm,
      'etaMinutes': snapshot.etaMinutes,
      'routePoints': snapshot.routePoints.map((point) => point.toMap()).toList(),
      'updatedAt': snapshot.updatedAt.toIso8601String(),
      'source': snapshot.source.name,
    };
  }

  OrderTrackingSnapshot _snapshotFromMap(
    String orderId,
    Map<String, dynamic> data,
  ) {
    final workerLocationMap = data['workerLocation'] as Map<String, dynamic>?;
    final routePointsData = (data['routePoints'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .toList(growable: false);

    return OrderTrackingSnapshot(
      orderId: orderId,
      customerLocation: ServiceLocation.fromMap(
        data['customerLocation'] as Map<String, dynamic>,
      ),
      workerLocation: workerLocationMap == null
          ? null
          : WorkerLiveLocation(
              location: ServiceLocation.fromMap(
                workerLocationMap['location'] as Map<String, dynamic>,
              ),
              updatedAt: DateTime.parse(
                workerLocationMap['updatedAt'] as String,
              ),
              source: _trackingSourceFromValue(
                workerLocationMap['source'] as String?,
              ),
              heading: (workerLocationMap['heading'] as num?)?.toDouble(),
              speedKph: (workerLocationMap['speedKph'] as num?)?.toDouble(),
            ),
      distanceKm: (data['distanceKm'] as num?)?.toDouble(),
      etaMinutes: data['etaMinutes'] as int?,
      routePoints: routePointsData
          .map(ServiceLocation.fromMap)
          .toList(growable: false),
      updatedAt: DateTime.parse(data['updatedAt'] as String),
      source: _trackingSourceFromValue(data['source'] as String?),
    );
  }

  TrackingSource _trackingSourceFromValue(String? value) {
    switch (value) {
      case 'deviceGps':
        return TrackingSource.deviceGps;
      case 'backend':
        return TrackingSource.backend;
      case 'directionsApi':
        return TrackingSource.directionsApi;
      case 'mock':
      default:
        return TrackingSource.mock;
    }
  }
}
