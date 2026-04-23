import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/wash_models.dart';
import 'profile_repository.dart';

class FirestoreProfileRepository implements ProfileRepository {
  FirestoreProfileRepository({
    FirebaseFirestore? firestore,
    this.collectionPath = 'profiles',
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  final String collectionPath;

  CollectionReference<Map<String, dynamic>> get _profilesCollection =>
      _firestore.collection(collectionPath);

  @override
  Future<UserProfile?> getProfile(String uid) async {
    if (uid.trim().isEmpty) {
      return null;
    }

    final snapshot = await _profilesCollection.doc(uid).get();
    final data = snapshot.data();
    if (data == null) {
      return null;
    }
    return UserProfile.fromMap({...data, 'uid': uid});
  }

  @override
  Future<UserProfile> updateProfile(UserProfile profile) async {
    if (profile.uid.trim().isEmpty) {
      throw ArgumentError('El perfil necesita uid para guardarse en Firestore.');
    }

    await _profilesCollection.doc(profile.uid).set({
      ...profile.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    return profile;
  }

  @override
  Future<void> updateAddress(String uid, String address) {
    if (uid.trim().isEmpty) {
      throw ArgumentError('El perfil necesita uid para guardarse en Firestore.');
    }
    final normalized = address.trim();
    return _profilesCollection.doc(uid).set({
      'favoriteAddress': normalized,
      'address': normalized,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Stream<UserProfile?> watchProfile(String uid) {
    if (uid.trim().isEmpty) {
      return Stream<UserProfile?>.value(null);
    }
    return _profilesCollection.doc(uid).snapshots().map((snapshot) {
      final data = snapshot.data();
      if (data == null) {
        return null;
      }
      return UserProfile.fromMap({...data, 'uid': uid});
    });
  }
}
