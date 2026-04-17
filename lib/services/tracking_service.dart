import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../app_config.dart';
import '../models/wash_models.dart';
import '../repositories/firestore_tracking_repository.dart';
import '../repositories/mock_tracking_repository.dart';
import '../repositories/tracking_repository.dart';

class TrackingService {
  TrackingService._internal() : _repository = _buildRepository();

  static final TrackingService _instance = TrackingService._internal();

  factory TrackingService() => _instance;

  final TrackingRepository _repository;
  final Map<String, ValueNotifier<OrderTrackingSnapshot?>> _trackers = {};
  final Map<String, Timer> _mockTimers = {};
  final Map<String, StreamSubscription<OrderTrackingSnapshot?>>
  _repositorySubscriptions = {};

  static TrackingRepository _buildRepository() {
    switch (AppConfig.trackingBackendMode) {
      case TrackingBackendMode.firestore:
        return FirestoreTrackingRepository();
      case TrackingBackendMode.mock:
        return MockTrackingRepository();
    }
  }

  ValueListenable<OrderTrackingSnapshot?> trackingForOrder(String orderId) {
    _ensureRepositorySubscription(orderId);
    return _trackers.putIfAbsent(
      orderId,
      () => ValueNotifier<OrderTrackingSnapshot?>(null),
    );
  }

  OrderTrackingSnapshot? snapshotForOrder(String orderId) {
    return _trackers[orderId]?.value;
  }

  void syncOrder(WashOrder order) {
    _ensureRepositorySubscription(order.id);
    final notifier = _trackers.putIfAbsent(
      order.id,
      () => ValueNotifier<OrderTrackingSnapshot?>(null),
    );
    final current = notifier.value;
    final customer = order.customerLocation;

    if (order.status == OrderStatus.searching) {
      _stopMockTimer(order.id);
      final snapshot = OrderTrackingSnapshot(
        orderId: order.id,
        customerLocation: customer,
        workerLocation: null,
        distanceKm: null,
        etaMinutes: order.etaMinutes,
        routePoints: const <ServiceLocation>[],
        updatedAt: DateTime.now(),
        source: TrackingSource.mock,
      );
      notifier.value = snapshot;
      if (!AppConfig.usesRemoteTrackingBackend) {
        unawaited(_repository.publishTracking(snapshot));
      }
      return;
    }

    if (AppConfig.usesRemoteTrackingBackend) {
      final fallbackSnapshot =
          current ??
          OrderTrackingSnapshot(
            orderId: order.id,
            customerLocation: customer,
            workerLocation: null,
            distanceKm: null,
            etaMinutes: order.etaMinutes,
            routePoints: const <ServiceLocation>[],
            updatedAt: DateTime.now(),
            source: TrackingSource.backend,
          );
      notifier.value = fallbackSnapshot.copyWith(
        customerLocation: customer,
        etaMinutes: order.etaMinutes,
        updatedAt: DateTime.now(),
      );
      _stopMockTimer(order.id);
      return;
    }

    final worker =
        current?.workerLocation ??
        WorkerLiveLocation(
          location: _initialWorkerLocation(order),
          updatedAt: DateTime.now(),
          source: TrackingSource.mock,
        );

    final snapshot = _buildSnapshot(
      order: order,
      customerLocation: customer,
      workerLocation: worker,
      source: worker.source,
    );
    notifier.value = snapshot;
    unawaited(_repository.publishTracking(snapshot));

    if (_shouldAnimateMockTracking(order) &&
        worker.source == TrackingSource.mock) {
      _startMockTimer(order);
    } else {
      _stopMockTimer(order.id);
    }
  }

  void updateWorkerLocation({
    required WashOrder order,
    required ServiceLocation location,
    TrackingSource source = TrackingSource.deviceGps,
    double? heading,
    double? speedKph,
    List<ServiceLocation>? routePoints,
  }) {
    _ensureRepositorySubscription(order.id);
    final notifier = _trackers.putIfAbsent(
      order.id,
      () => ValueNotifier<OrderTrackingSnapshot?>(null),
    );
    final worker = WorkerLiveLocation(
      location: location,
      updatedAt: DateTime.now(),
      source: source,
      heading: heading,
      speedKph: speedKph,
    );

    final snapshot = _buildSnapshot(
      order: order,
      customerLocation: order.customerLocation,
      workerLocation: worker,
      source: source,
      routePoints: routePoints,
    );
    notifier.value = snapshot;
    unawaited(_repository.publishTracking(snapshot));

    if (source != TrackingSource.mock) {
      _stopMockTimer(order.id);
    }
  }

  void setBackendRoute({
    required WashOrder order,
    required List<ServiceLocation> routePoints,
  }) {
    _ensureRepositorySubscription(order.id);
    final current = snapshotForOrder(order.id);
    final worker = current?.workerLocation;
    if (worker == null) {
      return;
    }

    final snapshot = _buildSnapshot(
      order: order,
      customerLocation: order.customerLocation,
      workerLocation: worker,
      source: TrackingSource.directionsApi,
      routePoints: routePoints,
    );
    final notifier = _trackers.putIfAbsent(
      order.id,
      () => ValueNotifier<OrderTrackingSnapshot?>(null),
    );
    notifier.value = snapshot;
    unawaited(_repository.publishTracking(snapshot));
  }

