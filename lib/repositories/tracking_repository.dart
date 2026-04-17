import '../models/wash_models.dart';

abstract class TrackingRepository {
  Stream<OrderTrackingSnapshot?> watchTracking(String orderId);

  Future<void> publishTracking(OrderTrackingSnapshot snapshot);

  Future<void> clearTracking(String orderId);
}
