import 'dart:math' show min;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';
import '../../providers/product_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/saved_items_provider.dart';
import '../../routes/app_routes.dart';
import '../../services/firebase_product_service.dart';
import '../../services/firebase_chat_service.dart';
import '../../services/firebase_saved_items_service.dart';
import '../../services/firebase_offer_service.dart';
import '../../services/firebase_report_service.dart';
import '../../models/product_model.dart';
import '../../models/offer_model.dart';
import '../../models/report_model.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final String productId;
  const ProductDetailScreen({Key? key, required this.productId})
      : super(key: key);

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  // ── Colors ───────────────────────────────────────────────────────────────────
  static const _background    = Color(0xFFF2F5FB);
  static const _surface       = Color(0xFFFFFFFF);
  static const _inputFill     = Color(0xFFEAF1FF);
  static const _primary       = Color(0xFF2979FF);
  static const _primaryDark   = Color(0xFF1A5FCC);
  static const _textPrimary   = Color(0xFF101828);
  static const _textSecondary = Color(0xFF667085);
  static const _border        = Color(0xFFE4EAF3);

  // ── State ────────────────────────────────────────────────────────────────────
  int  _selectedImageIndex = 0;
  bool _isLikeLoading      = false;
  bool _isSaveLoading      = false;

  @override
  void initState() {
    super.initState();
    FirebaseProductService().incrementViewCount(widget.productId);
    // Track this user as a viewer so seller can send discount offers.
    Future.microtask(() {
      final uid = ref.read(authStateProvider).value?.uid;
      if (uid != null) {
        FirebaseProductService().trackViewer(widget.productId, uid);
      }
    });
  }

  // ── Condition helpers ────────────────────────────────────────────────────────
  String _conditionLabel(ProductCondition cond) {
    switch (cond) {
      case ProductCondition.new_:
        return 'New';
      case ProductCondition.likeNew:
        return 'Like New';
      case ProductCondition.good:
        return 'Good';
      case ProductCondition.fair:
        return 'Fair';
    }
  }

  Color _conditionColor(ProductCondition cond) {
    switch (cond) {
      case ProductCondition.new_:
        return const Color(0xFF059669);
      case ProductCondition.likeNew:
        return const Color(0xFF0284C7);
      case ProductCondition.good:
        return const Color(0xFFD97706);
      case ProductCondition.fair:
        return const Color(0xFFDC2626);
    }
  }

  // ── Category helpers ─────────────────────────────────────────────────────────
  Color _categoryTint(ProductCategory cat) {
    switch (cat) {
      case ProductCategory.electronics:
        return const Color(0xFFE0F2FE);
      case ProductCategory.clothing:
        return const Color(0xFFFCE7F3);
      case ProductCategory.furniture:
        return const Color(0xFFFEF3C7);
      case ProductCategory.books:
        return const Color(0xFFF3E8FF);
      case ProductCategory.sports:
        return const Color(0xFFD1FAE5);
      case ProductCategory.toys:
        return const Color(0xFFFEE2E2);
      case ProductCategory.home:
        return const Color(0xFFE0F2FE);
      case ProductCategory.fashion:
        return const Color(0xFFFCE7F3);
      case ProductCategory.other:
        return const Color(0xFFF1F5F9);
    }
  }

  Color _categoryIconColor(ProductCategory cat) {
    switch (cat) {
      case ProductCategory.electronics:
        return const Color(0xFF0284C7);
      case ProductCategory.clothing:
        return const Color(0xFFDB2777);
      case ProductCategory.furniture:
        return const Color(0xFFD97706);
      case ProductCategory.books:
        return const Color(0xFF7C3AED);
      case ProductCategory.sports:
        return const Color(0xFF059669);
      case ProductCategory.toys:
        return const Color(0xFFDC2626);
      case ProductCategory.home:
        return const Color(0xFF0284C7);
      case ProductCategory.fashion:
        return const Color(0xFFDB2777);
      case ProductCategory.other:
        return const Color(0xFF64748B);
    }
  }

  IconData _categoryIcon(ProductCategory cat) {
    switch (cat) {
      case ProductCategory.electronics:
        return Icons.devices_rounded;
      case ProductCategory.clothing:
        return Icons.checkroom_rounded;
      case ProductCategory.furniture:
        return Icons.chair_rounded;
      case ProductCategory.books:
        return Icons.menu_book_rounded;
      case ProductCategory.sports:
        return Icons.sports_soccer_rounded;
      case ProductCategory.toys:
        return Icons.toys_rounded;
      case ProductCategory.home:
        return Icons.home_rounded;
      case ProductCategory.fashion:
        return Icons.style_rounded;
      case ProductCategory.other:
        return Icons.category_rounded;
    }
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  // ── Build ────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final productAsync   = ref.watch(productByIdProvider(widget.productId));
    final authState       = ref.watch(authStateProvider);
    final currentUserId   = authState.value?.uid;
    // Watch saved-item IDs so heart updates instantly across screens
    final savedIds = currentUserId != null
        ? ref.watch(savedIdsProvider(currentUserId)).value ?? const <String>{}
        : const <String>{};

    return Scaffold(
      backgroundColor: _background,
      body: productAsync.when(
        data: (product) {
          if (product == null) return _buildNotFound();
          final isLiked = product.likes.contains(currentUserId);
          final isSaved = savedIds.contains(product.id);
          return _buildProductView(product, isLiked, isSaved, currentUserId);
        },
        loading: _buildLoading,
        error: (e, _) => _buildError(e.toString()),
      ),
    );
  }

  // ── Main product view ────────────────────────────────────────────────────────
  Widget _buildProductView(
    ProductModel product,
    bool isLiked,
    bool isSaved,
    String? currentUserId,
  ) {
    return CustomScrollView(
      slivers: [
        // ── Hero SliverAppBar ─────────────────────────────────────────────────
        SliverAppBar(
          expandedHeight: 320,
          pinned: true,
          stretch: true,
          backgroundColor: _primaryDark,
          automaticallyImplyLeading: false,
          leading: _appBarButton(
            icon: Icons.arrow_back_rounded,
            onTap: () => Navigator.pop(context),
          ),
          actions: [
            // Share
            _appBarButton(
              icon: Icons.share_rounded,
              onTap: () => Share.share(
                'Check out "${product.title}" on QuickSell!\n'
                'Price: \$${product.price.toStringAsFixed(2)}\n'
                'Location: ${product.location}',
              ),
            ),
            // Save / Bookmark
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: GestureDetector(
                onTap: () => _handleToggleSave(product, currentUserId),
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.white.withOpacity(0.9),
                  child: _isSaveLoading
                      ? const SizedBox(
                          width: 16, height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Color(0xFF2979FF)))
                      : Icon(
                          isSaved
                              ? Icons.bookmark_rounded
                              : Icons.bookmark_outline_rounded,
                          size: 22,
                          color: isSaved
                              ? const Color(0xFF2979FF)
                              : const Color(0xFF667085),
                        ),
                ),
              ),
            ),
            // Like
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: GestureDetector(
                onTap: () => _handleToggleLike(product.id, currentUserId),
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.white.withOpacity(0.9),
                  child: _isLikeLoading
                      ? const SizedBox(
                          width: 16, height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Color(0xFFDC2626)))
                      : Icon(
                          isLiked
                              ? Icons.favorite_rounded
                              : Icons.favorite_outline_rounded,
                          size: 22,
                          color: isLiked
                              ? const Color(0xFFDC2626)
                              : const Color(0xFF667085),
                        ),
                ),
              ),
            ),
            // More options (Report)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => _showMoreOptions(product, currentUserId),
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.white.withOpacity(0.9),
                  child: const Icon(Icons.more_vert_rounded,
                      color: Color(0xFF667085), size: 22),
                ),
              ),
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                // ── Image PageView ──────────────────────────────────────────
                PageView(
                  onPageChanged: (i) =>
                      setState(() => _selectedImageIndex = i),
                  children: product.imageUrls.isNotEmpty
                      ? product.imageUrls
                          .map(
                            (url) => Image.network(
                              url,
                              fit: BoxFit.cover,
                              loadingBuilder: (ctx, child, progress) {
                                if (progress == null) return child;
                                return Container(
                                  color: _categoryTint(product.category),
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      color: Color(0xFF2979FF),
                                      strokeWidth: 2,
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (_, __, ___) =>
                                  _imagePlaceholder(product.category),
                            ),
                          )
                          .toList()
                      : [_imagePlaceholder(product.category)],
                ),
                // ── Page indicator dots ─────────────────────────────────────
                if (product.imageUrls.length > 1)
                  Positioned(
                    bottom: 16,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(product.imageUrls.length, (i) {
                        final active = i == _selectedImageIndex;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          width: active ? 20 : 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          decoration: BoxDecoration(
                            color: active
                                ? Colors.white
                                : Colors.white.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),
                  ),
                // ── Gradient overlay for AppBar readability ─────────────────
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.3),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Content ──────────────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title + price
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        product.title,
                        style: GoogleFonts.outfit(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: _textPrimary,
                          height: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style: GoogleFonts.outfit(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: _primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Tags row: category + condition + views
                Row(
                  children: [
                    _chip(
                      _capitalize(product.category.name),
                      _primary.withOpacity(0.1),
                      _primary,
                    ),
                    const SizedBox(width: 8),
                    _chip(
                      _conditionLabel(product.condition),
                      _conditionColor(product.condition).withOpacity(0.1),
                      _conditionColor(product.condition),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.visibility_outlined,
                      size: 14,
                      color: Color(0xFF667085),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${product.views} views',
                      style: GoogleFonts.inter(
                          fontSize: 12, color: _textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Location pill
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: _inputFill,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on_rounded,
                          color: _primary, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          product.location,
                          style: GoogleFonts.inter(
                              fontSize: 14, color: _textPrimary),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Description
                Text(
                  'Description',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: _textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  product.description,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: _textSecondary,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 24),

                // Seller card
                _buildSellerCard(product, currentUserId),
                const SizedBox(height: 24),

                // CTA button(s)
                _buildActionButtons(product, currentUserId),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Seller card ──────────────────────────────────────────────────────────────
  Widget _buildSellerCard(ProductModel product, String? currentUserId) {
    final shortId =
        product.sellerId.substring(0, min(8, product.sellerId.length));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A101828),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          const CircleAvatar(
            radius: 28,
            backgroundColor: Color(0xFFEAF1FF),
            child: Icon(Icons.person_rounded,
                color: Color(0xFF2979FF), size: 32),
          ),
          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Seller',
                  style: GoogleFonts.inter(
                      fontSize: 12, color: _textSecondary),
                ),
                const SizedBox(height: 2),
                Text(
                  '$shortId...',
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: _textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star_rounded,
                        size: 14, color: Color(0xFFD97706)),
                    const SizedBox(width: 4),
                    Text(
                      'Verified Seller',
                      style: GoogleFonts.inter(
                          fontSize: 12, color: _textSecondary),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Message icon — only for other users
          if (currentUserId != null && currentUserId != product.sellerId)
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFFEAF1FF),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.message_rounded,
                    color: Color(0xFF2979FF)),
                onPressed: () =>
                    _handleContactSeller(product, currentUserId),
              ),
            ),
        ],
      ),
    );
  }

  // ── Action buttons ───────────────────────────────────────────────────────────────
  Widget _buildActionButtons(ProductModel product, String? currentUserId) {
    if (currentUserId == null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: _inputFill,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline_rounded, color: _primary, size: 18),
            const SizedBox(width: 8),
            Text(
              'Sign in to contact the seller',
              style: GoogleFonts.inter(
                  fontSize: 14, color: _textSecondary,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
    }

    if (currentUserId == product.sellerId) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: _inputFill,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.store_rounded, color: _primary, size: 18),
            const SizedBox(width: 8),
            Text('This is your listing',
                style: GoogleFonts.inter(
                    fontSize: 14, color: _textSecondary,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      );
    }

    // Buyer: Contact Seller + Make an Offer side by side
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: SizedBox(
            height: 54,
            child: ElevatedButton.icon(
              onPressed: () =>
                  _handleContactSeller(product, currentUserId),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              icon: const Icon(Icons.chat_bubble_rounded, size: 18),
              label: Text('Contact Seller',
                  style: GoogleFonts.outfit(
                      fontSize: 14, fontWeight: FontWeight.w600)),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 2,
          child: SizedBox(
            height: 54,
            child: OutlinedButton.icon(
              onPressed: () =>
                  _showMakeOfferSheet(product, currentUserId),
              style: OutlinedButton.styleFrom(
                foregroundColor: _primary,
                side: const BorderSide(color: _primary, width: 1.5),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              icon: const Icon(Icons.local_offer_rounded, size: 16),
              label: Text('Offer',
                  style: GoogleFonts.outfit(
                      fontSize: 14, fontWeight: FontWeight.w600)),
            ),
          ),
        ),
      ],
    );
  }

  // ── Handlers ────────────────────────────────────────────────────────────────────
  Future<void> _handleToggleSave(
      ProductModel product, String? userId) async {
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign in to save items')),
      );
      return;
    }
    setState(() => _isSaveLoading = true);
    try {
      await FirebaseSavedItemsService().toggleSaved(userId, product);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not update saved: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaveLoading = false);
    }
  }

  Future<void> _handleToggleLike(
      String productId, String? userId) async {
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to like items')),
      );
      return;
    }
    setState(() => _isLikeLoading = true);
    try {
      await FirebaseProductService().toggleLike(productId, userId);
      // Stream auto-updates via productByIdProvider — no manual setState needed.
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not update like: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLikeLoading = false);
    }
  }

  Future<void> _handleContactSeller(
      ProductModel product, String currentUserId) async {
    if (currentUserId == product.sellerId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This is your own product')),
      );
      return;
    }
    try {
      final chatService = FirebaseChatService();
      final conversationId = await chatService.getOrCreateConversation(
        currentUserId,
        product.sellerId,
        product.id,
      );
      if (mounted) {
        Navigator.pushNamed(
          context,
          AppRoutes.chat,
          arguments: {
            'conversationId': conversationId,
            'receiverId': product.sellerId,
            'receiverName': 'Seller',
          },
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open chat: $e')),
        );
      }
    }
  }

  // ── Make Offer sheet ────────────────────────────────────────────────────────────
  void _showMakeOfferSheet(ProductModel product, String buyerId) {
    final priceCtrl   = TextEditingController(
        text: (product.price * 0.85).toStringAsFixed(2));
    final messageCtrl = TextEditingController();
    bool sending = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFFF2F5FB),
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.circular(2))),
                ),
                const SizedBox(height: 20),
                Text('Make an Offer',
                    style: GoogleFonts.outfit(
                        fontSize: 20, fontWeight: FontWeight.w700,
                        color: _textPrimary)),
                const SizedBox(height: 4),
                Text(
                  'Listed at \$${product.price.toStringAsFixed(2)}',
                  style: GoogleFonts.inter(
                      fontSize: 13, color: _textSecondary),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: priceCtrl,
                  keyboardType: TextInputType.number,
                  style: GoogleFonts.inter(fontSize: 14, color: _textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Your offer price',
                    prefixIcon: const Icon(Icons.attach_money_rounded,
                        color: Color(0xFF667085), size: 20),
                    filled: true,
                    fillColor: const Color(0xFFEAF1FF),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                            color: Color(0xFFE4EAF3), width: 1.5)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                            color: Color(0xFF2979FF), width: 2)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: messageCtrl,
                  maxLines: 2,
                  style: GoogleFonts.inter(fontSize: 14, color: _textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Add a message (optional)',
                    filled: true,
                    fillColor: const Color(0xFFEAF1FF),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                            color: Color(0xFFE4EAF3), width: 1.5)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                            color: Color(0xFF2979FF), width: 2)),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: sending
                        ? null
                        : () async {
                            final offerPrice = double.tryParse(
                                priceCtrl.text.trim());
                            if (offerPrice == null || offerPrice <= 0) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Enter a valid price')));
                              return;
                            }
                            if (offerPrice >= product.price) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Offer must be below listed price')));
                              return;
                            }
                            setSheetState(() => sending = true);
                            try {
                              await FirebaseOfferService().createBuyerOffer(
                                product: product,
                                buyerId: buyerId,
                                offerPrice: offerPrice,
                                message: messageCtrl.text.trim().isEmpty
                                    ? null
                                    : messageCtrl.text.trim(),
                              );
                              if (mounted) {
                                Navigator.pop(ctx);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('Offer sent to seller!')));
                                final convId = await FirebaseChatService()
                                    .getOrCreateConversation(
                                        buyerId, product.sellerId,
                                        product.id);
                                if (mounted) {
                                  Navigator.pushNamed(
                                    context, AppRoutes.chat,
                                    arguments: {
                                      'conversationId': convId,
                                      'receiverId': product.sellerId,
                                      'receiverName': 'Seller',
                                    },
                                  );
                                }
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error: $e')));
                              }
                            } finally {
                              setSheetState(() => sending = false);
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: sending
                        ? const SizedBox(
                            width: 20, height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : Text('Send Offer',
                            style: GoogleFonts.outfit(
                                fontSize: 15,
                                fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── More / Report ────────────────────────────────────────────────────────
  void _showMoreOptions(ProductModel product, String? uid) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF2F5FB),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 20),
            if (uid != null && uid != product.sellerId)
              ListTile(
                leading: const Icon(Icons.flag_outlined,
                    color: Color(0xFFDC2626)),
                title: Text('Report this listing',
                    style: GoogleFonts.outfit(
                        fontSize: 15, fontWeight: FontWeight.w600,
                        color: const Color(0xFFDC2626))),
                onTap: () {
                  Navigator.pop(ctx);
                  _showReportSheet(product, uid);
                },
              )
            else
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text('No additional options.',
                    style: GoogleFonts.inter(
                        fontSize: 14,
                        color: const Color(0xFF667085))),
              ),
          ],
        ),
      ),
    );
  }

  void _showReportSheet(ProductModel product, String reporterId) {
    ReportReason selected = ReportReason.scam;
    final detailsCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFFF2F5FB),
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.circular(2))),
                ),
                const SizedBox(height: 20),
                Text('Report Listing',
                    style: GoogleFonts.outfit(
                        fontSize: 20, fontWeight: FontWeight.w700,
                        color: _textPrimary)),
                const SizedBox(height: 4),
                Text('Choose a reason',
                    style: GoogleFonts.inter(
                        fontSize: 13, color: _textSecondary)),
                const SizedBox(height: 8),
                ...ReportReason.values.map((r) =>
                  RadioListTile<ReportReason>(
                    dense: true,
                    activeColor: _primary,
                    value: r,
                    groupValue: selected,
                    onChanged: (v) =>
                        setSheet(() => selected = v ?? r),
                    title: Text(_reasonLabel(r),
                        style: GoogleFonts.inter(
                            fontSize: 14, color: _textPrimary)),
                  )),
                const SizedBox(height: 8),
                TextField(
                  controller: detailsCtrl,
                  maxLines: 2,
                  style: GoogleFonts.inter(
                      fontSize: 14, color: _textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Additional details (optional)',
                    filled: true,
                    fillColor: const Color(0xFFEAF1FF),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                            color: Color(0xFFE4EAF3), width: 1.5)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                            color: Color(0xFF2979FF), width: 2)),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        await FirebaseReportService().reportProduct(
                          ReportModel(
                            id: '',
                            productId: product.id,
                            reporterId: reporterId,
                            reason: selected,
                            details: detailsCtrl.text.trim(),
                            createdAt: DateTime.now(),
                          ),
                        );
                        if (mounted) {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'Report submitted. Thank you!')));
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('Error: $e')));
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDC2626),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text('Submit Report',
                        style: GoogleFonts.outfit(
                            fontSize: 15,
                            fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _reasonLabel(ReportReason r) {
    switch (r) {
      case ReportReason.scam:           return 'Scam or fraud';
      case ReportReason.prohibitedItem: return 'Prohibited item';
      case ReportReason.offensive:      return 'Offensive content';
      case ReportReason.duplicate:      return 'Duplicate listing';
      case ReportReason.other:          return 'Other';
    }
  }

  // ── Helper widgets ──────────────────────────────────────────────────────
  Widget _appBarButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: GestureDetector(
        onTap: onTap,
        child: CircleAvatar(
          radius: 20,
          backgroundColor: Colors.white.withOpacity(0.9),
          child: Icon(icon, color: _textPrimary, size: 20),
        ),
      ),
    );
  }

  Widget _chip(String label, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GoogleFonts.outfit(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Widget _imagePlaceholder(ProductCategory category) {
    return Container(
      color: _categoryTint(category),
      child: Center(
        child: Icon(
          _categoryIcon(category),
          size: 64,
          color: _categoryIconColor(category).withOpacity(0.5),
        ),
      ),
    );
  }

  // ── Loading / error / not-found scaffolds ────────────────────────────────────
  Widget _buildLoading() {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _primaryDark,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: const Center(
        child: CircularProgressIndicator(color: Color(0xFF2979FF)),
      ),
    );
  }

  Widget _buildError(String message) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _primaryDark,
        foregroundColor: Colors.white,
        title: Text(
          'Error',
          style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded,
                  color: Color(0xFFDC2626), size: 56),
              const SizedBox(height: 16),
              Text(
                'Something went wrong',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: _textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: GoogleFonts.inter(
                    fontSize: 14, color: _textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  'Go back',
                  style: GoogleFonts.outfit(
                      fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotFound() {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _primaryDark,
        foregroundColor: Colors.white,
        title: Text(
          'Product',
          style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.search_off_rounded,
                  color: Color(0xFF667085), size: 56),
              const SizedBox(height: 16),
              Text(
                'Product not found',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: _textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'This listing may have been removed.',
                style: GoogleFonts.inter(
                    fontSize: 14, color: _textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  'Go back',
                  style: GoogleFonts.outfit(
                      fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
