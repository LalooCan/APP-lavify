import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../models/session_models.dart';

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

      await _ensureUserProfile(user: user, fallbackRole: fallbackRole);
      return user;
    } catch (e) {
      debugPrint('Error Google Sign-In: $e');
      return null;
    }
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

  Future<void> signOut() async {
    if (!kIsWeb) {
      await _googleSignIn.signOut();
    }
    await _auth.signOut();
  }

  Future<void> _ensureUserProfile({
    required User user,
    required AppRole fallbackRole,
  }) async {
    final doc = _profilesCollection.doc(user.uid);
    final snapshot = await doc.get();
    final existing = snapshot.data();
    final role = existing?['role'] as String? ?? fallbackRole.name;

    await doc.set({
      'uid': user.uid,
      'name': user.displayName ?? existing?['name'] ?? 'Usuario Lavify',
      'email': user.email ?? existing?['email'] ?? '',
      'photoUrl': user.photoURL ?? existing?['photoUrl'],
      'role': role,
      'updatedAt': FieldValue.serverTimestamp(),
      if (!snapshot.exists) 'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
