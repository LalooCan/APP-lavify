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
  const VehicleType({
    required this.id,
    required this.name,
    required this.icon,
  });

  final String id;
  final String name;
  final IconData icon;
}

class ServiceLocation {
  const ServiceLocation({
    required this.latitude,
    required this.longitude,
  });

  final double latitude;
  final double longitude;

  LatLng toLatLng() => LatLng(latitude, longitude);

  String get coordinatesLabel =>
      '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';

  ServiceLocation copyWith({
    double? latitude,
    double? longitude,
  }) {
    return ServiceLocation(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }

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

enum LocationAddressSource {
  reverseGeocoding,
  manual,
  fallback,
}

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
    return {
      'lat': lat,
      'lng': lng,
      'address': address,
    };
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
  bool get isReadyForConfirmation =>
      hasValidPackage && hasValidAddress && hasValidLocation;

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
    final total = selectedPackage.price + travelFee;

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
      totalPrice: total,
      estimatedMinutes: estimatedMinutes,
      currency: 'MXN',
      status: 'draft',
      createdAt: DateTime.now().toUtc(),
    );
  }

  Map<String, dynamic> toBackendPayload() => toRequest().toMap();

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
  final String status;
  final DateTime createdAt;

  int get price => totalPrice;

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
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }

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
}

class WashOrder {
  const WashOrder({
    required this.id,
    required this.request,
    required this.status,
    required this.assignedWasherName,
    required this.assignedVehicleLabel,
    required this.createdAt,
    required this.etaMinutes,
  });

  final String id;
  final WashRequest request;
  final OrderStatus status;
  final String assignedWasherName;
  final String assignedVehicleLabel;
  final DateTime createdAt;
  final int etaMinutes;

  WashOrder copyWith({
    OrderStatus? status,
    int? etaMinutes,
  }) {
    return WashOrder(
      id: id,
      request: request,
      status: status ?? this.status,
      assignedWasherName: assignedWasherName,
      assignedVehicleLabel: assignedVehicleLabel,
      createdAt: createdAt,
      etaMinutes: etaMinutes ?? this.etaMinutes,
    );
  }
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
  VehicleType(
    id: 'suv',
    name: 'SUV',
    icon: Icons.airport_shuttle_rounded,
  ),
];
