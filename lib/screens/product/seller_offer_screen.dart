import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import '../../models/product_model.dart';
import '../../services/firebase_offer_service.dart';
import '../../services/firebase_chat_service.dart';
import '../../services/firebase_product_service.dart';
import '../../models/message_model.dart';

class SellerOfferScreen extends ConsumerStatefulWidget {
  final ProductModel product;
  const SellerOfferScreen({Key? key, required this.product}) : super(key: key);

  @override
  ConsumerState<SellerOfferScreen> createState() => _SellerOfferScreenState();
}

class _SellerOfferScreenState extends ConsumerState<SellerOfferScreen> {
  // ── Colors ────────────────────────────────────────────────────────────────
  static const _primary      = Color(0xFF2979FF);
  static const _bg           = Color(0xFFF2F5FB);
  static const _inputFill    = Color(0xFFEAF1FF);
  static const _border       = Color(0xFFE4EAF3);
  static const _textPrimary  = Color(0xFF101828);
  static const _textSecondary= Color(0xFF667085);
  static const _textHint     = Color(0xFF9CA3AF);
  static const _success      = Color(0xFF059669);
  static const _successLight = Color(0xFFD1FAE5);
  static const _warning      = Color(0xFFD97706);
  static const _warningLight = Color(0xFFFEF3C7);

  final _priceCtrl   = TextEditingController();
  final _messageCtrl = TextEditingController();
  bool _isSending    = false;
  bool _sent         = false;
  List<String> _viewerIds = [];
  bool _loadingViewers    = true;

  final _offerService   = FirebaseOfferService();
  final _chatService    = FirebaseChatService();
  final _productService = FirebaseProductService();

  @override
  void initState() {
    super.initState();
    _loadViewers();
    // Pre-fill with a 10% discount
    final suggested =
        (widget.product.price * 0.90).toStringAsFixed(2);
    _priceCtrl.text = suggested;
  }

  @override
  void dispose() {
    _priceCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadViewers() async {
    try {
      _productService.getViewerIdsStream(widget.product.id).listen((ids) {
        if (mounted) {
          setState(() {
            _viewerIds      = ids.where((id) => id != widget.product.sellerId).toList();
            _loadingViewers = false;
          });
        }
      });
    } catch (_) {
      if (mounted) setState(() => _loadingViewers = false);
    }
  }

  Future<void> _sendOffers() async {
    final price = double.tryParse(_priceCtrl.text.trim());
    if (price == null || price <= 0) {
      _snack('Enter a valid offer price');
      return;
    }
    if (price >= widget.product.price) {
      _snack('Offer price must be lower than the original price');
      return;
    }
    if (_viewerIds.isEmpty) {
      _snack('No viewers to send the offer to yet');
      return;
    }

    setState(() => _isSending = true);
    try {
      final product   = widget.product;
      final msg       = _messageCtrl.text.trim();
      final discount  = ((product.price - price) / product.price * 100).round();

      // Create offer documents in batch
      await _offerService.createSellerDiscountOffers(
        product: product,
        viewerIds: _viewerIds,
        discountedPrice: price,
        message: msg,
      );

      // Send a chat message to each viewer
      for (final viewerId in _viewerIds) {
        try {
          final convId = await _chatService.getOrCreateConversation(
              product.sellerId, viewerId, product.id);
          final chatText =
              '🎉 Special Offer on "${product.title}"!\n\n'
              'Original: \$${product.price.toStringAsFixed(2)}\n'
              'New Price: \$${price.toStringAsFixed(2)} ($discount% off)\n'
              '${msg.isNotEmpty ? '\n$msg' : '\nLimited time — grab it before it\'s gone!'}';
          await _chatService.sendMessage(MessageModel(
            id: const Uuid().v4(),
            senderId:       product.sellerId,
            receiverId:     viewerId,
            conversationId: convId,
            text:           chatText,
            timestamp:      DateTime.now(),
          ));
        } catch (_) {
          // Continue to next viewer even if one fails
        }
      }

      if (mounted) setState(() { _sent = true; _isSending = false; });
    } catch (e) {
      _snack('Error sending offers: $e');
      if (mounted) setState(() => _isSending = false);
    }
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text('Send Offer to Viewers',
            style: GoogleFonts.outfit(
                fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
        centerTitle: true,
      ),
      body: _sent ? _buildSuccess() : _buildForm(),
    );
  }

