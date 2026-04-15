import '../models/wash_models.dart';
import 'profile_repository.dart';

class MockProfileRepository implements ProfileRepository {
  UserProfile _profile = const UserProfile(
    name: 'Elige tu nombre',
    email: 'cliente@lavify.app',
    vehicleLabel: 'Sedan mediano - Color gris',
    favoriteAddress: 'Av. Reforma 245, CDMX',
    paymentMethod: 'Visa terminacion 4242',
  );

  @override
  UserProfile getProfile() => _profile;

  @override
  UserProfile saveProfile(UserProfile profile) {
    _profile = profile;
    return _profile;
  }

  @override
  UserProfile syncLoginEmail(String email) {
    final normalizedEmail = email.trim();
    if (normalizedEmail.isEmpty) {
      return _profile;
    }

    _profile = _profile.copyWith(email: normalizedEmail);
    return _profile;
  }
}
