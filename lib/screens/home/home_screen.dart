import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../routes/app_routes.dart';
import '../../providers/product_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/saved_items_provider.dart';
import '../../services/firebase_saved_items_service.dart';
import '../../models/product_model.dart';
import '../../config/theme/theme_colors.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;
  ProductCategory? _selectedCategory;
  String? _pressedId;

  // ── Colors ────────────────────────────────────────────────────────────────
  Color get _bg            => TC.bg(context);
  Color get _surface       => TC.surface(context);
  Color get _card          => TC.card(context);
  Color get _border        => TC.border(context);
  Color get _textPrimary   => TC.textPrimary(context);
  Color get _textSecondary => TC.textSecondary(context);
  static const _primary    = TC.primary;
  static const _cardShadow = TC.cardShadow;

  // ── Category helpers ──────────────────────────────────────────────────────
  Color _getCategoryTint(ProductCategory cat) {
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

  IconData _getCategoryIcon(ProductCategory cat) {
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

  Color _getCategoryIconColor(ProductCategory cat) {
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

  // ── Icon button helper ────────────────────────────────────────────────────
  Widget _iconBtn(IconData icon, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.20),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2979FF), Color(0xFF1A5FCC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 56, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'QuickSell',
                style: GoogleFonts.outfit(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              Row(
                children: [
                  _iconBtn(
                    Icons.search_rounded,
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.search),
                  ),
                  const SizedBox(width: 8),
                  _iconBtn(
                    Icons.notifications_none_rounded,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'No new notifications',
                            style: GoogleFonts.inter(color: Colors.white),
                          ),
                          backgroundColor: const Color(0xFF1A5FCC),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Find great deals near you',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  // ── Category chip ─────────────────────────────────────────────────────────
  Widget _buildCategoryChip(
    ProductCategory? category,
    String label,
    IconData icon,
    Color iconColor,
    Color catBgColor,
  ) {
    final isSelected = _selectedCategory == category;

    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = category),
      child: Container(
        width: 80,
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: isSelected ? _primary : _card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? _primary : _border,
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: _primary.withOpacity(0.2),
                    blurRadius: 8,
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withOpacity(0.2)
                    : catBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : iconColor,
                size: 22,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : _textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // ── Category row ──────────────────────────────────────────────────────────
  Widget _buildCategoryRow() {
    return Container(
      color: _surface,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Categories',
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: _textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 100,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildCategoryChip(
                  null,
                  'All',
                  Icons.grid_view_rounded,
                  const Color(0xFF2979FF),
                  const Color(0xFFEAF1FF),
                ),
                ...ProductCategory.values.map((cat) => _buildCategoryChip(
                      cat,
                      cat.name[0].toUpperCase() + cat.name.substring(1),
                      _getCategoryIcon(cat),
                      _getCategoryIconColor(cat),
                      _getCategoryTint(cat),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Product card ──────────────────────────────────────────────────────────
  Widget _buildProductCard(ProductModel product,
      {Set<String> savedIds = const {}, String? userId}) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressedId = product.id),
      onTapUp: (_) {
        setState(() => _pressedId = null);
        Navigator.pushNamed(
          context,
          AppRoutes.productDetail,
          arguments: product.id,
        );
      },
      onTapCancel: () => setState(() => _pressedId = null),
      child: AnimatedScale(
        scale: _pressedId == product.id ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [
              BoxShadow(
                color: _cardShadow,
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image area
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: _getCategoryTint(product.category),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(18),
                        ),
                        image: product.imageUrls.isNotEmpty
                            ? DecorationImage(
                                image:
                                    NetworkImage(product.imageUrls[0]),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: product.imageUrls.isEmpty
                          ? Center(
                              child: Icon(
                                _getCategoryIcon(product.category),
                                size: 40,
                                color: _getCategoryIconColor(product.category)
                                    .withOpacity(0.4),
                              ),
                            )
                          : null,
                    ),
                    // Save / heart button (top-left)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: GestureDetector(
                        onTap: () async {
                          if (userId == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Sign in to save items')));
                            return;
                          }
                          await FirebaseSavedItemsService()
                              .toggleSaved(userId, product);
                        },
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.90),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Icon(
                            savedIds.contains(product.id)
                                ? Icons.favorite_rounded
                                : Icons.favorite_outline_rounded,
                            size: 16,
                            color: savedIds.contains(product.id)
                                ? const Color(0xFFDC2626)
                                : const Color(0xFF667085),
                          ),
                        ),
                      ),
                    ),
                    // Price badge
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _primary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '\$${product.price.toStringAsFixed(0)}',
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Info area
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.title,
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_rounded,
                          size: 11,
                          color: _primary,
                        ),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            product.location,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: _textSecondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _conditionColor(product.condition)
                            .withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _conditionLabel(product.condition),
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: _conditionColor(product.condition),
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

  // ── Grid ──────────────────────────────────────────────────────────────────
  Widget _buildGrid(List<ProductModel> products,
      {Set<String> savedIds = const {}, String? userId}) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.72,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: Duration(milliseconds: 300 + index * 60),
          curve: Curves.easeOut,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: child,
              ),
            );
          },
          child: _buildProductCard(
            products[index],
            savedIds: savedIds,
            userId: userId,
          ),
        );
      },
    );
  }

  // ── Empty state ───────────────────────────────────────────────────────────
  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: 72,
              color: _primary.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No listings yet',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: _textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Be the first to list something!',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: _textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Loading state ─────────────────────────────────────────────────────────
  Widget _buildLoading() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: _primary),
            const SizedBox(height: 16),
            Text(
              'Loading listings...',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: _textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Error state ───────────────────────────────────────────────────────────
  Widget _buildError(String msg) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 72,
              color: const Color(0xFFDC2626).withOpacity(0.4),
            ),
            const SizedBox(height: 16),
            Text(
              'Could not load listings',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: _textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              msg,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: _textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => ref.refresh(allProductsProvider),
              icon: const Icon(Icons.refresh_rounded),
              label: Text(
                'Retry',
                style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Products section ──────────────────────────────────────────────────────
  Widget _buildProductsSection(
    AsyncValue<List<ProductModel>> productsAsync, {
    Set<String> savedIds = const {},
    String? userId,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          productsAsync.when(
            data: (products) => Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Featured Listings',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: _textPrimary,
                  ),
                ),
                if (products.isNotEmpty)
                  Text(
                    '${products.length} items',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: _textSecondary,
                    ),
                  ),
              ],
            ),
            loading: () => Text(
              'Featured Listings',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _textPrimary,
              ),
            ),
            error: (_, __) => Text(
              'Featured Listings',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 12),
          productsAsync.when(
            data: (products) => products.isEmpty
                ? _buildEmpty()
                : _buildGrid(products, savedIds: savedIds, userId: userId),
            loading: () => _buildLoading(),
            error: (e, _) => _buildError(e.toString()),
          ),
        ],
      ),
    );
  }

  // ── Nav item helper ───────────────────────────────────────────────────────
  Widget _navItem(int index, IconData icon, IconData activeIcon,
      String label, int badge) {
    final active = _selectedIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          switch (index) {
            case 0:
              setState(() => _selectedIndex = 0);
              break;
            case 1:
              Navigator.pushNamed(context, AppRoutes.chat)
                  .then((_) => setState(() => _selectedIndex = 0));
              break;
            case 2:
              Navigator.pushNamed(context, AppRoutes.profile)
                  .then((_) => setState(() => _selectedIndex = 0));
              break;
          }
        },
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  active ? activeIcon : icon,
                  color: active ? TC.primary : TC.textSecondary(context),
                  size: 24,
                ),
                if (badge > 0)
                  Positioned(
                    top: -4,
                    right: -6,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        color: TC.error,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          badge > 9 ? '9+' : '$badge',
                          style: GoogleFonts.outfit(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 11,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                color: active ? TC.primary : TC.textSecondary(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final productsAsync = _selectedCategory == null
        ? ref.watch(allProductsProvider)
        : ref.watch(
            productsByCategoryProvider(_selectedCategory!.name),
          );
    // Auth + saved items (for heart button on cards)
    final userId = ref.watch(authStateProvider).value?.uid;
    final savedIds = userId != null
        ? ref.watch(savedIdsProvider(userId)).value ?? const <String>{}
        : const <String>{};
    final msgCount = userId != null
        ? ref.watch(conversationCountProvider(userId)).value ?? 0
        : 0;
    final offerCount = userId != null
        ? ref.watch(pendingOffersCountProvider(userId)).value ?? 0
        : 0;

    return Scaffold(
      backgroundColor: _bg,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader()),
          SliverToBoxAdapter(child: _buildCategoryRow()),
          SliverToBoxAdapter(
            child: _buildProductsSection(
              productsAsync,
              savedIds: savedIds,
              userId: userId,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            Navigator.pushNamed(context, AppRoutes.createProduct),
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.add_rounded, size: 22),
        label: Text(
          'Sell',
          style: GoogleFonts.outfit(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: TC.surface(context),
          border: Border(
            top: BorderSide(color: TC.border(context), width: 0.8),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 60,
            child: Row(
              children: [
                _navItem(0, Icons.home_outlined, Icons.home_rounded, 'Home', 0),
                _navItem(1, Icons.chat_bubble_outline_rounded,
                    Icons.chat_bubble_rounded, 'Messages', msgCount),
                _navItem(2, Icons.person_outline_rounded,
                    Icons.person_rounded, 'Profile', offerCount),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
