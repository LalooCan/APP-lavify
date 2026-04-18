import 'package:flutter/foundation.dart';

import '../app_config.dart';
import '../models/session_models.dart';
import '../models/wash_models.dart';
import '../repositories/firestore_order_repository.dart';
import '../repositories/mock_order_repository.dart';
import '../repositories/order_repository.dart';
import 'session_service.dart';
import 'tracking_service.dart';

class OrderService {
  OrderService._internal() : _repository = _buildRepository() {
    orders = ValueNotifier<List<WashOrder>>(_repository.getOrders());
    _repository.watchOrders().listen(
      (nextOrders) {
        orders.value = nextOrders;
        for (final order in nextOrders) {
          _trackingService.syncOrder(order);
        }
      },
      onError: (error) {
        debugPrint('Error al observar pedidos: $error');
      },
    );
  }

  static final OrderService _instance = OrderService._internal();

  factory OrderService() => _instance;

  final OrderRepository _repository;
  final SessionService _sessionService = SessionService();
  final TrackingService _trackingService = TrackingService();
  late final ValueNotifier<List<WashOrder>> orders;

  static OrderRepository _buildRepository() {
    switch (AppConfig.ordersBackendMode) {
      case BackendMode.firestore:
        return FirestoreOrderRepository();
      case BackendMode.mock:
        return MockOrderRepository();
    }
  }

  List<WashOrder> get currentOrders => orders.value;

  ValueListenable<OrderTrackingSnapshot?> trackingForOrder(String orderId) {
    return _trackingService.trackingForOrder(orderId);
  }

  OrderTrackingSnapshot? trackingSnapshotForOrder(String orderId) {
    return _trackingService.snapshotForOrder(orderId);
  }

  WashOrder? getOrderById(String orderId) {
    for (final order in orders.value) {
      if (order.id == orderId) {
        return order;
      }
    }
    return null;
  }

  WashOrder? get activeWorkerOrder {
    final workerEmail = _normalizedCurrentSessionEmail;
    for (final order in orders.value) {
      if (order.status.isActiveForWorker &&
          workerEmail != null &&
          order.assignedWorkerEmail == workerEmail) {
        return order;
      }
    }
    return null;
  }

  bool get hasActiveWorkerOrder => activeWorkerOrder != null;

  bool hasScheduleConflictForWorker(WashOrder candidateOrder) {
    final workerEmail = _normalizedCurrentSessionEmail;
    if (workerEmail == null) {
      return false;
    }

    for (final order in orders.value) {
      if (order.id == candidateOrder.id) {
        continue;
      }
      if (order.assignedWorkerEmail != workerEmail) {
        continue;
      }
      if (order.status == OrderStatus.completed) {
        continue;
      }
      if (order.request.scheduleId == candidateOrder.request.scheduleId) {
        return true;
      }
    }

    return false;
  }

  List<WashOrder> get clientVisibleOrders {
    final sessionEmail = _normalizedCurrentSessionEmail;
    if (sessionEmail == null) {
      return const <WashOrder>[];
    }

    return orders.value
        .where(
          (order) => order.customerEmail.trim().toLowerCase() == sessionEmail,
        )
        .toList(growable: false);
  }

  WashOrder? get activeClientOrder {
    final visibleOrders = clientVisibleOrders;
    for (final order in visibleOrders) {
      if (order.status != OrderStatus.completed) {
        return order;
      }
    }
    return visibleOrders.isNotEmpty ? visibleOrders.first : null;
  }

  List<WashOrder> get workerVisibleOrders {
    final workerEmail = _normalizedCurrentSessionEmail;
    if (workerEmail == null) {
      return const <WashOrder>[];
    }

    return orders.value
        .where((order) {
          if (order.status == OrderStatus.searching) {
            return true;
          }
          return order.assignedWorkerEmail == workerEmail;
        })
        .toList(growable: false);
  }

  Future<WashOrder> createOrderFromDraft(WashRequestDraft draft) async {
    if (!AppConfig.usesRemoteOrdersBackend) {
      await Future<void>.delayed(const Duration(milliseconds: 900));
    }
    final session = _sessionService.currentSession.value;
    final request = draft.toRequest();
    final order = WashOrder(
      id: 'order_${DateTime.now().millisecondsSinceEpoch}',
      request: request,
      status: OrderStatus.searching,
      customerEmail: session?.email ?? 'cliente@lavify.app',
      assignedWasherName: 'Por asignar',
      assignedWorkerEmail: null,
      assignedVehicleLabel: request.vehicleTypeName,
      createdAt: DateTime.now().toUtc(),
      etaMinutes: request.estimatedMinutes,
    );
    await _repository.createOrder(order);
    if (!AppConfig.usesRemoteOrdersBackend) {
      orders.value = _repository.getOrders();
    }
    _trackingService.syncOrder(order);
    return order;
  }

