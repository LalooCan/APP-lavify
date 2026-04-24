import 'dart:convert';

import 'package:flutter/material.dart';

import 'service_location.dart';
import 'wash_package.dart';

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
  bool get hasValidPricing =>
      selectedPackage.price >= 0 && travelFee >= 0 && vehicleExtraFee >= 0;
  int get vehicleExtraFee => selectedVehicle.extraFee;
  int get totalPrice => selectedPackage.price + travelFee + vehicleExtraFee;
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
        extraFee:
            (map['vehicleExtraFee'] as num?)?.toInt() ??
            vehicleExtraFeeFor(map['vehicleTypeId'] as String),
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
      'vehicleExtraFee': vehicleExtraFee,
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
