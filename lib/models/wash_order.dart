import 'service_location.dart';
import 'wash_request.dart';

enum OrderStatus {
  searching,
  assigned,
  onTheWay,
  arrived,
  inProgress,
  completed,
}

extension OrderStatusX on OrderStatus {
  String get apiValue {
    switch (this) {
      case OrderStatus.searching:
        return 'searching';
      case OrderStatus.assigned:
        return 'assigned';
      case OrderStatus.onTheWay:
        return 'on_the_way';
      case OrderStatus.arrived:
        return 'arrived';
      case OrderStatus.inProgress:
        return 'in_progress';
      case OrderStatus.completed:
        return 'completed';
    }
  }

  String get label {
    switch (this) {
      case OrderStatus.searching:
        return 'Buscando lavador';
      case OrderStatus.assigned:
        return 'Lavador asignado';
      case OrderStatus.onTheWay:
        return 'En camino';
      case OrderStatus.arrived:
        return 'Ha llegado';
      case OrderStatus.inProgress:
        return 'Lavado en progreso';
      case OrderStatus.completed:
        return 'Completado';
    }
  }

  static OrderStatus fromValue(String value) {
    switch (value) {
      case 'assigned':
        return OrderStatus.assigned;
      case 'on_the_way':
        return OrderStatus.onTheWay;
      case 'arrived':
        return OrderStatus.arrived;
      case 'in_progress':
        return OrderStatus.inProgress;
      case 'completed':
        return OrderStatus.completed;
      case 'searching':
      default:
        return OrderStatus.searching;
    }
  }

  bool get isActiveForWorker {
    switch (this) {
      case OrderStatus.assigned:
      case OrderStatus.onTheWay:
      case OrderStatus.arrived:
      case OrderStatus.inProgress:
        return true;
      case OrderStatus.searching:
      case OrderStatus.completed:
        return false;
    }
  }
}

class WashOrder {
  const WashOrder({
    required this.id,
    required this.request,
    required this.status,
    this.clientId = '',
    required this.customerEmail,
    required this.assignedWasherName,
    this.workerId,
    this.assignedWorkerEmail,
    required this.assignedVehicleLabel,
    required this.createdAt,
    required this.etaMinutes,
  });

  final String id;
  final WashRequest request;
  final OrderStatus status;
  final String clientId;
  final String customerEmail;
  final String assignedWasherName;
  final String? workerId;
  final String? assignedWorkerEmail;
  final String assignedVehicleLabel;
  final DateTime createdAt;
  final int etaMinutes;

  factory WashOrder.fromMap(Map<String, dynamic> map) {
    return WashOrder(
      id: map['id'] as String,
      request: WashRequest.fromMap(map['request'] as Map<String, dynamic>),
      status: OrderStatusX.fromValue(map['status'] as String),
      clientId: map['clientId'] as String? ?? '',
      customerEmail: map['customerEmail'] as String,
      assignedWasherName: map['assignedWasherName'] as String,
      workerId: map['workerId'] as String?,
      assignedWorkerEmail: map['assignedWorkerEmail'] as String?,
      assignedVehicleLabel: map['assignedVehicleLabel'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      etaMinutes: map['etaMinutes'] as int,
    );
  }

  WashOrder copyWith({
    OrderStatus? status,
    String? clientId,
    String? customerEmail,
    String? assignedWasherName,
    String? workerId,
    String? assignedWorkerEmail,
    String? assignedVehicleLabel,
    int? etaMinutes,
  }) {
    return WashOrder(
      id: id,
      request: request,
      status: status ?? this.status,
      clientId: clientId ?? this.clientId,
      customerEmail: customerEmail ?? this.customerEmail,
      assignedWasherName: assignedWasherName ?? this.assignedWasherName,
      workerId: workerId ?? this.workerId,
      assignedWorkerEmail: assignedWorkerEmail ?? this.assignedWorkerEmail,
      assignedVehicleLabel: assignedVehicleLabel ?? this.assignedVehicleLabel,
      createdAt: createdAt,
      etaMinutes: etaMinutes ?? this.etaMinutes,
    );
  }

  RequestLifecycleStatus get requestLifecycleStatus {
    switch (status) {
      case OrderStatus.searching:
        return RequestLifecycleStatus.confirmed;
      case OrderStatus.assigned:
      case OrderStatus.onTheWay:
      case OrderStatus.arrived:
        return RequestLifecycleStatus.assigned;
      case OrderStatus.inProgress:
        return RequestLifecycleStatus.inProgress;
      case OrderStatus.completed:
        return RequestLifecycleStatus.completed;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'request': request.toMap(),
      'status': status.apiValue,
      'clientId': clientId,
      'customerEmail': customerEmail,
      'assignedWasherName': assignedWasherName,
      'workerId': workerId,
      'assignedWorkerEmail': assignedWorkerEmail,
      'assignedVehicleLabel': assignedVehicleLabel,
      'createdAt': createdAt.toIso8601String(),
      'etaMinutes': etaMinutes,
    };
  }

  Map<String, dynamic> toJson() => toMap();
}

extension WashOrderTrackingX on WashOrder {
  ServiceLocation get customerLocation =>
      ServiceLocation(latitude: request.latitude, longitude: request.longitude);
}
