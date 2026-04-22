import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreWorkerRepository {
  FirestoreWorkerRepository({
    FirebaseFirestore? firestore,
    this.collectionPath = 'workers',
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  final String collectionPath;

  CollectionReference<Map<String, dynamic>> get _workersCollection =>
      _firestore.collection(collectionPath);

  Future<void> setAvailability(
    String uid,
    bool available,
    GeoPoint? location,
  ) {
    return _workersCollection.doc(uid).set({
      'uid': uid,
      'available': available,
      'location': location,
      'currentOrderId': null,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<List<Map<String, dynamic>>> getAvailableWorkers() async {
    final snapshot = await _workersCollection
        .where('available', isEqualTo: true)
        .get();
    return snapshot.docs.map((doc) => doc.data()).toList(growable: false);
  }

  Future<void> updateWorkerLocation(String uid, GeoPoint location) {
    return _workersCollection.doc(uid).set({
      'uid': uid,
      'location': location,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
