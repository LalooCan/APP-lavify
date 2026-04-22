import '../models/wash_models.dart';
import 'profile_repository.dart';

class MockProfileRepository implements ProfileRepository {
  @override
  Future<UserProfile?> getProfile(String uid) async => _profile;

  @override
  Future<UserProfile> updateProfile(UserProfile profile) async {
    _profile = profile;
    return _profile;
  }

  @override
  Future<void> updateAddress(String uid, String address) async {
    _profile = _profile.copyWith(favoriteAddress: address.trim());
  }

  UserProfile _profile = const UserProfile(
    name: 'Elige tu nombre',
    email: 'cliente@lavify.app',
    vehicleLabel: 'Sedan mediano - Color gris',
    favoriteAddress: 'Av. Reforma 245, CDMX',
    paymentMethod: 'Visa terminacion 4242',
  );


  UserProfile saveProfile(UserProfile profile) {
    _profile = profile;
    return _profile;
  }

  UserProfile syncLoginEmail(String email) {
    final normalizedEmail = email.trim();
    if (normalizedEmail.isEmpty) {
      return _profile;
    }

    _profile = _profile.copyWith(email: normalizedEmail);
    return _profile;
  }
}
