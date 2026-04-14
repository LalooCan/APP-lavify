import 'package:flutter/foundation.dart';

import '../models/wash_models.dart';

class ProfileService {
  ProfileService._internal();

  static final ProfileService _instance = ProfileService._internal();

  factory ProfileService() => _instance;

  final ValueNotifier<UserProfile> profile = ValueNotifier<UserProfile>(
    const UserProfile(
      name: 'Elige tu nombre',
      email: 'cliente@lavify.app',
      vehicleLabel: 'Sedan mediano - Color gris',
      favoriteAddress: 'Av. Reforma 245, CDMX',
      paymentMethod: 'Visa terminacion 4242',
    ),
  );

  void updateProfile(UserProfile next) {
    profile.value = next;
  }

  void syncLoginEmail(String email) {
    final normalizedEmail = email.trim();
    if (normalizedEmail.isEmpty) {
      return;
    }

    profile.value = profile.value.copyWith(email: normalizedEmail);
  }
}
