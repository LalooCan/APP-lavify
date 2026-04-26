import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/review.dart';
import '../repositories/firestore_review_repository.dart';

class ReviewService {
  ReviewService._internal();

  static final ReviewService _instance = ReviewService._internal();

  factory ReviewService() => _instance;

  final FirestoreReviewRepository _repo = FirestoreReviewRepository();

  Future<Review?> submitReview({
    required String orderId,
    required String workerId,
    required int rating,
    required String comment,
  }) async {
    final clientId = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (clientId.isEmpty || workerId.isEmpty) return null;

    final existing = await _repo.getReviewForOrder(orderId);
    if (existing != null) return existing;

    final review = Review(
      id: 'review_${DateTime.now().millisecondsSinceEpoch}',
      orderId: orderId,
      clientId: clientId,
      workerId: workerId,
      rating: rating.clamp(1, 5),
      comment: comment.trim(),
      createdAt: DateTime.now().toUtc(),
    );

    try {
      return await _repo.createReview(review);
    } catch (e, st) {
      debugPrint('ReviewService.submitReview error: $e\n$st');
      return null;
    }
  }

  Future<Review?> getReviewForOrder(String orderId) =>
      _repo.getReviewForOrder(orderId);

  Stream<List<Review>> watchWorkerReviews(String workerId) =>
      _repo.watchWorkerReviews(workerId);

  Future<double> getWorkerAverageRating(String workerId) =>
      _repo.getWorkerAverageRating(workerId);
}
