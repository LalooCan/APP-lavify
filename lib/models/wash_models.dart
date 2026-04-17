import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class WashPackage {
  const WashPackage({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.priceLabel,
    required this.summary,
    required this.icon,
  });

  final String id;
  final String name;
  final String description;
  final int price;
  final String priceLabel;
  final String summary;
  final IconData icon;

  String get formattedPrice => '\$$price';

  factory WashPackage.fromMap(Map<String, dynamic> map) {
    return WashPackage(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      price: map['price'] as int,
      priceLabel: map['priceLabel'] as String,
      summary: map['summary'] as String,
      icon: Icons.local_car_wash_rounded,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'priceLabel': priceLabel,
      'summary': summary,
    };
  }

  Map<String, dynamic> toJson() => toMap();
}

class ScheduleSlot {
  const ScheduleSlot({
    required this.id,
    required this.time,
    required this.period,
  });

  final String id;
  final String time;
  final String period;

  String get label => '$period - $time';
}

class VehicleType {
  const VehicleType({required this.id, required this.name, required this.icon});

  final String id;
  final String name;
  final IconData icon;
}

class ServiceLocation {
  const ServiceLocation({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;

  LatLng toLatLng() => LatLng(latitude, longitude);

  factory ServiceLocation.fromMap(Map<String, dynamic> map) {
    return ServiceLocation(
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
    );
  }

  String get coordinatesLabel =>
      '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';

  ServiceLocation copyWith({double? latitude, double? longitude}) {
    return ServiceLocation(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  Map<String, dynamic> toMap() {
    return {'latitude': latitude, 'longitude': longitude};
  }

  Map<String, dynamic> toJson() => toMap();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is ServiceLocation &&
        other.latitude == latitude &&
        other.longitude == longitude;
  }

  @override
  int get hashCode => Object.hash(latitude, longitude);
}

enum LocationAddressSource { reverseGeocoding, manual, fallback }

class LocationResolution {
  const LocationResolution({
    required this.location,
    required this.address,
    required this.source,
    required this.isPrecise,
    this.errorMessage,
  });

  final ServiceLocation location;
  final String address;
  final LocationAddressSource source;
  final bool isPrecise;
  final String? errorMessage;

  bool get hasError => errorMessage != null && errorMessage!.trim().isNotEmpty;

  LocationResolution copyWith({
    ServiceLocation? location,
    String? address,
    LocationAddressSource? source,
    bool? isPrecise,
    String? errorMessage,
  }) {
    return LocationResolution(
      location: location ?? this.location,
      address: address ?? this.address,
      source: source ?? this.source,
      isPrecise: isPrecise ?? this.isPrecise,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class ServiceLocationPayload {
  const ServiceLocationPayload({
    required this.lat,
    required this.lng,
    required this.address,
  });

  final double lat;
  final double lng;
  final String address;

  Map<String, dynamic> toMap() {
    return {'lat': lat, 'lng': lng, 'address': address};
  }

  Map<String, dynamic> toJson() => toMap();
}

enum RequestLifecycleStatus {
  draft,
  confirmed,
  assigned,
  inProgress,
  completed,
}

extension RequestLifecycleStatusX on RequestLifecycleStatus {
  String get apiValue {
    switch (this) {
      case RequestLifecycleStatus.draft:
        return 'draft';
      case RequestLifecycleStatus.confirmed:
        return 'confirmed';
      case RequestLifecycleStatus.assigned:
        return 'assigned';
      case RequestLifecycleStatus.inProgress:
        return 'in_progress';
      case RequestLifecycleStatus.completed:
        return 'completed';
    }
  }

  static RequestLifecycleStatus fromValue(String value) {
    switch (value) {
      case 'confirmed':
        return RequestLifecycleStatus.confirmed;
      case 'assigned':
        return RequestLifecycleStatus.assigned;
      case 'in_progress':
        return RequestLifecycleStatus.inProgress;
      case 'completed':
        return RequestLifecycleStatus.completed;
      case 'draft':
      default:
        return RequestLifecycleStatus.draft;
    }
  }
}

class WashRequestDraft {
  const WashRequestDraft({
    required this.selectedPackage,
    required this.address,
    required this.selectedSchedule,
    required this.selectedVehicle,
    required this.estimatedMinutes,
    required this.travelFee,
    required this.notes,
    required this.selectedLocation,
    required this.isLocationConfirmed,
  });

  final WashPackage selectedPackage;
  final String address;
  final ScheduleSlot selectedSchedule;
  final VehicleType selectedVehicle;
  final int estimatedMinutes;
  final int travelFee;
  final String notes;
  final ServiceLocation selectedLocation;
  final bool isLocationConfirmed;

  bool get hasValidPackage => selectedPackage.id.trim().isNotEmpty;
  bool get hasValidAddress => address.trim().isNotEmpty;
  bool get hasValidLocation => isLocationConfirmed;
  bool get hasValidPricing => selectedPackage.price >= 0 && travelFee >= 0;
  int get totalPrice => selectedPackage.price + travelFee;
  bool get isReadyForConfirmation =>
      hasValidPackage && hasValidAddress && hasValidLocation && hasValidPricing;

  String? get validationMessage {
    if (!hasValidPackage) {
      return 'Selecciona un paquete antes de continuar.';
    }
    if (!hasValidAddress) {
      return 'Agrega una direccion antes de confirmar el lavado.';
    }
    if (!hasValidLocation) {
      return 'Confirma la ubicacion en el mapa antes de continuar.';
    }
    if (!hasValidPricing) {
      return 'No se pudo calcular el precio del servicio.';
    }
    return null;
  }

  factory WashRequestDraft.fromMap(Map<String, dynamic> map) {
    return WashRequestDraft(
      selectedPackage: WashPackage.fromMap(
        map['selectedPackage'] as Map<String, dynamic>,
      ),
      address: map['address'] as String,
      selectedSchedule: ScheduleSlot(
        id: map['scheduleId'] as String,
        time: map['scheduleTime'] as String,
        period: map['schedulePeriod'] as String,
      ),
      selectedVehicle: VehicleType(
        id: map['vehicleTypeId'] as String,
        name: map['vehicleTypeName'] as String,
        icon: Icons.directions_car_filled_rounded,
      ),
      estimatedMinutes: map['estimatedMinutes'] as int,
      travelFee: map['travelFee'] as int,
      notes: (map['notes'] as String?) ?? '',
      selectedLocation: ServiceLocation.fromMap(
        map['selectedLocation'] as Map<String, dynamic>,
      ),
      isLocationConfirmed: map['isLocationConfirmed'] as bool,
    );
  }

  WashRequestDraft copyWith({
    WashPackage? selectedPackage,
    String? address,
    ScheduleSlot? selectedSchedule,
    VehicleType? selectedVehicle,
    int? estimatedMinutes,
    int? travelFee,
    String? notes,
    ServiceLocation? selectedLocation,
    bool? isLocationConfirmed,
  }) {
    return WashRequestDraft(
      selectedPackage: selectedPackage ?? this.selectedPackage,
      address: address ?? this.address,
      selectedSchedule: selectedSchedule ?? this.selectedSchedule,
      selectedVehicle: selectedVehicle ?? this.selectedVehicle,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      travelFee: travelFee ?? this.travelFee,
      notes: notes ?? this.notes,
      selectedLocation: selectedLocation ?? this.selectedLocation,
      isLocationConfirmed: isLocationConfirmed ?? this.isLocationConfirmed,
    );
  }

  WashRequest toRequest() {
    return WashRequest(
      serviceType: 'mobile_car_wash',
      packageId: selectedPackage.id,
      packageName: selectedPackage.name,
      vehicleTypeId: selectedVehicle.id,
      vehicleTypeName: selectedVehicle.name,
      address: address.trim(),
      latitude: selectedLocation.latitude,
      longitude: selectedLocation.longitude,
      scheduleId: selectedSchedule.id,
      scheduleLabel: selectedSchedule.label,
      notes: notes.trim(),
      servicePrice: selectedPackage.price,
      travelFee: travelFee,
      totalPrice: totalPrice,
      estimatedMinutes: estimatedMinutes,
      currency: 'MXN',
      status: RequestLifecycleStatus.draft,
      createdAt: DateTime.now().toUtc(),
    );
  }

  Map<String, dynamic> toBackendPayload() => toRequest().toMap();

  Map<String, dynamic> toMap() {
    return {
      'selectedPackage': selectedPackage.toMap(),
      'packageId': selectedPackage.id,
      'packageName': selectedPackage.name,
      'address': address.trim(),
      'scheduleId': selectedSchedule.id,
      'scheduleTime': selectedSchedule.time,
      'schedulePeriod': selectedSchedule.period,
      'vehicleTypeId': selectedVehicle.id,
      'vehicleTypeName': selectedVehicle.name,
      'estimatedMinutes': estimatedMinutes,
      'travelFee': travelFee,
      'totalPrice': totalPrice,
      'notes': notes.trim(),
      'selectedLocation': selectedLocation.toMap(),
      'latitude': selectedLocation.latitude,
      'longitude': selectedLocation.longitude,
      'isLocationConfirmed': isLocationConfirmed,
    };
  }

  Map<String, dynamic> toJson() => toMap();

  ServiceLocationPayload toLocationPayload() {
    return ServiceLocationPayload(
      lat: selectedLocation.latitude,
      lng: selectedLocation.longitude,
      address: address.trim(),
    );
  }
}

class WashRequest {
  const WashRequest({
    required this.serviceType,
    required this.packageId,
    required this.packageName,
    required this.vehicleTypeId,
    required this.vehicleTypeName,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.scheduleId,
    required this.scheduleLabel,
    required this.notes,
    required this.servicePrice,
    required this.travelFee,
    required this.totalPrice,
    required this.estimatedMinutes,
    required this.currency,
    required this.status,
    required this.createdAt,
  });

  final String serviceType;
  final String packageId;
  final String packageName;
  final String vehicleTypeId;
  final String vehicleTypeName;
  final String address;
  final double latitude;
  final double longitude;
  final String scheduleId;
  final String scheduleLabel;
  final String notes;
  final int servicePrice;
  final int travelFee;
  final int totalPrice;
  final int estimatedMinutes;
  final String currency;
  final RequestLifecycleStatus status;
  final DateTime createdAt;

  int get price => totalPrice;

  factory WashRequest.fromMap(Map<String, dynamic> map) {
    return WashRequest(
      serviceType: map['serviceType'] as String,
      packageId: map['packageId'] as String,
      packageName: map['packageName'] as String,
      vehicleTypeId: map['vehicleTypeId'] as String,
      vehicleTypeName: map['vehicleTypeName'] as String,
      address: map['address'] as String,
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      scheduleId: map['scheduleId'] as String,
      scheduleLabel: map['scheduleLabel'] as String,
      notes: (map['notes'] as String?) ?? '',
      servicePrice: map['servicePrice'] as int,
      travelFee: map['travelFee'] as int,
      totalPrice: map['totalPrice'] as int,
      estimatedMinutes: map['estimatedMinutes'] as int,
      currency: map['currency'] as String,
      status: RequestLifecycleStatusX.fromValue(map['status'] as String),
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'serviceType': serviceType,
      'packageId': packageId,
      'packageName': packageName,
      'vehicleTypeId': vehicleTypeId,
      'vehicleTypeName': vehicleTypeName,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'scheduleId': scheduleId,
      'scheduleLabel': scheduleLabel,
      'notes': notes,
      'servicePrice': servicePrice,
      'travelFee': travelFee,
      'totalPrice': totalPrice,
      'estimatedMinutes': estimatedMinutes,
      'currency': currency,
      'status': status.apiValue,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toJsonMap() => toMap();
  String toJson() => const JsonEncoder.withIndent('  ').convert(toMap());

  Map<String, dynamic> toApiPayload() {
    return {
      'packageId': packageId,
      'packageName': packageName,
      'price': totalPrice,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'vehicleTypeId': vehicleTypeId,
      'vehicleTypeName': vehicleTypeName,
      'scheduleId': scheduleId,
      'scheduleLabel': scheduleLabel,
      'notes': notes,
    };
  }
}

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
    required this.customerEmail,
    required this.assignedWasherName,
    this.assignedWorkerEmail,
    required this.assignedVehicleLabel,
    required this.createdAt,
    required this.etaMinutes,
  });

  final String id;
  final WashRequest request;
  final OrderStatus status;
  final String customerEmail;
  final String assignedWasherName;
  final String? assignedWorkerEmail;
  final String assignedVehicleLabel;
  final DateTime createdAt;
  final int etaMinutes;

  factory WashOrder.fromMap(Map<String, dynamic> map) {
    return WashOrder(
      id: map['id'] as String,
      request: WashRequest.fromMap(map['request'] as Map<String, dynamic>),
      status: OrderStatusX.fromValue(map['status'] as String),
      customerEmail: map['customerEmail'] as String,
      assignedWasherName: map['assignedWasherName'] as String,
      assignedWorkerEmail: map['assignedWorkerEmail'] as String?,
      assignedVehicleLabel: map['assignedVehicleLabel'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      etaMinutes: map['etaMinutes'] as int,
    );
  }

  WashOrder copyWith({
    OrderStatus? status,
    String? customerEmail,
    String? assignedWasherName,
    String? assignedWorkerEmail,
    String? assignedVehicleLabel,
    int? etaMinutes,
  }) {
    return WashOrder(
      id: id,
      request: request,
      status: status ?? this.status,
      customerEmail: customerEmail ?? this.customerEmail,
      assignedWasherName: assignedWasherName ?? this.assignedWasherName,
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
      'customerEmail': customerEmail,
      'assignedWasherName': assignedWasherName,
      'assignedWorkerEmail': assignedWorkerEmail,
      'assignedVehicleLabel': assignedVehicleLabel,
      'createdAt': createdAt.toIso8601String(),
      'etaMinutes': etaMinutes,
    };
  }

  Map<String, dynamic> toJson() => toMap();
}

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

extension WashOrderTrackingX on WashOrder {
  ServiceLocation get customerLocation =>
      ServiceLocation(latitude: request.latitude, longitude: request.longitude);
}

class UserProfile {
  const UserProfile({
    required this.name,
    required this.email,
    required this.vehicleLabel,
    required this.favoriteAddress,
    required this.paymentMethod,
  });

  final String name;
  final String email;
  final String vehicleLabel;
  final String favoriteAddress;
  final String paymentMethod;

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      name: map['name'] as String,
      email: map['email'] as String,
      vehicleLabel: map['vehicleLabel'] as String,
      favoriteAddress: map['favoriteAddress'] as String,
      paymentMethod: map['paymentMethod'] as String,
    );
  }

  UserProfile copyWith({
    String? name,
    String? email,
    String? vehicleLabel,
    String? favoriteAddress,
    String? paymentMethod,
  }) {
    return UserProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      vehicleLabel: vehicleLabel ?? this.vehicleLabel,
      favoriteAddress: favoriteAddress ?? this.favoriteAddress,
      paymentMethod: paymentMethod ?? this.paymentMethod,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'vehicleLabel': vehicleLabel,
      'favoriteAddress': favoriteAddress,
      'paymentMethod': paymentMethod,
    };
  }

  Map<String, dynamic> toJson() => toMap();
}

const List<WashPackage> washPackages = [
  WashPackage(
    id: 'express',
    name: 'Express',
    description: 'Lavado exterior rapido para mantener tu auto impecable.',
    price: 99,
    priceLabel: 'Lavado express',
    summary: 'Express exterior',
    icon: Icons.flash_on_rounded,
  ),
  WashPackage(
    id: 'full-care',
    name: 'Full Care',
    description: 'Exterior e interior con enfoque en limpieza detallada.',
    price: 149,
    priceLabel: 'Lavado full care',
    summary: 'Full Care interior + exterior',
    icon: Icons.cleaning_services_rounded,
  ),
  WashPackage(
    id: 'premium',
    name: 'Premium',
    description: 'Acabado profundo, brillo y sanitizacion completa.',
    price: 199,
    priceLabel: 'Lavado premium',
    summary: 'Premium interior + exterior',
    icon: Icons.auto_awesome_rounded,
  ),
];

const List<ScheduleSlot> scheduleSlots = [
  ScheduleSlot(id: 'now', time: 'Ahora mismo', period: 'Disponible'),
  ScheduleSlot(id: 'today_630', time: '6:30 PM', period: 'Hoy'),
  ScheduleSlot(id: 'today_800', time: '8:00 PM', period: 'Hoy'),
  ScheduleSlot(id: 'tomorrow_900', time: '9:00 AM', period: 'Manana'),
  ScheduleSlot(id: 'tomorrow_1130', time: '11:30 AM', period: 'Manana'),
  ScheduleSlot(id: 'tomorrow_200', time: '2:00 PM', period: 'Manana'),
];

const List<VehicleType> vehicleTypes = [
  VehicleType(
    id: 'compact',
    name: 'Compacto',
    icon: Icons.directions_car_filled_rounded,
  ),
  VehicleType(
    id: 'sedan',
    name: 'Sedan mediano',
    icon: Icons.drive_eta_rounded,
  ),
  VehicleType(id: 'suv', name: 'SUV', icon: Icons.airport_shuttle_rounded),
];