  Future<WashOrder> createOrder(WashRequest request) async {
    final draft = WashRequestDraft(
      selectedPackage: washPackages.firstWhere(
        (item) => item.id == request.packageId,
        orElse: () => washPackages.first,
      ),
      address: request.address,
      selectedSchedule: scheduleSlots.firstWhere(
        (item) => item.id == request.scheduleId,
        orElse: () => scheduleSlots.first,
      ),
      selectedVehicle: vehicleTypes.firstWhere(
        (item) => item.id == request.vehicleTypeId,
        orElse: () => vehicleTypes.first,
      ),
      estimatedMinutes: request.estimatedMinutes,
      travelFee: request.travelFee,
      notes: request.notes,
      selectedLocation: ServiceLocation(
        latitude: request.latitude,
        longitude: request.longitude,
      ),
      isLocationConfirmed: true,
    );

    return createOrderFromDraft(draft);
  }

  Future<WashOrder?> takeOrder(String orderId) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final order = _findById(orderId);
    final session = _sessionService.currentSession.value;
    final workerEmail = _normalizedCurrentSessionEmail;
    final activeOrder = activeWorkerOrder;
    final hasAnotherActiveOrder =
        activeOrder != null && activeOrder.id != orderId;
    final hasScheduleConflict =
        order != null && hasScheduleConflictForWorker(order);

    if (order == null ||
        order.status != OrderStatus.searching ||
        session == null ||
        session.role != AppRole.worker ||
        workerEmail == null ||
        hasAnotherActiveOrder ||
        hasScheduleConflict) {
      return null;
    }

    return _saveOrder(
      order.copyWith(
        status: OrderStatus.assigned,
        assignedWasherName: session.visibleName,
        assignedWorkerEmail: workerEmail,
        assignedVehicleLabel: 'Unidad activa',
        etaMinutes: 18,
      ),
    );
  }

  Future<WashOrder?> advanceOrder(String orderId) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final order = _findById(orderId);
    if (order == null) {
      return null;
    }

    if (order.status == OrderStatus.onTheWay) {
      if (order.etaMinutes > 4) {
        return _saveOrder(order.copyWith(etaMinutes: order.etaMinutes - 4));
      }
      if (order.etaMinutes > 0) {
        return _saveOrder(order.copyWith(etaMinutes: 0));
      }
    }

    final nextStatus = _nextStatus(order.status);
    if (nextStatus == null) {
      return order;
    }

    final nextEta = switch (nextStatus) {
      OrderStatus.assigned => 18,
      OrderStatus.onTheWay => 12,
      OrderStatus.arrived => 0,
      OrderStatus.inProgress => 30,
      OrderStatus.completed => 0,
      OrderStatus.searching => order.etaMinutes,
    };

    return _saveOrder(order.copyWith(status: nextStatus, etaMinutes: nextEta));
  }

  void updateWorkerLiveLocation(
    String orderId,
    ServiceLocation location, {
    TrackingSource source = TrackingSource.deviceGps,
    double? heading,
    double? speedKph,
    List<ServiceLocation>? routePoints,
  }) {
    final order = _findById(orderId);
    if (order == null) {
      return;
    }

    _trackingService.updateWorkerLocation(
      order: order,
      location: location,
      source: source,
      heading: heading,
      speedKph: speedKph,
      routePoints: routePoints,
    );
  }

  void setTrackingRoute(String orderId, List<ServiceLocation> routePoints) {
    final order = _findById(orderId);
    if (order == null) {
      return;
    }

    _trackingService.setBackendRoute(order: order, routePoints: routePoints);
  }

  WashOrder? _findById(String orderId) {
    return getOrderById(orderId);
  }

  WashOrder _saveOrder(WashOrder order) {
    _repository.updateOrder(order);
    if (!AppConfig.usesRemoteOrdersBackend) {
      orders.value = _repository.getOrders();
    }
    _trackingService.syncOrder(order);
    return order;
  }

  OrderStatus? _nextStatus(OrderStatus currentStatus) {
    switch (currentStatus) {
      case OrderStatus.searching:
        return OrderStatus.assigned;
      case OrderStatus.assigned:
        return OrderStatus.onTheWay;
      case OrderStatus.onTheWay:
        return OrderStatus.arrived;
      case OrderStatus.arrived:
        return OrderStatus.inProgress;
      case OrderStatus.inProgress:
        return OrderStatus.completed;
      case OrderStatus.completed:
        return null;
    }
  }

  String? get _normalizedCurrentSessionEmail {
    final email = _sessionService.currentSession.value?.email
        .trim()
        .toLowerCase();
    if (email == null || email.isEmpty) {
      return null;
    }
    return email;
  }
}
