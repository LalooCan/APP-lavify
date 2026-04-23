import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../app_config.dart';
import '../models/wash_models.dart';
import '../repositories/firestore_profile_repository.dart';
import '../repositories/mock_profile_repository.dart';
import '../repositories/profile_repository.dart';
import 'session_service.dart';

class ProfileService {
  ProfileService._internal() : _repository = _buildRepository();

  final ProfileRepository _repository;
  static final SessionService _sessionService = SessionService();

  static final ProfileService _instance = ProfileService._internal();

  factory ProfileService() => _instance;

  late final ValueNotifier<UserProfile> profile = ValueNotifier<UserProfile>(
    const UserProfile(
      name: 'Elige tu nombre',
      email: '',
      vehicleLabel: '',
      favoriteAddress: '',
      paymentMethod: '',
    ),
  );

  StreamSubscription<UserProfile?>? _profileSubscription;
  String? _subscribedUid;

  static ProfileRepository _buildRepository() {
    switch (AppConfig.backendMode) {
      case BackendMode.firestore:
        return FirestoreProfileRepository();
      case BackendMode.mock:
        return MockProfileRepository();
    }
  }

  void setProfile(UserProfile next) {
    profile.value = next;
    _sessionService.startSessionFromProfile(next);
    final uid = next.uid.trim();
    if (uid.isNotEmpty) {
      _subscribeToProfile(uid);
    }
  }

  Future<void> loadCurrentUserProfile() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || uid.isEmpty) {
      return;
    }
    final remoteProfile = await _repository.getProfile(uid);
    if (remoteProfile != null) {
      setProfile(remoteProfile);
    } else {
      _subscribeToProfile(uid);
    }
  }

  // Mantiene el notifier en sincronia con Firestore: cualquier cambio en
  // el documento (otra sesion, otro dispositivo, backend) se refleja aqui.
  void _subscribeToProfile(String uid) {
    if (_subscribedUid == uid && _profileSubscription != null) {
      return;
    }
    _profileSubscription?.cancel();
    _subscribedUid = uid;
    _profileSubscription = _repository.watchProfile(uid).listen(
      (remoteProfile) {
        if (remoteProfile == null) {
          return;
        }
        profile.value = remoteProfile;
        _sessionService.updateSession(
          email: remoteProfile.email,
          visibleName: remoteProfile.name,
          favoriteAddress: remoteProfile.favoriteAddress,
        );
      },
      onError: (Object error, StackTrace stack) {
        debugPrint('ProfileService.watchProfile error: $error');
      },
    );
  }

  Future<void> clearCurrentUser() async {
    await _profileSubscription?.cancel();
    _profileSubscription = null;
    _subscribedUid = null;
  }

  Future<void> updateProfile(UserProfile next) async {
    profile.value = next;
    if (next.uid.trim().isEmpty) {
      _sessionService.updateSession(
        email: next.email,
        visibleName: next.name,
        favoriteAddress: next.favoriteAddress,
      );
      return;
    }
    try {
      final saved = await _repository.updateProfile(next);
      profile.value = saved;
      _sessionService.updateSession(
        email: saved.email,
        visibleName: saved.name,
        favoriteAddress: saved.favoriteAddress,
      );
    } catch (error, stack) {
      debugPrint('ProfileService.updateProfile error: $error\n$stack');
      rethrow;
    }
  }

  void syncLoginEmail(String email) {
    syncLoginIdentity(email: email);
  }

  Future<void> syncLoginIdentity({
    required String email,
    String? displayName,
  }) async {
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

    final nextProfile = currentProfile.copyWith(
      email: normalizedEmail.isEmpty ? currentProfile.email : normalizedEmail,
      name: shouldReplaceName && resolvedName.isNotEmpty
          ? resolvedName
          : currentProfile.name,
    );
    profile.value = nextProfile;

    if (nextProfile.uid.trim().isEmpty) {
      _sessionService.updateSession(
        email: nextProfile.email,
        visibleName: nextProfile.name,
      );
      return;
    }

    try {
      await _repository.updateProfile(nextProfile);
      _sessionService.updateSession(
        email: nextProfile.email,
        visibleName: nextProfile.name,
      );
    } catch (error, stack) {
      debugPrint('ProfileService.syncLoginIdentity error: $error\n$stack');
    }
  }

  Future<void> syncFavoriteAddress(String address) async {
    final normalizedAddress = address.trim();
    if (normalizedAddress.isEmpty) {
      return;
    }

    final nextProfile = profile.value.copyWith(
      favoriteAddress: normalizedAddress,
    );
    profile.value = nextProfile;
    _sessionService.updateSession(favoriteAddress: normalizedAddress);

    if (nextProfile.uid.trim().isEmpty) {
      return;
    }

    try {
      await _repository.updateAddress(nextProfile.uid, normalizedAddress);
    } catch (error, stack) {
      debugPrint('ProfileService.syncFavoriteAddress error: $error\n$stack');
    }
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
