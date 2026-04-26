import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../app_config.dart';
import '../models/wash_models.dart';
import '../repositories/firestore_order_repository.dart';
import '../repositories/mock_order_repository.dart';
import '../repositories/order_repository.dart';
import 'cloud_functions_service.dart';
import 'session_service.dart';
import 'tracking_service.dart';

class OrderSubmissionException implements Exception {
  const OrderSubmissionException(this.message);

  final String message;

  @override
  String toString() => message;
}

class OrderService {
  OrderService._internal() : _repository = _buildRepository() {
    orders = ValueNotifier<List<WashOrder>>(_repository.getOrders());
    pendingSyncOrderIds = ValueNotifier<Set<String>>(const <String>{});
    syncErrors = ValueNotifier<Map<String, String>>(const <String, String>{});
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
  final CloudFunctionsService _cloudFunctions = CloudFunctionsService();
  late final ValueNotifier<List<WashOrder>> orders;
  late final ValueNotifier<Set<String>> pendingSyncOrderIds;
  late final ValueNotifier<Map<String, String>> syncErrors;

  static OrderRepository _buildRepository() {
    switch (AppConfig.ordersBackendMode) {
      case BackendMode.firestore:
        return FirestoreOrderRepository();
      case BackendMode.mock:
        return MockOrderRepository();
    }
  }

  List<WashOrder> get currentOrders => orders.value;

  bool isOrderSyncPending(String orderId) =>
      pendingSyncOrderIds.value.contains(orderId);

  String? syncErrorForOrder(String orderId) => syncErrors.value[orderId];

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
    final workerUid = FirebaseAuth.instance.currentUser?.uid;
    for (final order in orders.value) {
      if (order.status.isActiveForWorker &&
          order.isVisibleToWorker(workerId: workerUid, email: workerEmail)) {
        return order;
      }
    }
    return null;
  }

  bool get hasActiveWorkerOrder => activeWorkerOrder != null;