  Widget _buildSuccess() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96, height: 96,
              decoration: const BoxDecoration(
                  color: _successLight, shape: BoxShape.circle),
              child: const Icon(Icons.check_circle_rounded,
                  color: _success, size: 52),
            ),
            const SizedBox(height: 24),
            Text('Offers Sent!',
                style: GoogleFonts.outfit(
                    fontSize: 28, fontWeight: FontWeight.w800,
                    color: _textPrimary)),
            const SizedBox(height: 12),
            Text(
              'Your special offer has been sent to ${_viewerIds.length} viewer(s) via chat.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 15, color: _textSecondary,
                  height: 1.6),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: Text('Back to My Listings',
                    style: GoogleFonts.outfit(
                        fontSize: 15, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    final original = widget.product.price;
    final offerPrice = double.tryParse(_priceCtrl.text) ?? 0;
    final discountPct = original > 0 && offerPrice > 0 && offerPrice < original
        ? ((original - offerPrice) / original * 100).round()
        : 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Product summary card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _border),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: 64, height: 64,
                    color: _inputFill,
                    child: widget.product.imageUrls.isNotEmpty
                        ? Image.network(widget.product.imageUrls.first,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.image_not_supported_outlined,
                                    color: _textHint))
                        : const Icon(Icons.image_not_supported_outlined,
                            color: _textHint),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.product.title,
                          style: GoogleFonts.outfit(
                              fontSize: 15, fontWeight: FontWeight.w700,
                              color: _textPrimary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Text(
                          'Listed at \$${original.toStringAsFixed(2)}',
                          style: GoogleFonts.inter(
                              fontSize: 13, color: _textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Viewers banner
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: _loadingViewers
                  ? _inputFill
                  : _viewerIds.isEmpty
                      ? _warningLight
                      : _successLight,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Icon(
                  _loadingViewers
                      ? Icons.hourglass_empty_rounded
                      : _viewerIds.isEmpty
                          ? Icons.info_outline_rounded
                          : Icons.people_rounded,
                  color: _loadingViewers
                      ? _textSecondary
                      : _viewerIds.isEmpty
                          ? _warning
                          : _success,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _loadingViewers
                        ? 'Loading viewers…'
                        : _viewerIds.isEmpty
                            ? 'No viewers yet — share your listing to get views!'
                            : '${_viewerIds.length} viewer(s) will receive this offer',
                    style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _loadingViewers
                            ? _textSecondary
                            : _viewerIds.isEmpty
                                ? _warning
                                : _success),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Price input
          Text('Special Offer Price',
              style: GoogleFonts.outfit(
                  fontSize: 15, fontWeight: FontWeight.w700,
                  color: _textPrimary)),
          const SizedBox(height: 8),
          TextField(
            controller: _priceCtrl,
            keyboardType: TextInputType.number,
            onChanged: (_) => setState(() {}),
            style: GoogleFonts.inter(fontSize: 14, color: _textPrimary),
            decoration: InputDecoration(
              hintText: 'e.g. ${(original * 0.85).toStringAsFixed(2)}',
              hintStyle:
                  GoogleFonts.inter(fontSize: 14, color: _textHint),
              prefixIcon: const Icon(Icons.sell_rounded,
                  color: _textSecondary, size: 20),
              filled: true,
              fillColor: _inputFill,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 16),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide:
                      const BorderSide(color: _border, width: 1.5)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide:
                      const BorderSide(color: _primary, width: 2)),
            ),
          ),

          // Discount badge
          if (discountPct > 0) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.local_offer_rounded,
                      color: _primary, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    '$discountPct% discount  ·  Save \$${(original - offerPrice).toStringAsFixed(2)}',
                    style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _primary),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),

          // Message input
          Text('Message (optional)',
              style: GoogleFonts.outfit(
                  fontSize: 15, fontWeight: FontWeight.w700,
                  color: _textPrimary)),
          const SizedBox(height: 8),
          TextField(
            controller: _messageCtrl,
            maxLines: 3,
            style: GoogleFonts.inter(fontSize: 14, color: _textPrimary),
            decoration: InputDecoration(
              hintText:
                  'e.g. "Only 2 left at this price!" or "Bundle deal available"',
              hintStyle:
                  GoogleFonts.inter(fontSize: 13, color: _textHint),
              filled: true,
              fillColor: _inputFill,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 16),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide:
                      const BorderSide(color: _border, width: 1.5)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide:
                      const BorderSide(color: _primary, width: 2)),
            ),
          ),
          const SizedBox(height: 32),

          SizedBox(
            height: 54,
            child: ElevatedButton.icon(
              onPressed:
                  (_isSending || _viewerIds.isEmpty) ? null : _sendOffers,
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              icon: _isSending
                  ? const SizedBox(
                      width: 18, height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.5, color: Colors.white))
                  : const Icon(Icons.send_rounded, size: 20),
              label: Text(
                _isSending
                    ? 'Sending…'
                    : 'Send Offer to ${_viewerIds.length} Viewer(s)',
                style: GoogleFonts.outfit(
                    fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
