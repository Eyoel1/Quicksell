import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import '../../providers/auth_provider.dart';
import '../../services/firebase_chat_service.dart';
import '../../models/message_model.dart';
import '../../config/theme/theme_colors.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String? initialConversationId;
  final String? receiverId;
  final String? receiverName;

  const ChatScreen({
    Key? key,
    this.initialConversationId,
    this.receiverId,
    this.receiverName,
  }) : super(key: key);

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final FirebaseChatService _chatService = FirebaseChatService();
  late TextEditingController _messageController;
  final ScrollController _scrollController = ScrollController();

  Color get _bg            => TC.bg(context);
  Color get _surface       => TC.surface(context);
  Color get _card          => TC.card(context);
  Color get _inputFill     => TC.inputFill(context);
  Color get _border        => TC.border(context);
  Color get _textPrimary   => TC.textPrimary(context);
  Color get _textSecondary => TC.textSecondary(context);
  Color get _textHint      => TC.textHint(context);
  static const _primary    = TC.primary;
  static const _cardShadow = TC.cardShadow;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    if (widget.initialConversationId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _openConversationDialog(
          context,
          widget.initialConversationId!,
          widget.receiverName ?? 'Seller',
          widget.receiverId ?? '',
        );
      });
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Messages',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
      body: authState.when(
        data: (user) {
          if (user == null) return _buildSignedOut();
          return StreamBuilder<List<Map<String, dynamic>>>(
            stream: _chatService.getUserConversations(user.uid),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: _primary),
                );
              }
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error loading messages',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: _textSecondary,
                    ),
                  ),
                );
              }
              final conversations = snapshot.data ?? [];
              if (conversations.isEmpty) return _buildEmptyChat();
              return _buildConversationsList(conversations, user.uid);
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: _primary),
        ),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildEmptyChat() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline_rounded,
              size: 80,
              color: _primary.withOpacity(0.2),
            ),
            const SizedBox(height: 16),
            Text(
              'No messages yet',
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: _textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Contact a seller to start a conversation',
              style: GoogleFonts.inter(fontSize: 14, color: _textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignedOut() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline_rounded,
            size: 80,
            color: _primary.withOpacity(0.2),
          ),
          const SizedBox(height: 16),
          Text(
            'Sign in to view messages',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: _textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationsList(
    List<Map<String, dynamic>> conversations,
    String currentUserId,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: conversations.length,
      itemBuilder: (context, index) {
        final conv = conversations[index];
        final otherUser = conv['otherUser'] as Map<String, dynamic>?;
        final name = otherUser?['displayName'] as String? ?? 'User';
        final lastMessage = conv['lastMessage'] as String? ?? '';
        final lastTime =
            DateTime.tryParse(conv['lastMessageTime'] as String? ?? '') ??
                DateTime.now();
        final receiverId = conv['userId1'] == currentUserId
            ? conv['userId2'] as String
            : conv['userId1'] as String;

        return GestureDetector(
          onTap: () => _openConversationDialog(
            context,
            conv['id'] as String,
            name,
            receiverId,
          ),
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _border),
              boxShadow: const [
                BoxShadow(
                  color: _cardShadow,
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              leading: CircleAvatar(
                radius: 26,
                backgroundColor: _inputFill,
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : 'U',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: _primary,
                  ),
                ),
              ),
              title: Text(
                name,
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: _textPrimary,
                ),
              ),
              subtitle: Text(
                lastMessage.isEmpty ? 'No messages yet' : lastMessage,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: _textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Text(
                _formatTime(lastTime),
                style: GoogleFonts.inter(fontSize: 11, color: _textHint),
              ),
            ),
          ),
        );
      },
    );
  }

  void _openConversationDialog(
    BuildContext context,
    String conversationId,
    String otherUserName,
    String receiverId,
  ) {
    final authState = ref.read(authStateProvider);
    final currentUserId = authState.value?.uid;
    if (currentUserId == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.92,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, scrollController) => Container(
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: _border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: _inputFill,
                      child: Text(
                        otherUserName.isNotEmpty
                            ? otherUserName[0].toUpperCase()
                            : 'U',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: _primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        otherUserName,
                        style: GoogleFonts.outfit(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: _textPrimary,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close_rounded,
                        color: _textSecondary,
                      ),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),
              Divider(color: _border, height: 1),
              // Messages list
              Expanded(
                child: StreamBuilder<List<MessageModel>>(
                  stream: _chatService.getMessages(conversationId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(color: _primary),
                      );
                    }
                    final messages = snapshot.data ?? [];
                    if (messages.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline_rounded,
                              size: 48,
                              color: _primary.withOpacity(0.2),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Send a message to start chatting',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: _textSecondary,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return ListView.builder(
                      controller: scrollController,
                      reverse: true,
                      padding: const EdgeInsets.all(16),
                      itemCount: messages.length,
                      itemBuilder: (_, i) {
                        final msg = messages[i];
                        final isMe = msg.senderId == currentUserId;
                        return Align(
                          alignment: isMe
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            margin: EdgeInsets.only(
                              bottom: 8,
                              left: isMe ? 60 : 0,
                              right: isMe ? 0 : 60,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: isMe ? _primary : _card,
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(16),
                                topRight: const Radius.circular(16),
                                bottomLeft:
                                    Radius.circular(isMe ? 16 : 4),
                                bottomRight:
                                    Radius.circular(isMe ? 4 : 16),
                              ),
                            ),
                            child: Text(
                              msg.text,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: isMe ? Colors.white : _textPrimary,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              // Input bar
              Container(
                padding: EdgeInsets.fromLTRB(
                  16,
                  8,
                  16,
                  max(16.0, MediaQuery.of(ctx).viewInsets.bottom + 16),
                ),
                decoration: BoxDecoration(
                  color: _surface,
                  border: Border(
                    top: BorderSide(color: _border),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: _textPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          hintStyle: GoogleFonts.inter(
                            color: _textHint,
                            fontSize: 14,
                          ),
                          filled: true,
                          fillColor: _inputFill,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: const BorderSide(
                              color: TC.primary,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: _primary,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.send_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed: () => _sendMessage(
                          conversationId,
                          currentUserId,
                          receiverId,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _sendMessage(
    String conversationId,
    String senderId,
    String receiverId,
  ) async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    _messageController.clear();
    try {
      final message = MessageModel(
        id: const Uuid().v4(),
        senderId: senderId,
        receiverId: receiverId,
        conversationId: conversationId,
        text: text,
        timestamp: DateTime.now(),
      );
      await _chatService.sendMessage(message);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not send message: $e')),
        );
      }
    }
  }

  String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inHours < 1) return '${diff.inMinutes}m';
    if (diff.inDays < 1) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${dt.month}/${dt.day}';
  }
}
