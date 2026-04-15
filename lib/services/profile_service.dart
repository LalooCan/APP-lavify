import 'package:flutter/foundation.dart';

import '../models/wash_models.dart';
import '../repositories/mock_profile_repository.dart';
import '../repositories/profile_repository.dart';
import 'session_service.dart';

class ProfileService {
  ProfileService._internal() : _repository = MockProfileRepository();

  final ProfileRepository _repository;
  static final SessionService _sessionService = SessionService();

  static final ProfileService _instance = ProfileService._internal();

  factory ProfileService() => _instance;

  late final ValueNotifier<UserProfile> profile = ValueNotifier<UserProfile>(
    _repository.getProfile(),
  );

  void updateProfile(UserProfile next) {
    profile.value = _repository.saveProfile(next);
    _sessionService.updateSession(
      email: next.email,
      visibleName: next.name,
      favoriteAddress: next.favoriteAddress,
    );
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
    _repository.saveProfile(profile.value);
    _sessionService.updateSession(
      email: profile.value.email,
      visibleName: profile.value.name,
    );
  }

  void syncFavoriteAddress(String address) {
    final normalizedAddress = address.trim();
    if (normalizedAddress.isEmpty) {
      return;
    }

    profile.value = _repository.saveProfile(
      profile.value.copyWith(favoriteAddress: normalizedAddress),
    );
    _sessionService.updateSession(favoriteAddress: normalizedAddress);
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
