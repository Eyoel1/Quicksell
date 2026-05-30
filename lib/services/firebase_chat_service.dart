import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/message_model.dart';

class FirebaseChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create or get conversation
  Future<String> getOrCreateConversation(
    String userId1,
    String userId2,
    String? productId,
  ) async {
    try {
      final conversationId = _generateConversationId(userId1, userId2);

      final doc = await _firestore
          .collection('conversations')
          .doc(conversationId)
          .get();

      if (!doc.exists) {
        await _firestore.collection('conversations').doc(conversationId).set({
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

  // Send message
  Future<void> sendMessage(MessageModel message) async {
    try {
      await _firestore
          .collection('conversations')
          .doc(message.conversationId)
          .collection('messages')
          .doc(message.id)
          .set(message.toJson());

      // Update conversation last message
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

  // Get messages for conversation
  Stream<List<MessageModel>> getMessages(String conversationId) {
    return _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => MessageModel.fromJson({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();
    });
  }

  // Get conversations for user
  Stream<List<Map<String, dynamic>>> getUserConversations(String userId) {
    return _firestore
        .collection('conversations')
        .where('userId1', isEqualTo: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      final conversations = <Map<String, dynamic>>[];

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final otherUserId =
            data['userId1'] == userId ? data['userId2'] : data['userId1'];

        // Get other user's profile
        final userDoc =
            await _firestore.collection('users').doc(otherUserId).get();

        conversations.add({
          'id': doc.id,
          'userId1': data['userId1'],
          'userId2': data['userId2'],
          'lastMessage': data['lastMessage'],
          'lastMessageTime': data['lastMessageTime'],
          'productId': data['productId'],
          'otherUser': userDoc.data(),
        });
      }

      return conversations;
    });
  }

  // Mark message as read
  Future<void> markMessageAsRead(
    String conversationId,
    String messageId,
  ) async {
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

  // Delete conversation
  Future<void> deleteConversation(String conversationId) async {
    try {
      // Delete all messages in conversation
      final messages = await _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .get();

      for (final doc in messages.docs) {
        await doc.reference.delete();
      }

      // Delete conversation
      await _firestore.collection('conversations').doc(conversationId).delete();
    } catch (e) {
      rethrow;
    }
  }

  // Generate conversation ID
  String _generateConversationId(String userId1, String userId2) {
    final ids = [userId1, userId2]..sort();
    return '${ids[0]}_${ids[1]}';
  }
}
