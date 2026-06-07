import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/firebase_auth_service.dart';
import '../../services/firebase_product_service.dart';
import '../../routes/app_routes.dart';
import '../../models/product_model.dart';
import '../../models/transaction_model.dart';
import '../../config/theme/theme_colors.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final FirebaseAuthService _authService = FirebaseAuthService();
  final FirebaseProductService _productService = FirebaseProductService();


  Color get _bg            => TC.bg(context);
  Color get _surface       => TC.surface(context);
  Color get _card          => TC.card(context);
  Color get _inputFill     => TC.inputFill(context);
  Color get _border        => TC.border(context);
  Color get _textPrimary   => TC.textPrimary(context);
  Color get _textSecondary => TC.textSecondary(context);
  Color get _textHint      => TC.textHint(context);
  static const _primary      = TC.primary;
  static const _error        = TC.error;
  static const _success      = TC.success;
  static const _successLight = TC.successLight;
  static const _errorLight   = TC.errorLight;
  static const _cardShadow   = TC.cardShadow;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) {
        if (user == null) return _buildSignedOut();
        final listingsAsync = ref.watch(productsBySellerProvider(user.uid));
        return _buildProfile(user, listingsAsync);
      },
      loading: () => Scaffold(
        backgroundColor: _bg,
        body: const Center(
          child: CircularProgressIndicator(color: TC.primary),
        ),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: _bg,
        body: Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildSignedOut() {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _primary,
        title: Text(
          'Profile',
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 48,
              backgroundColor: _inputFill,
              child: const Icon(
                Icons.person_outline_rounded,
                size: 56,
                color: TC.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Sign in to your account',
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: _textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'View your listings, messages, and more',
              style: GoogleFonts.inter(fontSize: 14, color: _textSecondary),
            ),
            const SizedBox(height: 28),
            ElevatedButton(
              onPressed: () =>
                  Navigator.pushReplacementNamed(context, AppRoutes.login),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 14,
                ),
              ),
              child: Text(
                'Sign In',
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfile(
    User user,
    AsyncValue<List<ProductModel>> listingsAsync,
  ) {
    return Scaffold(
      backgroundColor: _bg,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: _primary,
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_rounded, color: Colors.white),
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Settings coming soon')),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF2979FF), Color(0xFF1A5FCC)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 16),
                      const CircleAvatar(
                        radius: 44,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 40,
                          backgroundColor: Color(0xFFEAF1FF),
                          child: Icon(
                            Icons.person_rounded,
                            size: 52,
                            color: Color(0xFF2979FF),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        user.displayName ?? 'User',
                        style: GoogleFonts.outfit(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email ?? '',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 20),
                      listingsAsync.when(
                        data: (listings) => Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _statCard('${listings.length}', 'Listings'),
                            _statCard(
                              '${listings.where((p) => p.status == ProductStatus.sold).length}',
                              'Sold',
                            ),
                            _statCard(
                              '${listings.fold<int>(0, (sum, p) => sum + p.likes.length)}',
                              'Likes',
                            ),
                          ],
                        ),
                        loading: () => const SizedBox(height: 48),
                        error: (_, __) => const SizedBox(height: 48),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 16),
              _buildMenuSection(user, listingsAsync),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statCard(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 12, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(
    User user,
    AsyncValue<List<ProductModel>> listingsAsync,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'My Listings',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          listingsAsync.when(
            data: (listings) {
              if (listings.isEmpty) return _buildNoListings();
              return Column(
                children:
                    listings.map((p) => _buildListingCard(p)).toList(),
              );
            },
            loading: () => const Center(
                child: CircularProgressIndicator(color: TC.primary),
              ),
              error: (e, _) => Text(
                'Error loading listings: $e',
              style: GoogleFonts.inter(fontSize: 13, color: _error),
            ),
          ),
          const SizedBox(height: 24),
          Divider(color: _border),
          const SizedBox(height: 16),
          Text(
            'Account',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _menuItem(
            Icons.favorite_rounded,
            'Saved Items',
            () => Navigator.pushNamed(context, AppRoutes.savedItems),
          ),
          const SizedBox(height: 8),
          _menuItem(
            Icons.history_rounded,
            'Purchase History',
            () => _showPurchaseHistory(user.uid),
          ),
          const SizedBox(height: 8),
          _menuItem(
            Icons.info_outline_rounded,
            'About QuickSell',
            _showAbout,
          ),
          const SizedBox(height: 12),
          // Dark Mode toggle
          _darkModeToggle(),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _handleLogout,
              style: OutlinedButton.styleFrom(
                foregroundColor: _error,
                side: BorderSide(color: _error.withOpacity(0.5)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              icon: const Icon(Icons.logout_rounded, size: 20),
              label: Text(
                'Log Out',
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildListingCard(ProductModel product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
        boxShadow: const [
          BoxShadow(color: _cardShadow, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: 64,
            height: 64,
            color: _inputFill,
            child: product.imageUrls.isNotEmpty
                ? Image.network(
                    product.imageUrls[0],
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Icon(
                                Icons.image_not_supported_outlined,
                                color: _textHint,
                              ),
                  )
                : Icon(
                    Icons.image_not_supported_outlined,
                    color: _textHint,
                  ),
          ),
        ),
        title: Text(
          product.title,
          style: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: _textPrimary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '\$${product.price.toStringAsFixed(2)}',
              style: GoogleFonts.outfit(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: _primary,
              ),
            ),
            const SizedBox(height: 2),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: product.status == ProductStatus.available
                    ? _successLight
                    : _errorLight,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                product.status == ProductStatus.available
                    ? 'Active'
                    : product.status.name,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: product.status == ProductStatus.available
                      ? _success
                      : _error,
                ),
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: Icon(Icons.more_vert_rounded, color: _textSecondary),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          onSelected: (value) async {
            if (value == 'view') {
              Navigator.pushNamed(context, AppRoutes.productDetail,
                  arguments: product.id);
            } else if (value == 'edit') {
              Navigator.pushNamed(context, AppRoutes.editProduct,
                  arguments: product);
            } else if (value == 'offer') {
              Navigator.pushNamed(context, AppRoutes.sellerOffer,
                  arguments: product);
            } else if (value == 'sold') {
              await _markAsSold(product.id);
            } else if (value == 'delete') {
              _confirmDelete(product);
            }
          },
          itemBuilder: (_) => [
            _popItem('view', Icons.open_in_new_rounded,   'View',          const Color(0xFF2979FF)),
            _popItem('edit', Icons.edit_rounded,           'Edit',          const Color(0xFF0284C7)),
            _popItem('offer',Icons.local_offer_rounded,   'Send Discount', const Color(0xFF7C3AED)),
            _popItem('sold', Icons.check_circle_outline_rounded, 'Mark as Sold', const Color(0xFF059669)),
            _popItem('delete',Icons.delete_outline_rounded,'Delete',        const Color(0xFFDC2626)),
          ],
        ),
        onTap: () => Navigator.pushNamed(
          context,
          AppRoutes.productDetail,
          arguments: product.id,
        ),
      ),
    );
  }

  Widget _buildNoListings() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 56,
            color: _primary.withOpacity(0.3),
          ),
          const SizedBox(height: 12),
          Text(
            'No listings yet',
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tap "Sell" to post your first item',
            style: GoogleFonts.inter(fontSize: 13, color: _textSecondary),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.createProduct),
            style: ElevatedButton.styleFrom(
              backgroundColor: _primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: Text(
              'Post a Listing',
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuItem(IconData icon, String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _border),
        ),
        child: Row(
          children: [
            Icon(icon, color: _primary, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _textPrimary,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: _textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  // ── Pop-up menu item helper ───────────────────────────────────────────────
  PopupMenuItem<String> _popItem(
      String value, IconData icon, String label, Color color) {
    return PopupMenuItem(
      value: value,
      child: Row(children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
      ]),
    );
  }

  // ── Dark mode toggle ─────────────────────────────────────────────────────
  Widget _darkModeToggle() {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
      ),
      child: Row(children: [
        Icon(isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
            color: _primary, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Text('Dark Mode',
              style: GoogleFonts.outfit(
                  fontSize: 14, fontWeight: FontWeight.w600,
                  color: _textPrimary)),
        ),
        Switch(
          value: isDark,
          activeColor: _primary,
          onChanged: (_) => ref.read(themeProvider.notifier).toggle(),
        ),
      ]),
    );
  }

  // ── Purchase History bottom sheet ────────────────────────────────────────
  void _showPurchaseHistory(String userId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.70,
        minChildSize: 0.40,
        maxChildSize: 0.92,
        builder: (_, ctrl) => Container(
          decoration: BoxDecoration(
            color: TC.bg(context),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Center(
                child: Container(width: 40, height: 4,
                    decoration: BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.circular(2))),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text('Purchase History',
                    style: GoogleFonts.outfit(
                        fontSize: 20, fontWeight: FontWeight.w700,
                        color: _textPrimary)),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Consumer(
                  builder: (_, ref, __) {
                    final txAsync =
                        ref.watch(userTransactionsProvider(userId));
                    return txAsync.when(
                      data: (transactions) {
                        final myBuys = transactions
                            .where((t) => t.buyerId == userId)
                            .toList();
                        if (myBuys.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.receipt_long_rounded,
                                    size: 56,
                                    color: _primary.withOpacity(0.3)),
                                const SizedBox(height: 12),
                                Text('No purchases yet',
                                    style: GoogleFonts.outfit(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: _textPrimary)),
                                const SizedBox(height: 6),
                                Text('Items you buy will appear here',
                                    style: GoogleFonts.inter(
                                        fontSize: 13,
                                        color: _textSecondary)),
                              ],
                            ),
                          );
                        }
                        return ListView.builder(
                          controller: ctrl,
                          padding: const EdgeInsets.all(16),
                          itemCount: myBuys.length,
                          itemBuilder: (_, i) =>
                              _txCard(myBuys[i]),
                        );
                      },
                      loading: () => const Center(
                          child: CircularProgressIndicator(
                              color: TC.primary)),
                      error: (e, _) => Center(
                          child: Text('Error: $e',
                              style: GoogleFonts.inter(
                                  color: _error))),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _txCard(TransactionModel tx) {
    final isCompleted = tx.status == TransactionStatus.completed;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: isCompleted ? _successLight : const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isCompleted
                  ? Icons.check_circle_rounded
                  : Icons.hourglass_top_rounded,
              color: isCompleted ? _success : const Color(0xFFD97706),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tx.productTitle,
                    style: GoogleFonts.outfit(
                        fontSize: 14, fontWeight: FontWeight.w600,
                        color: _textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(
                  isCompleted ? 'Completed' : 'Awaiting confirmation',
                  style: GoogleFonts.inter(
                      fontSize: 12,
                      color: isCompleted ? _success : const Color(0xFFD97706),
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          Text(
            '\$${tx.finalPrice.toStringAsFixed(2)}',
            style: GoogleFonts.outfit(
                fontSize: 15, fontWeight: FontWeight.w700,
                color: _primary),
          ),
        ],
      ),
    );
  }

  // ── About dialog ─────────────────────────────────────────────────────────
  void _showAbout() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: TC.bg(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2979FF), Color(0xFF1A5FCC)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.shopping_bag_rounded,
                  color: Colors.white, size: 40),
            ),
            const SizedBox(height: 16),
            Text('QuickSell',
                style: GoogleFonts.outfit(
                    fontSize: 24, fontWeight: FontWeight.w800,
                    color: _textPrimary)),
            const SizedBox(height: 6),
            Text('Version 1.0.0',
                style: GoogleFonts.inter(fontSize: 13, color: _textSecondary)),
            const SizedBox(height: 16),
            Text(
              'QuickSell is your local marketplace for buying and selling items in your community. Post listings in seconds, chat with buyers and sellers, and discover great deals near you.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                  fontSize: 14, color: _textSecondary, height: 1.6),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _inputFill,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.favorite_rounded,
                      color: Color(0xFF2979FF), size: 16),
                  const SizedBox(width: 8),
                  Text('Made with care for local communities',
                      style: GoogleFonts.inter(
                          fontSize: 13,
                          color: const Color(0xFF2979FF),
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2979FF),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('Close',
                    style: GoogleFonts.outfit(
                        fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Log Out',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w700,
            color: _textPrimary,
          ),
        ),
        content: Text(
          'Are you sure you want to log out?',
          style: GoogleFonts.inter(color: _textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: GoogleFonts.outfit(color: _textSecondary),
            ),
          ),
          TextButton(
            onPressed: () async {
              await _authService.signOut();
              if (mounted) {
                Navigator.pop(ctx);
                Navigator.pushReplacementNamed(context, AppRoutes.login);
              }
            },
            child: Text(
              'Log Out',
              style: GoogleFonts.outfit(
                color: _error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _markAsSold(String productId) async {
    try {
      await _productService.markAsSold(productId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Marked as sold')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _confirmDelete(ProductModel product) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Delete Listing',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Are you sure you want to delete "${product.title}"? This cannot be undone.',
          style: GoogleFonts.inter(color: _textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: GoogleFonts.outfit(color: _textSecondary),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await _productService.deleteProduct(product.id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Listing deleted')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error deleting: $e')),
                  );
                }
              }
            },
            child: Text(
              'Delete',
              style: GoogleFonts.outfit(
                  color: _error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

}
