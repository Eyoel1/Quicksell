import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/review_model.dart';

class FirebaseReviewService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> createReview(ReviewModel review) async {
    final ref = _firestore.collection('reviews').doc();
    await ref.set(review.toJson()..['id'] = ref.id);
    return ref.id;
  }

  Stream<List<ReviewModel>> reviewsForUserStream(String userId) {
    return _firestore
        .collection('reviews')
        .where('revieweeId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final reviews = snapshot.docs
          .map((doc) => ReviewModel.fromJson({'id': doc.id, ...doc.data()}))
          .toList();
      reviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return reviews;
    });
  }

  Stream<List<ReviewModel>> reviewsForProductStream(String productId) {
    return _firestore
        .collection('reviews')
        .where('productId', isEqualTo: productId)
        .snapshots()
        .map((snapshot) {
      final reviews = snapshot.docs
          .map((doc) => ReviewModel.fromJson({'id': doc.id, ...doc.data()}))
          .toList();
      reviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return reviews;
    });
  }

  double averageRating(List<ReviewModel> reviews) {
    if (reviews.isEmpty) return 0;
    return reviews.map((r) => r.rating).reduce((a, b) => a + b) /
        reviews.length;
  }
}
