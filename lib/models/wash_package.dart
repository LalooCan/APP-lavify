import 'package:flutter/material.dart';

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
  const VehicleType({
    required this.id,
    required this.name,
    required this.icon,
    this.extraFee = 0,
  });

  final String id;
  final String name;
  final IconData icon;
  final int extraFee;
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
    extraFee: 30,
  ),
];

int vehicleExtraFeeFor(String vehicleId) {
  for (final vehicle in vehicleTypes) {
    if (vehicle.id == vehicleId) {
      return vehicle.extraFee;
    }
  }
  return 0;
}
