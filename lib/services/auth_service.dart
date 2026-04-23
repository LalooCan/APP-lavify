import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../models/wash_models.dart';

class AuthService {
  static const _webClientId =
      '66350788000-vrkk9hflkn0m4e6gha4d7q3bbslaaae8.apps.googleusercontent.com';

  AuthService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
  }) : _auth = auth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _googleSignIn =
           googleSignIn ?? GoogleSignIn(clientId: kIsWeb ? _webClientId : null);

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  CollectionReference<Map<String, dynamic>> get _profilesCollection =>
      _firestore.collection('profiles');

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<User?> signInWithGoogle({
    AppRole fallbackRole = AppRole.client,
  }) async {
    try {
      UserCredential userCredential;

      if (kIsWeb) {
        final provider = GoogleAuthProvider();
        provider.addScope('email');
        provider.addScope('profile');
        userCredential = await _auth.signInWithPopup(provider);
      } else {
        final googleUser = await _googleSignIn.signIn();
        if (googleUser == null) {
          return null;
        }

        final googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        userCredential = await _auth.signInWithCredential(credential);
      }

      final user = userCredential.user;
      if (user == null) {
        return null;
      }

      await loadOrCreateUserProfile(user: user, fallbackRole: fallbackRole);
      return user;
    } catch (e) {
      debugPrint('Error Google Sign-In: $e');
      return null;
    }
  }

  Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  ) {
    return _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<UserCredential> createUserWithEmailAndPassword(
    String email,
    String password, {
    AppRole fallbackRole = AppRole.client,
    String? displayName,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final user = credential.user;
    if (user != null) {
      final normalizedDisplayName = displayName?.trim() ?? '';
      if (normalizedDisplayName.isNotEmpty) {
        await user.updateDisplayName(normalizedDisplayName);
      }
      await _createUserProfile(
        user: user,
        fallbackRole: fallbackRole,
        displayName: normalizedDisplayName,
      );
    }
    return credential;
  }

  Future<AppRole> resolveUserRole({
    User? user,
    AppRole fallbackRole = AppRole.client,
  }) async {
    final current = user ?? currentUser;
    if (current == null) {
      return fallbackRole;
    }

    final snapshot = await _profilesCollection.doc(current.uid).get();
    final data = snapshot.data();
    if (data == null) {
      return fallbackRole;
    }

    final rawRole = (data['role'] as String? ?? '').trim().toLowerCase();
    return rawRole == 'worker' ? AppRole.worker : AppRole.client;
  }

  Future<Map<String, dynamic>?> loadProfileData({User? user}) async {
    final current = user ?? currentUser;
    if (current == null) {
      return null;
    }

    final snapshot = await _profilesCollection.doc(current.uid).get();
    return snapshot.data();
  }

  Future<UserProfile> loadOrCreateUserProfile({
    User? user,
    AppRole fallbackRole = AppRole.client,
    String? displayName,
  }) async {
    final current = user ?? currentUser;
    if (current == null) {
      throw StateError('No hay usuario autenticado.');
    }

    final doc = _profilesCollection.doc(current.uid);
    final snapshot = await doc.get();
    final data = snapshot.data();

    if (data == null) {
      return _createUserProfile(
        user: current,
        fallbackRole: fallbackRole,
        displayName: displayName,
      );
    }

    final updates = _profileUpdatesForExisting(
      existing: data,
      user: current,
      fallbackRole: fallbackRole,
      displayName: displayName,
    );
    if (updates.isEmpty) {
      return UserProfile.fromMap(data);
    }

    await doc.set({
      ...updates,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    return UserProfile.fromMap({...data, ...updates});
  }

  Future<void> signOut() async {
    if (!kIsWeb) {
      await _googleSignIn.signOut();
    }
    await _auth.signOut();
  }

  Future<UserProfile> _createUserProfile({
    required User user,
    required AppRole fallbackRole,
    String? displayName,
  }) async {
    final doc = _profilesCollection.doc(user.uid);
    final profileData = _newProfileData(
      user: user,
      fallbackRole: fallbackRole,
      displayName: displayName,
    );

    await doc.set({
      ...profileData,
      'updatedAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    return UserProfile.fromMap(profileData);
  }

  Map<String, dynamic> _newProfileData({
    required User user,
    required AppRole fallbackRole,
    String? displayName,
  }) {
    final resolvedName = _resolveProfileName(
      user: user,
      displayName: displayName,
    );

    return {
      'uid': user.uid,
      'name': resolvedName,
      'displayName': resolvedName,
      'email': user.email?.trim() ?? '',
      'photoUrl': user.photoURL,
      'role': fallbackRole.name,
    };
  }

  Map<String, dynamic> _profileUpdatesForExisting({
    required Map<String, dynamic> existing,
    required User user,
    required AppRole fallbackRole,
    String? displayName,
  }) {
    final updates = <String, dynamic>{};
    final explicitDisplayName = displayName?.trim() ?? '';
    final existingName = _stringValue(existing, 'name');
    final existingDisplayName = _stringValue(existing, 'displayName');
    final email = user.email?.trim() ?? '';
    final photoUrl = user.photoURL?.trim() ?? '';

    if (_stringValue(existing, 'uid') != user.uid) {
      updates['uid'] = user.uid;
    }
    if (email.isNotEmpty && _stringValue(existing, 'email') != email) {
      updates['email'] = email;
    }
    if (_stringValue(existing, 'role').isEmpty) {
      updates['role'] = fallbackRole.name;
    }
    if (photoUrl.isNotEmpty && _stringValue(existing, 'photoUrl') != photoUrl) {
      updates['photoUrl'] = photoUrl;
    }

    if (explicitDisplayName.isNotEmpty) {
      if (existingName != explicitDisplayName) {
        updates['name'] = explicitDisplayName;
      }
      if (existingDisplayName != explicitDisplayName) {
        updates['displayName'] = explicitDisplayName;
      }
      return updates;
    }

    if (existingName.isEmpty && existingDisplayName.isEmpty) {
      final resolvedName = _resolveProfileName(user: user, existing: existing);
      updates['name'] = resolvedName;
      updates['displayName'] = resolvedName;
    } else if (existingName.isEmpty) {
      updates['name'] = existingDisplayName;
    } else if (existingDisplayName.isEmpty) {
      updates['displayName'] = existingName;
    }

    return updates;
  }

  String _resolveProfileName({
    required User user,
    Map<String, dynamic>? existing,
    String? displayName,
  }) {
    final explicitDisplayName = displayName?.trim() ?? '';
    if (explicitDisplayName.isNotEmpty) {
      return explicitDisplayName;
    }

    final authDisplayName = user.displayName?.trim() ?? '';
    if (authDisplayName.isNotEmpty) {
      return authDisplayName;
    }

    final storedDisplayName = _stringValue(existing, 'displayName');
    if (storedDisplayName.isNotEmpty) {
      return storedDisplayName;
    }

    final storedName = _stringValue(existing, 'name');
    if (storedName.isNotEmpty) {
      return storedName;
    }

    return 'Usuario Lavify';
  }

  String _stringValue(Map<String, dynamic>? data, String key) {
    final value = data?[key];
    return value is String ? value.trim() : '';
  }
}
