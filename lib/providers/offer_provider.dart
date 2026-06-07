import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/offer_model.dart';
import '../services/firebase_offer_service.dart';

final offerServiceProvider = Provider((ref) => FirebaseOfferService());

final userOffersProvider =
    StreamProvider.family<List<OfferModel>, String>((ref, userId) {
  return ref.watch(offerServiceProvider).offersForUserStream(userId);
});

final productOffersProvider =
    StreamProvider.family<List<OfferModel>, String>((ref, productId) {
  return ref.watch(offerServiceProvider).productOffersStream(productId);
});
