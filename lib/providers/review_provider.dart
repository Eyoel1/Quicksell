import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/review_model.dart';
import '../services/firebase_review_service.dart';

final reviewServiceProvider = Provider((ref) => FirebaseReviewService());

final userReviewsProvider =
    StreamProvider.family<List<ReviewModel>, String>((ref, userId) {
  return ref.watch(reviewServiceProvider).reviewsForUserStream(userId);
});

final productReviewsProvider =
    StreamProvider.family<List<ReviewModel>, String>((ref, productId) {
  return ref.watch(reviewServiceProvider).reviewsForProductStream(productId);
});
