// Valida que el catálogo de precios del lado Flutter coincida con el del backend.
import 'package:flutter_test/flutter_test.dart';
import 'package:lavify_app/models/wash_models.dart';

void main() {
  group('Catálogo de paquetes — precios server-side', () {
    const expectedPrices = {
      'express': 99,
      'full-care': 149,
      'premium': 199,
    };

    test('cada paquete tiene el precio correcto', () {
      for (final pkg in washPackages) {
        expect(
          pkg.price,
          expectedPrices[pkg.id],
          reason: 'Precio incorrecto para paquete ${pkg.id}',
        );
      }
    });

    test('IDs de paquetes coinciden con los conocidos por el backend', () {
      final ids = washPackages.map((p) => p.id).toSet();
      expect(ids, containsAll(expectedPrices.keys));
    });
  });

  group('Catálogo de vehículos — fees server-side', () {
    test('SUV tiene fee de 30, otros 0', () {
      final suv = vehicleTypes.firstWhere((v) => v.id == 'suv');
      final compact = vehicleTypes.firstWhere((v) => v.id == 'compact');
      final sedan = vehicleTypes.firstWhere((v) => v.id == 'sedan');
      expect(suv.extraFee, 30);
      expect(compact.extraFee, 0);
      expect(sedan.extraFee, 0);
    });
  });

  group('WashRequestDraft.toRequest — cálculo de totalPrice', () {
    test('totalPrice = servicePrice + travelFee + extraFee', () {
      final pkg = washPackages.first; // express → 99
      final vehicle = vehicleTypes.firstWhere((v) => v.id == 'suv'); // +30
      const travelFee = 50;

      final draft = WashRequestDraft(
        selectedPackage: pkg,
        address: 'Av. Reforma 1',
        selectedSchedule: scheduleSlots.first,
        selectedVehicle: vehicle,
        estimatedMinutes: 30,
        travelFee: travelFee,
        notes: '',
        selectedLocation: const ServiceLocation(latitude: 19.4, longitude: -99.1),
        isLocationConfirmed: true,
      );

      final request = draft.toRequest();
      expect(request.totalPrice, pkg.price + travelFee + vehicle.extraFee);
    });
  });
}
