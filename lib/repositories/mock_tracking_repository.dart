import 'dart:async';

import '../models/wash_models.dart';
import 'tracking_repository.dart';

class MockTrackingRepository implements TrackingRepository {
  final Map<String, StreamController<OrderTrackingSnapshot?>> _controllers = {};
  final Map<String, OrderTrackingSnapshot?> _cache = {};

  @override
  Stream<OrderTrackingSnapshot?> watchTracking(String orderId) {
    final controller = _controllers.putIfAbsent(
      orderId,
      () => StreamController<OrderTrackingSnapshot?>.broadcast(),
    );

    final cached = _cache[orderId];
    if (cached != null) {
      scheduleMicrotask(() {
        if (!controller.isClosed) {
          controller.add(cached);
        }
      });
    }

    return controller.stream;
  }

  @override
  Future<void> publishTracking(OrderTrackingSnapshot snapshot) async {
    _cache[snapshot.orderId] = snapshot;
    final controller = _controllers.putIfAbsent(
      snapshot.orderId,
      () => StreamController<OrderTrackingSnapshot?>.broadcast(),
    );
    if (!controller.isClosed) {
      controller.add(snapshot);
    }
  }

  @override
  Future<void> clearTracking(String orderId) async {
    _cache.remove(orderId);
    final controller = _controllers[orderId];
    if (controller != null && !controller.isClosed) {
      controller.add(null);
    }
  }
}
