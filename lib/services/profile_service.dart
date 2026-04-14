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
      favoriteAddress: '',
      paymentMethod: 'Visa terminacion 4242',
    ),
  );

  void updateProfile(UserProfile next) {
    profile.value = next;
  }

  void syncLoginEmail(String email) {
    syncLoginIdentity(email: email);
  }

  void syncLoginIdentity({required String email, String? displayName}) {
    final normalizedEmail = email.trim();
    final normalizedDisplayName = displayName?.trim() ?? '';
    if (normalizedEmail.isEmpty && normalizedDisplayName.isEmpty) {
      return;
    }

    final currentProfile = profile.value;
    final shouldReplaceName =
        currentProfile.name.trim().isEmpty ||
        currentProfile.name == 'Elige tu nombre';
    final resolvedName = normalizedDisplayName.isNotEmpty
        ? normalizedDisplayName
        : _deriveNameFromEmail(normalizedEmail);

    profile.value = currentProfile.copyWith(
      email: normalizedEmail.isEmpty ? currentProfile.email : normalizedEmail,
      name: shouldReplaceName && resolvedName.isNotEmpty
          ? resolvedName
          : currentProfile.name,
    );
  }

  void syncFavoriteAddress(String address) {
    final normalizedAddress = address.trim();
    if (normalizedAddress.isEmpty) {
      return;
    }

    profile.value = profile.value.copyWith(favoriteAddress: normalizedAddress);
  }

  String resolveGreetingName() {
    final currentProfile = profile.value;
    final trimmedName = currentProfile.name.trim();
    if (trimmedName.isNotEmpty && trimmedName != 'Elige tu nombre') {
      return _extractFirstName(trimmedName);
    }

    final derivedFromEmail = _deriveNameFromEmail(currentProfile.email);
    if (derivedFromEmail.isNotEmpty) {
      return _extractFirstName(derivedFromEmail);
    }

    return 'bienvenido';
  }

  String _deriveNameFromEmail(String email) {
    final trimmedEmail = email.trim();
    if (trimmedEmail.isEmpty || !trimmedEmail.contains('@')) {
      return '';
    }

    final localPart = trimmedEmail.split('@').first.trim();
    if (localPart.isEmpty) {
      return '';
    }

    final normalized = localPart
        .replaceAll(RegExp(r'[._-]+'), ' ')
        .replaceAll(RegExp(r'\d+'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    if (normalized.isEmpty) {
      return '';
    }

    return normalized
        .split(' ')
        .where((segment) => segment.isNotEmpty)
        .map(_capitalizeWord)
        .join(' ');
  }

  String _extractFirstName(String value) {
    final trimmedValue = value.trim();
    if (trimmedValue.isEmpty) {
      return '';
    }

    return _capitalizeWord(trimmedValue.split(RegExp(r'\s+')).first);
  }

  String _capitalizeWord(String value) {
    if (value.isEmpty) {
      return value;
    }

    final lowerCased = value.toLowerCase();
    return '${lowerCased[0].toUpperCase()}${lowerCased.substring(1)}';
  }
}
