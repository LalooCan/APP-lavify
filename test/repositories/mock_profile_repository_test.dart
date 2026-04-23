import 'package:flutter_test/flutter_test.dart';
import 'package:lavify_app/models/wash_models.dart';
import 'package:lavify_app/repositories/mock_profile_repository.dart';

void main() {
  group('MockProfileRepository', () {
    test('getProfile devuelve el perfil seed', () async {
      final repo = MockProfileRepository();
      final profile = await repo.getProfile('any');
      expect(profile, isNotNull);
      expect(profile!.email, 'cliente@lavify.app');
    });

    test('updateProfile reemplaza el estado interno', () async {
      final repo = MockProfileRepository();
      const next = UserProfile(
        uid: 'u',
        name: 'Nuevo Nombre',
        email: 'nuevo@x.com',
        vehicleLabel: '',
        favoriteAddress: '',
        paymentMethod: '',
      );
      final saved = await repo.updateProfile(next);
      expect(saved.name, 'Nuevo Nombre');
      final reloaded = await repo.getProfile('u');
      expect(reloaded!.email, 'nuevo@x.com');
    });

    test('updateAddress trim-ea y persiste', () async {
      final repo = MockProfileRepository();
      await repo.updateAddress('u', '  Av Reforma  ');
      final reloaded = await repo.getProfile('u');
      expect(reloaded!.favoriteAddress, 'Av Reforma');
    });

    test('watchProfile emite el seed y luego cambios', () async {
      final repo = MockProfileRepository();
      final stream = repo.watchProfile('u');
      final completer = expectLater(
        stream.take(2).map((p) => p?.email).toList(),
        completion(['cliente@lavify.app', 'b@x.com']),
      );
      // Da un tick para que se enganche el listener antes de emitir.
      await Future<void>.delayed(Duration.zero);
      await repo.updateProfile(
        const UserProfile(
          uid: 'u',
          name: 'B',
          email: 'b@x.com',
          vehicleLabel: '',
          favoriteAddress: '',
          paymentMethod: '',
        ),
      );
      await completer;
    });
  });
}
