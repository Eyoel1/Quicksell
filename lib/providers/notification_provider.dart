import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/offer_model.dart';
import '../services/firebase_offer_service.dart';
import '../services/firebase_chat_service.dart';

final _offerService = FirebaseOfferService();
final _chatService  = FirebaseChatService();

/// Number of pending offers the current user (as seller) has not yet responded to.
final pendingOffersCountProvider =
    StreamProvider.family<int, String>((ref, userId) {
  return _offerService.offersForUserStream(userId).map((offers) => offers
      .where((o) =>
          o.sellerId == userId && o.status == OfferStatus.pending)
      .length);
});

/// Total conversations the user has (used as a badge proxy for Messages).
final conversationCountProvider =
    StreamProvider.family<int, String>((ref, userId) {
  return _chatService.getUserConversations(userId).map((c) => c.length);
});
