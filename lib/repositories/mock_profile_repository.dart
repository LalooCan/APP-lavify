import 'dart:async';

import '../models/wash_models.dart';
import 'profile_repository.dart';

class MockProfileRepository implements ProfileRepository {
  final StreamController<UserProfile?> _controller =
      StreamController<UserProfile?>.broadcast();

  @override
  Future<UserProfile?> getProfile(String uid) async => _profile;

  @override
  Future<UserProfile> updateProfile(UserProfile profile) async {
    _profile = profile;
    _controller.add(_profile);
    return _profile;
  }

  @override
  Future<void> updateAddress(String uid, String address) async {
    _profile = _profile.copyWith(favoriteAddress: address.trim());
    _controller.add(_profile);
  }

  @override
  Stream<UserProfile?> watchProfile(String uid) async* {
    yield _profile;
    yield* _controller.stream;
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
    _controller.add(_profile);
    return _profile;
  }

  UserProfile syncLoginEmail(String email) {
    final normalizedEmail = email.trim();
    if (normalizedEmail.isEmpty) {
      return _profile;
    }

    _profile = _profile.copyWith(email: normalizedEmail);
    _controller.add(_profile);
    return _profile;
  }
}
