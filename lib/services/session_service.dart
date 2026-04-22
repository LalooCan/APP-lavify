import 'package:flutter/foundation.dart';

import '../models/session_models.dart';
import '../models/wash_models.dart';

class SessionService {
  SessionService._internal();

  static final SessionService _instance = SessionService._internal();

  factory SessionService() => _instance;

  final ValueNotifier<MockSession?> currentSession = ValueNotifier<MockSession?>(
    null,
  );

  void startSession({
    String uid = '',
    required AppRole role,
    required String email,
    required String visibleName,
    required String favoriteAddress,
  }) {
    currentSession.value = MockSession(
      role: role,
      email: email.trim(),
      visibleName: visibleName.trim(),
      favoriteAddress: favoriteAddress.trim(),
    );
  }

  void startSessionFromProfile(UserProfile profile) {
    startSession(
      uid: profile.uid,
      role: profile.role,
      email: profile.email,
      visibleName: profile.name,
      favoriteAddress: profile.favoriteAddress,
    );
  }

  void updateSession({
    AppRole? role,
    String? email,
    String? visibleName,
    String? favoriteAddress,
  }) {
    final session = currentSession.value;
    if (session == null) {
      return;
    }

    currentSession.value = session.copyWith(
      role: role,
      email: email,
      visibleName: visibleName,
      favoriteAddress: favoriteAddress,
    );
  }

  void clearSession() {
    currentSession.value = null;
  }
}
