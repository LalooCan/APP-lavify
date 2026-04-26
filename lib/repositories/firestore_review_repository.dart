import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/review.dart';

class FirestoreReviewRepository {
  FirestoreReviewRepository._internal();

  static final FirestoreReviewRepository _instance =
      FirestoreReviewRepository._internal();

  factory FirestoreReviewRepository() => _instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      FirebaseFirestore.instance.collection('reviews');

  Future<Review> createReview(Review review) async {
    await _col.doc(review.id).set({
      ...review.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });
    return review;
  }

  Future<Review?> getReviewForOrder(String orderId) async {
    final snap = await _col
        .where('orderId', isEqualTo: orderId)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    final data = snap.docs.first.data();
    data['id'] = snap.docs.first.id;
    return Review.fromMap(data);
  }

  Stream<List<Review>> watchWorkerReviews(String workerId) {
    return _col
        .where('workerId', isEqualTo: workerId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snap) => snap.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return Review.fromMap(data);
            }).toList());
  }

  Future<double> getWorkerAverageRating(String workerId) async {
    final snap = await _col
        .where('workerId', isEqualTo: workerId)
        .get();
    if (snap.docs.isEmpty) return 0;
    final total = snap.docs.fold<int>(
      0,
      (acc, doc) => acc + ((doc.data()['rating'] as num?)?.toInt() ?? 0),
    );
    return total / snap.docs.length;
  }
}