  Future<void> clearTracking(String orderId) async {
    _stopMockTimer(orderId);
    await _repository.clearTracking(orderId);
    final notifier = _trackers[orderId];
    if (notifier != null) {
      notifier.value = null;
    }
  }

  void _ensureRepositorySubscription(String orderId) {
    if (_repositorySubscriptions.containsKey(orderId)) {
      return;
    }

    _repositorySubscriptions[orderId] = _repository
        .watchTracking(orderId)
        .listen((snapshot) {
          final notifier = _trackers.putIfAbsent(
            orderId,
            () => ValueNotifier<OrderTrackingSnapshot?>(null),
          );
          notifier.value = snapshot;
        });
  }

  void _startMockTimer(WashOrder order) {
    _mockTimers.putIfAbsent(order.id, () {
      return Timer.periodic(const Duration(seconds: 4), (_) {
        final current = snapshotForOrder(order.id);
        if (current == null || !current.hasWorkerLocation) {
          return;
        }

        final nextLocation = _moveTowards(
          current.workerLocation!.location,
          current.customerLocation,
          _mockStepFactor(order.status),
        );

        updateWorkerLocation(
          order: order,
          location: nextLocation,
          source: TrackingSource.mock,
        );
      });
    });
  }

  void _stopMockTimer(String orderId) {
    _mockTimers.remove(orderId)?.cancel();
  }

  bool _shouldAnimateMockTracking(WashOrder order) {
    switch (order.status) {
      case OrderStatus.assigned:
      case OrderStatus.onTheWay:
        return true;
      case OrderStatus.searching:
      case OrderStatus.arrived:
      case OrderStatus.inProgress:
      case OrderStatus.completed:
        return false;
    }
  }

  double _mockStepFactor(OrderStatus status) {
    switch (status) {
      case OrderStatus.assigned:
        return 0.10;
      case OrderStatus.onTheWay:
        return 0.16;
      case OrderStatus.arrived:
      case OrderStatus.inProgress:
      case OrderStatus.completed:
        return 1.0;
      case OrderStatus.searching:
        return 0.0;
    }
  }

  ServiceLocation _initialWorkerLocation(WashOrder order) {
    final destination = order.customerLocation;
    final seed = order.id.codeUnits.fold<int>(0, (value, unit) => value + unit);
    final baseDistanceDegrees = 0.02 + ((seed % 7) * 0.0025);
    final angle = (seed % 360) * (math.pi / 180);
    final latOffset = math.sin(angle) * baseDistanceDegrees;
    final lngOffset =
        math.cos(angle) *
        baseDistanceDegrees /
        math.max(0.35, math.cos(destination.latitude * (math.pi / 180)).abs());

    return ServiceLocation(
      latitude: destination.latitude + latOffset,
      longitude: destination.longitude + lngOffset,
    );
  }

  ServiceLocation _moveTowards(
    ServiceLocation from,
    ServiceLocation target,
    double factor,
  ) {
    return ServiceLocation(
      latitude: from.latitude + ((target.latitude - from.latitude) * factor),
      longitude:
          from.longitude + ((target.longitude - from.longitude) * factor),
    );
  }

  OrderTrackingSnapshot _buildSnapshot({
    required WashOrder order,
    required ServiceLocation customerLocation,
    required WorkerLiveLocation workerLocation,
    required TrackingSource source,
    List<ServiceLocation>? routePoints,
  }) {
    final normalizedWorker = switch (order.status) {
      OrderStatus.arrived ||
      OrderStatus.inProgress ||
      OrderStatus.completed => workerLocation.copyWith(
        location: customerLocation,
        updatedAt: DateTime.now(),
      ),
      OrderStatus.searching ||
      OrderStatus.assigned ||
      OrderStatus.onTheWay => workerLocation,
    };

    return OrderTrackingSnapshot(
      orderId: order.id,
      customerLocation: customerLocation,
      workerLocation: normalizedWorker,
      distanceKm: _distanceBetweenKm(
        normalizedWorker.location,
        customerLocation,
      ),
      etaMinutes: order.etaMinutes,
      routePoints: routePoints ?? [normalizedWorker.location, customerLocation],
      updatedAt: DateTime.now(),
      source: source,
    );
  }

  double _distanceBetweenKm(ServiceLocation start, ServiceLocation end) {
    const earthRadiusKm = 6371.0;
    final lat1 = start.latitude * (math.pi / 180);
    final lat2 = end.latitude * (math.pi / 180);
    final dLat = (end.latitude - start.latitude) * (math.pi / 180);
    final dLng = (end.longitude - start.longitude) * (math.pi / 180);

    final a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1) *
            math.cos(lat2) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusKm * c;
  }
}
