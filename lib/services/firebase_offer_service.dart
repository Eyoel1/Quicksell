import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/offer_model.dart';
import '../models/product_model.dart';
import '../models/transaction_model.dart';

class FirebaseOfferService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> createBuyerOffer({
    required ProductModel product,
    required String buyerId,
    required double offerPrice,
    String? message,
  }) async {
    final ref = _firestore.collection('offers').doc();
    final offer = OfferModel(
      id: ref.id,
      productId: product.id,
      productTitle: product.title,
      buyerId: buyerId,
      sellerId: product.sellerId,
      offerPrice: offerPrice,
      originalPrice: product.price,
      message: message,
      type: OfferType.buyerOffer,
      createdAt: DateTime.now(),
    );
    await ref.set(offer.toJson());
    return ref.id;
  }

  Future<List<String>> createSellerDiscountOffers({
    required ProductModel product,
    required List<String> viewerIds,
    required double discountedPrice,
    String? message,
  }) async {
    final batch = _firestore.batch();
    final ids = <String>[];
    for (final viewerId in viewerIds.toSet()) {
      if (viewerId == product.sellerId) continue;
      final ref = _firestore.collection('offers').doc();
      ids.add(ref.id);
      final offer = OfferModel(
        id: ref.id,
        productId: product.id,
        productTitle: product.title,
        buyerId: viewerId,
        sellerId: product.sellerId,
        offerPrice: discountedPrice,
        originalPrice: product.price,
        message: message,
        type: OfferType.sellerDiscount,
        createdAt: DateTime.now(),
      );
      batch.set(ref, offer.toJson());
    }
    if (ids.isNotEmpty) await batch.commit();
    return ids;
  }

  Stream<List<OfferModel>> offersForUserStream(String userId) {
    return _firestore
        .collection('offers')
        .where(Filter.or(
          Filter('buyerId', isEqualTo: userId),
          Filter('sellerId', isEqualTo: userId),
        ))
        .snapshots()
        .map((snapshot) {
      final offers = snapshot.docs
          .map((doc) => OfferModel.fromJson({'id': doc.id, ...doc.data()}))
          .toList();
      offers.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return offers;
    });
  }

  Stream<List<OfferModel>> productOffersStream(String productId) {
    return _firestore
        .collection('offers')
        .where('productId', isEqualTo: productId)
        .snapshots()
        .map((snapshot) {
      final offers = snapshot.docs
          .map((doc) => OfferModel.fromJson({'id': doc.id, ...doc.data()}))
          .toList();
      offers.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return offers;
    });
  }

  Future<void> declineOffer(String offerId) async {
    await _firestore.collection('offers').doc(offerId).update({
      'status': OfferStatus.declined.name,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  Future<String> acceptOffer(OfferModel offer) async {
    final transactionRef = _firestore.collection('transactions').doc();
    final offerRef = _firestore.collection('offers').doc(offer.id);
    final transaction = TransactionModel(
      id: transactionRef.id,
      productId: offer.productId,
      productTitle: offer.productTitle,
      buyerId: offer.buyerId,
      sellerId: offer.sellerId,
      finalPrice: offer.offerPrice,
      createdAt: DateTime.now(),
    );

    final batch = _firestore.batch();
    batch.update(offerRef, {
      'status': OfferStatus.accepted.name,
      'updatedAt': DateTime.now().toIso8601String(),
    });
    batch.set(transactionRef, transaction.toJson());
    batch.update(_firestore.collection('products').doc(offer.productId), {
      'status': ProductStatus.pending.name,
    });
    await batch.commit();
    return transactionRef.id;
  }
}
