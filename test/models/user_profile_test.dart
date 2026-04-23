import 'package:flutter_test/flutter_test.dart';
import 'package:lavify_app/models/wash_models.dart';

void main() {
  group('UserProfile', () {
    test('fromMap reconoce role worker', () {
      final profile = UserProfile.fromMap({
        'uid': 'abc',
        'name': 'Ana',
        'email': 'ana@x.com',
        'role': 'worker',
        'vehicleLabel': 'Sedan',
        'favoriteAddress': 'Calle 1',
        'paymentMethod': 'Cash',
      });
      expect(profile.role, AppRole.worker);
      expect(profile.uid, 'abc');
    });

    test('fromMap usa client por defecto cuando role esta vacio', () {
      final profile = UserProfile.fromMap({'name': 'Ana', 'email': 'a@x.com'});
      expect(profile.role, AppRole.client);
    });

    test('fromMap acepta address como alias de favoriteAddress', () {
      final profile = UserProfile.fromMap({
        'name': 'Ana',
        'email': 'a@x.com',
        'address': 'Av Reforma',
      });
      expect(profile.favoriteAddress, 'Av Reforma');
    });

    test('toMap escribe ambas claves de direccion', () {
      const profile = UserProfile(
        uid: 'u',
        name: 'Ana',
        email: 'a@x.com',
        vehicleLabel: '',
        favoriteAddress: 'Av Insurgentes',
        paymentMethod: '',
      );
      final map = profile.toMap();
      expect(map['favoriteAddress'], 'Av Insurgentes');
      expect(map['address'], 'Av Insurgentes');
      expect(map['displayName'], 'Ana');
    });

    test('copyWith aplica solo los campos pasados', () {
      const base = UserProfile(
        uid: 'u',
        name: 'Ana',
        email: 'a@x.com',
        vehicleLabel: '',
        favoriteAddress: '',
        paymentMethod: '',
      );
      final updated = base.copyWith(name: 'Juan');
      expect(updated.name, 'Juan');
      expect(updated.email, base.email);
      expect(updated.uid, base.uid);
    });
  });
}
