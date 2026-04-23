import 'service_location.dart';

enum TrackingSource { mock, deviceGps, backend, directionsApi }

class WorkerLiveLocation {
  const WorkerLiveLocation({
    required this.location,
    required this.updatedAt,
    required this.source,
    this.heading,
    this.speedKph,
  });

  final ServiceLocation location;
  final DateTime updatedAt;
  final TrackingSource source;
  final double? heading;
  final double? speedKph;

  WorkerLiveLocation copyWith({
    ServiceLocation? location,
    DateTime? updatedAt,
    TrackingSource? source,
    double? heading,
    double? speedKph,
  }) {
    return WorkerLiveLocation(
      location: location ?? this.location,
      updatedAt: updatedAt ?? this.updatedAt,
      source: source ?? this.source,
      heading: heading ?? this.heading,
      speedKph: speedKph ?? this.speedKph,
    );
  }
}

class OrderTrackingSnapshot {
  const OrderTrackingSnapshot({
    required this.orderId,
    required this.customerLocation,
    required this.updatedAt,
    required this.source,
    this.workerLocation,
    this.distanceKm,
    this.etaMinutes,
    this.routePoints = const <ServiceLocation>[],
  });

  final String orderId;
  final ServiceLocation customerLocation;
  final WorkerLiveLocation? workerLocation;
  final double? distanceKm;
  final int? etaMinutes;
  final List<ServiceLocation> routePoints;
  final DateTime updatedAt;
  final TrackingSource source;

  bool get hasWorkerLocation => workerLocation != null;

  OrderTrackingSnapshot copyWith({
    ServiceLocation? customerLocation,
    WorkerLiveLocation? workerLocation,
    bool clearWorkerLocation = false,
    double? distanceKm,
    int? etaMinutes,
    List<ServiceLocation>? routePoints,
    DateTime? updatedAt,
    TrackingSource? source,
  }) {
    return OrderTrackingSnapshot(
      orderId: orderId,
      customerLocation: customerLocation ?? this.customerLocation,
      workerLocation: clearWorkerLocation
          ? null
          : (workerLocation ?? this.workerLocation),
      distanceKm: distanceKm ?? this.distanceKm,
      etaMinutes: etaMinutes ?? this.etaMinutes,
      routePoints: routePoints ?? this.routePoints,
      updatedAt: updatedAt ?? this.updatedAt,
      source: source ?? this.source,
    );
  }
}