  bool hasScheduleConflictForWorker(WashOrder candidateOrder) {
    final workerEmail = _normalizedCurrentSessionEmail;
    final workerUid = FirebaseAuth.instance.currentUser?.uid;
    if (workerEmail == null && (workerUid == null || workerUid.isEmpty)) {
      return false;
    }

    for (final order in orders.value) {
      if (order.id == candidateOrder.id) {
        continue;
      }
      if (!order.isVisibleToWorker(workerId: workerUid, email: workerEmail) ||
          order.status == OrderStatus.searching) {
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
    final clientUid = FirebaseAuth.instance.currentUser?.uid;
    if (sessionEmail == null && (clientUid == null || clientUid.isEmpty)) {
      return const <WashOrder>[];
    }

    return orders.value
        .where(
          (order) =>
              order.isVisibleToClient(clientId: clientUid, email: sessionEmail),
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
    final workerUid = FirebaseAuth.instance.currentUser?.uid;
    if (workerEmail == null && (workerUid == null || workerUid.isEmpty)) {
      return const <WashOrder>[];
    }

    return orders.value
        .where(
          (order) =>
              order.isVisibleToWorker(workerId: workerUid, email: workerEmail),
        )
        .toList(growable: false);
  }

  Future<WashOrder> createOrderFromDraft(WashRequestDraft draft) async {
    final validationMessage = draft.validationMessage;
    if (validationMessage != null) {
      throw OrderSubmissionException(validationMessage);
    }

    if (!AppConfig.usesRemoteOrdersBackend) {
      await Future<void>.delayed(const Duration(milliseconds: 900));
    }
    final session = _sessionService.currentSession.value;
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (AppConfig.usesRemoteOrdersBackend && firebaseUser == null) {
      throw const OrderSubmissionException(
        'Inicia sesion nuevamente para confirmar tu pedido.',
      );
    }
    final request = _requestFromTrustedCatalog(draft);
    final customerEmail = session?.email.trim().isNotEmpty == true
        ? session!.email.trim()
        : firebaseUser?.email?.trim() ?? 'cliente@lavify.app';
    final order = WashOrder(
      id: 'order_${DateTime.now().millisecondsSinceEpoch}',
      request: request,
      status: OrderStatus.searching,
      clientId: firebaseUser?.uid ?? '',
      customerEmail: customerEmail,
      assignedWasherName: 'Por asignar',
      assignedWorkerEmail: null,
      assignedVehicleLabel: request.vehicleTypeName,
      createdAt: DateTime.now().toUtc(),
      etaMinutes: request.estimatedMinutes,
    );
    var createdOrder = order;
    if (AppConfig.usesRemoteOrdersBackend) {
      // Optimistic local insert mientras Cloud Function escribe en Firestore.
      _storeOptimisticOrder(order);
      _markOrderSyncPending(order.id);
      try {
        final result = await _cloudFunctions
            .createOrder(draft)
            .timeout(const Duration(seconds: 8));
        // Reemplazar el id optimista con el id real devuelto por la función.
        final realId = result['orderId'] as String? ?? order.id;
        if (realId != order.id) {
          _removeOptimisticOrder(order.id);
          _markOrderSynced(order.id);
          createdOrder = order.copyWith(id: realId);
          _storeOptimisticOrder(createdOrder);
          _markOrderSynced(realId);
        } else {
          _markOrderSynced(realId);
        }
      } on TimeoutException {
        await _createOrderDirectly(order);
        debugPrint('Cloud Function createOrder tardó; orden optimista activa.');
      } catch (error, stack) {
        debugPrint('Error Cloud Function createOrder: $error\n$stack');
        if (error is CloudFunctionsException &&
            _canFallbackToFirestore(error)) {
          await _createOrderDirectly(order);
        } else {
          _removeOptimisticOrder(order.id);
          _markOrderSyncError(order.id, _syncErrorMessage(error));
          rethrow;
        }
      }
    } else {
      await _repository.createOrder(order);
      orders.value = _repository.getOrders();
    }
    _trackingService.syncOrder(createdOrder);
    return createdOrder;
  }

  Future<void> _createOrderDirectly(WashOrder order) async {
    final saveFuture = _repository.createOrder(order);
    try {
      await saveFuture.timeout(const Duration(seconds: 8));
      _markOrderSynced(order.id);
    } on TimeoutException {
      debugPrint(
        'Firestore createOrder tardo; la orden queda pendiente de sync.',
      );
      unawaited(
        saveFuture
            .then<void>((_) => _markOrderSynced(order.id))
            .catchError((Object error, StackTrace stack) {
          debugPrint('Fallback Firestore createOrder error: $error\n$stack');
          _removeOptimisticOrder(order.id);
          _markOrderSyncError(order.id, _syncErrorMessage(error));
        }),
      );
    } catch (error, stack) {
      debugPrint('Fallback Firestore createOrder error: $error\n$stack');
      _removeOptimisticOrder(order.id);
      _markOrderSyncError(order.id, _syncErrorMessage(error));
      rethrow;
    }
  }

  bool _canFallbackToFirestore(CloudFunctionsException error) {
    switch (error.code) {
      case 'internal':
      case 'not-found':
      case 'unavailable':
      case 'deadline-exceeded':
      case 'unknown':
        return true;
      default:
        return false;
    }
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
    final workerUid = FirebaseAuth.instance.currentUser?.uid;
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
        (AppConfig.usesRemoteOrdersBackend &&
            (workerUid == null || workerUid.isEmpty)) ||
        hasAnotherActiveOrder ||
        hasScheduleConflict) {
      return null;
    }

    if (AppConfig.usesRemoteOrdersBackend) {
      // Cloud Function valida race conditions y escribe en Firestore atómicamente.
      try {
        await _cloudFunctions.assignWorker(orderId);
      } on CloudFunctionsException catch (e) {
        _markOrderSyncError(orderId, e.message);
        return null;
      }
      // Optimistic local update; Firestore stream entregará la versión real.
      return _saveOrder(
        order.copyWith(
          status: OrderStatus.assigned,
          assignedWasherName: session.visibleName,
          workerId: workerUid,
          assignedWorkerEmail: workerEmail,
          assignedVehicleLabel: 'Unidad activa',
          etaMinutes: 18,
        ),
      );
    }
    return _saveOrder(
      order.copyWith(
        status: OrderStatus.assigned,
        assignedWasherName: session.visibleName,
        workerId: workerUid,
        assignedWorkerEmail: workerEmail,
        assignedVehicleLabel: 'Unidad activa',
        etaMinutes: 18,
      ),
    );
  }

  Future<WashOrder?> advanceOrder(String orderId) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final order = _findById(orderId);
    final session = _sessionService.currentSession.value;
    final workerEmail = _normalizedCurrentSessionEmail;
    if (order == null) {
      return null;
    }
    if (session == null ||
        session.role != AppRole.worker ||
        workerEmail == null ||
        order.status == OrderStatus.searching ||
        (order.assignedWorkerEmail != workerEmail &&
            order.workerId != FirebaseAuth.instance.currentUser?.uid)) {
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

    if (AppConfig.usesRemoteOrdersBackend) {
      try {
        await _cloudFunctions.updateOrderStatus(
          orderId,
          nextStatus,
          etaMinutes: nextEta,
        );
      } on CloudFunctionsException catch (e) {
        _markOrderSyncError(orderId, e.message);
        return null;
      }
    }
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

  Future<void> retryOrderSync(String orderId) async {
    final order = _findById(orderId);
    if (order == null) {
      return;
    }

    await _saveOrder(order);
  }

  WashOrder? _findById(String orderId) {
    return getOrderById(orderId);
  }

  void _storeOptimisticOrder(WashOrder order) {
    orders.value = <WashOrder>[
      order,
      ...orders.value.where((item) => item.id != order.id),
    ];
  }

  Future<WashOrder> _saveOrder(WashOrder order) async {
    if (AppConfig.usesRemoteOrdersBackend) {
      _markOrderSyncPending(order.id);
    }

    try {
      final savedOrder = await _repository
          .updateOrder(order)
          .timeout(const Duration(seconds: 8));
      if (AppConfig.usesRemoteOrdersBackend) {
        _storeOptimisticOrder(savedOrder);
        _markOrderSynced(savedOrder.id);
      } else {
        orders.value = _repository.getOrders();
      }
      _trackingService.syncOrder(savedOrder);
      return savedOrder;
    } on TimeoutException {
      const message =
          'Firestore tardo demasiado en actualizar el pedido. Intenta de nuevo.';
      _markOrderSyncError(order.id, message);
      throw const OrderSubmissionException(message);
    } catch (error, stack) {
      debugPrint('Error al actualizar pedido remoto: $error\n$stack');
      _markOrderSyncError(order.id, _syncErrorMessage(error));
      rethrow;
    }
  }

  WashRequest _requestFromTrustedCatalog(WashRequestDraft draft) {
    final package = _packageById(draft.selectedPackage.id);
    final schedule = _scheduleById(draft.selectedSchedule.id);
    final vehicle = _vehicleById(draft.selectedVehicle.id);

    if (package == null) {
      throw const OrderSubmissionException(
        'El paquete seleccionado ya no esta disponible.',
      );
    }
    if (schedule == null) {
      throw const OrderSubmissionException(
        'El horario seleccionado ya no esta disponible.',
      );
    }
    if (vehicle == null) {
      throw const OrderSubmissionException(
        'El tipo de vehiculo seleccionado ya no esta disponible.',
      );
    }

    return draft
        .copyWith(
          selectedPackage: package,
          selectedSchedule: schedule,
          selectedVehicle: vehicle,
        )
        .toRequest();
  }

  WashPackage? _packageById(String id) {
    for (final package in washPackages) {
      if (package.id == id) {
        return package;
      }
    }
    return null;
  }

  ScheduleSlot? _scheduleById(String id) {
    for (final schedule in scheduleSlots) {
      if (schedule.id == id) {
        return schedule;
      }
    }
    return null;
  }

  VehicleType? _vehicleById(String id) {
    for (final vehicle in vehicleTypes) {
      if (vehicle.id == id) {
        return vehicle;
      }
    }
    return null;
  }

  void _removeOptimisticOrder(String orderId) {
    orders.value = orders.value
        .where((order) => order.id != orderId)
        .toList(growable: false);
  }

  void _markOrderSyncPending(String orderId) {
    final next = <String>{...pendingSyncOrderIds.value, orderId};
    pendingSyncOrderIds.value = Set<String>.unmodifiable(next);
    if (syncErrors.value.containsKey(orderId)) {
      final nextErrors = <String, String>{...syncErrors.value}..remove(orderId);
      syncErrors.value = Map<String, String>.unmodifiable(nextErrors);
    }
  }

  void _markOrderSynced(String orderId) {
    if (pendingSyncOrderIds.value.contains(orderId)) {
      final next = <String>{...pendingSyncOrderIds.value}..remove(orderId);
      pendingSyncOrderIds.value = Set<String>.unmodifiable(next);
    }
    if (syncErrors.value.containsKey(orderId)) {
      final nextErrors = <String, String>{...syncErrors.value}..remove(orderId);
      syncErrors.value = Map<String, String>.unmodifiable(nextErrors);
    }
  }

  void _markOrderSyncError(String orderId, String message) {
    if (pendingSyncOrderIds.value.contains(orderId)) {
      final next = <String>{...pendingSyncOrderIds.value}..remove(orderId);
      pendingSyncOrderIds.value = Set<String>.unmodifiable(next);
    }
    syncErrors.value = Map<String, String>.unmodifiable({
      ...syncErrors.value,
      orderId: message,
    });
  }

  String _syncErrorMessage(Object error) {
    if (error is FirestoreOrderRepositoryException) {
      if (error.code == 'permission-denied') {
        return 'Firestore rechazo la sincronizacion por permisos.';
      }
      return error.message;
    }
    if (error is CloudFunctionsException) {
      return error.message;
    }
    if (error is OrderSubmissionException) {
      return error.message;
    }
    return 'No se pudo sincronizar el pedido. Intenta de nuevo.';
  }

  OrderStatus? _nextStatus(OrderStatus currentStatus) {
    return currentStatus.nextForWorker;
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
