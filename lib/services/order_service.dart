import 'package:flutter/foundation.dart';

import '../models/session_models.dart';
import '../models/wash_models.dart';
import '../repositories/mock_order_fixtures.dart';
import '../repositories/mock_order_repository.dart';
import '../repositories/order_repository.dart';
import 'session_service.dart';

class OrderService {
  OrderService._internal() : _repository = MockOrderRepository() {
    orders = ValueNotifier<List<WashOrder>>(MockOrderFixtures.initialOrders());
    for (final order in orders.value) {
      _repository.updateOrder(order);
    }
  }

  static final OrderService _instance = OrderService._internal();

  factory OrderService() => _instance;

  final OrderRepository _repository;
  final SessionService _sessionService = SessionService();
  late final ValueNotifier<List<WashOrder>> orders;

  List<WashOrder> get currentOrders => orders.value;

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
        .where((order) => order.customerEmail.trim().toLowerCase() == sessionEmail)
        .toList(growable: false);
  }

  List<WashOrder> get workerVisibleOrders {
    final workerEmail = _normalizedCurrentSessionEmail;
    if (workerEmail == null) {
      return const <WashOrder>[];
    }

    return orders.value.where((order) {
      if (order.status == OrderStatus.searching) {
        return true;
      }
      return order.assignedWorkerEmail == workerEmail;
    }).toList(growable: false);
  }

  Future<WashOrder> createOrderFromDraft(WashRequestDraft draft) async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
    final order = _repository.createOrderFromDraft(draft);
    orders.value = _repository.getOrders();
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

    return _saveOrder(
      order.copyWith(
        status: nextStatus,
        etaMinutes: nextEta,
      ),
    );
  }

  WashOrder? _findById(String orderId) {
    for (final order in orders.value) {
      if (order.id == orderId) {
        return order;
      }
    }
    return null;
  }

  WashOrder _saveOrder(WashOrder order) {
    _repository.updateOrder(order);
    orders.value = _repository.getOrders();
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
    final email = _sessionService.currentSession.value?.email.trim().toLowerCase();
    if (email == null || email.isEmpty) {
      return null;
    }
    return email;
  }
}
