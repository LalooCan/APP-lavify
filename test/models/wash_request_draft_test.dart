import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lavify_app/models/wash_models.dart';

WashPackage _samplePackage({int price = 149}) => WashPackage(
      id: 'full-care',
      name: 'Full Care',
      description: 'desc',
      price: price,
      priceLabel: 'Lavado full care',
      summary: 'Full Care',
      icon: Icons.cleaning_services_rounded,
    );

ScheduleSlot _sampleSlot() =>
    const ScheduleSlot(id: 'now', time: 'Ahora mismo', period: 'Disponible');

VehicleType _sampleVehicle() => const VehicleType(
      id: 'sedan',
      name: 'Sedan mediano',
      icon: Icons.directions_car_filled_rounded,
    );

VehicleType _suvVehicle() => const VehicleType(
      id: 'suv',
      name: 'SUV',
      icon: Icons.airport_shuttle_rounded,
      extraFee: 30,
    );

WashRequestDraft _draft({
  String address = 'Av. Reforma 245',
  bool locationConfirmed = true,
  int travelFee = 30,
  int packagePrice = 149,
  VehicleType? vehicle,
}) {
  return WashRequestDraft(
    selectedPackage: _samplePackage(price: packagePrice),
    address: address,
    selectedSchedule: _sampleSlot(),
    selectedVehicle: vehicle ?? _sampleVehicle(),
    estimatedMinutes: 30,
    travelFee: travelFee,
    notes: '',
    selectedLocation: const ServiceLocation(latitude: 19.42, longitude: -99.16),
    isLocationConfirmed: locationConfirmed,
  );
}

void main() {
  group('WashRequestDraft', () {
    test('totalPrice suma paquete y travel fee', () {
      expect(_draft(packagePrice: 149, travelFee: 30).totalPrice, 179);
    });

    test('totalPrice incluye extra por vehiculo', () {
      expect(
        _draft(packagePrice: 149, travelFee: 20, vehicle: _suvVehicle())
            .totalPrice,
        199,
      );
    });

    test('isReadyForConfirmation true cuando todos los campos son validos', () {
      expect(_draft().isReadyForConfirmation, isTrue);
      expect(_draft().validationMessage, isNull);
    });

    test('valida direccion vacia', () {
      final draft = _draft(address: '   ');
      expect(draft.isReadyForConfirmation, isFalse);
      expect(draft.validationMessage,
          'Agrega una direccion antes de confirmar el lavado.');
    });

    test('valida ubicacion no confirmada', () {
      final draft = _draft(locationConfirmed: false);
      expect(draft.isReadyForConfirmation, isFalse);
      expect(draft.validationMessage,
          'Confirma la ubicacion en el mapa antes de continuar.');
    });

    test('toRequest hereda precio total', () {
      final request = _draft(packagePrice: 99, travelFee: 20).toRequest();
      expect(request.servicePrice, 99);
      expect(request.travelFee, 20);
      expect(request.totalPrice, 119);
      expect(request.status, RequestLifecycleStatus.draft);
    });

    test('round-trip toMap / fromMap preserva campos clave', () {
      final original = _draft();
      final map = {
        ...original.toMap(),
        'selectedSchedule': null,
      };
      final rebuilt = WashRequestDraft.fromMap(map);
      expect(rebuilt.selectedPackage.id, original.selectedPackage.id);
      expect(rebuilt.address, original.address);
      expect(rebuilt.selectedLocation, original.selectedLocation);
      expect(rebuilt.isLocationConfirmed, original.isLocationConfirmed);
    });
  });
}
