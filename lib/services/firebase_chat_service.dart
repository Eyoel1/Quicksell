import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/message_model.dart';

class FirebaseChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Create or retrieve a conversation between two users.
  /// Returns the deterministic conversation ID.
  Future<String> getOrCreateConversation(
    String userId1,
    String userId2,
    String? productId,
  ) async {
    try {
      final conversationId = _generateConversationId(userId1, userId2);
      final ref =
          _firestore.collection('conversations').doc(conversationId);
      final doc = await ref.get();
      if (!doc.exists) {
        await ref.set({
          'id': conversationId,
          'userId1': userId1,
          'userId2': userId2,
          'productId': productId,
          'createdAt': DateTime.now().toIso8601String(),
          'lastMessage': '',
          'lastMessageTime': DateTime.now().toIso8601String(),
          'unreadCount': 0,
        });
      }
      return conversationId;
    } catch (e) {
      rethrow;
    }
  }

  /// Send a message and update the conversation's last-message metadata.
  Future<void> sendMessage(MessageModel message) async {
    try {
      await _firestore
          .collection('conversations')
          .doc(message.conversationId)
          .collection('messages')
          .doc(message.id)
          .set(message.toJson());

      await _firestore
          .collection('conversations')
          .doc(message.conversationId)
          .update({
        'lastMessage': message.text,
        'lastMessageTime': message.timestamp.toIso8601String(),
      });
    } catch (e) {
      rethrow;
    }
  }

  /// Real-time stream of messages in a conversation (newest first).
  Stream<List<MessageModel>> getMessages(String conversationId) {
    return _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MessageModel.fromJson({'id': doc.id, ...doc.data()}))
            .toList());
  }

  /// Fix: queries BOTH sides of the conversation (userId1 OR userId2).
  /// Previously only queried userId1, so received conversations were invisible.
  Stream<List<Map<String, dynamic>>> getUserConversations(String userId) {
    // cloud_firestore 5.x supports Filter.or for cross-field OR queries
    return _firestore
        .collection('conversations')
        .where(Filter.or(
          Filter('userId1', isEqualTo: userId),
          Filter('userId2', isEqualTo: userId),
        ))
        .snapshots()
        .asyncMap((snapshot) async {
      final conversations = <Map<String, dynamic>>[];

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final otherUserId =
            data['userId1'] == userId ? data['userId2'] : data['userId1'];

        Map<String, dynamic>? otherUser;
        try {
          final userDoc =
              await _firestore.collection('users').doc(otherUserId).get();
          otherUser = userDoc.data();
        } catch (_) {
          otherUser = {'displayName': 'User'};
        }

        conversations.add({
          'id': doc.id,
          'userId1': data['userId1'],
          'userId2': data['userId2'],
          'lastMessage': data['lastMessage'] ?? '',
          'lastMessageTime':
              data['lastMessageTime'] ?? DateTime.now().toIso8601String(),
          'productId': data['productId'],
          'otherUser': otherUser,
        });
      }

      // Sort by lastMessageTime descending in memory
      conversations.sort((a, b) {
        final ta = DateTime.tryParse(a['lastMessageTime'] as String) ??
            DateTime.now();
        final tb = DateTime.tryParse(b['lastMessageTime'] as String) ??
            DateTime.now();
        return tb.compareTo(ta);
      });

      return conversations;
    });
  }

  Future<void> markMessageAsRead(
      String conversationId, String messageId) async {
    try {
      await _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .doc(messageId)
          .update({'isRead': true});
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteConversation(String conversationId) async {
    try {
      final messages = await _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .get();
      for (final doc in messages.docs) {
        await doc.reference.delete();
      }
      await _firestore
          .collection('conversations')
          .doc(conversationId)
          .delete();
    } catch (e) {
      rethrow;
    }
  }

  String _generateConversationId(String userId1, String userId2) {
    final ids = [userId1, userId2]..sort();
    return '${ids[0]}_${ids[1]}';
  }
}
