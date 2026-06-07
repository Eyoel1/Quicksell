import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../providers/saved_items_provider.dart';
import '../../services/firebase_saved_items_service.dart';
import '../../models/product_model.dart';
import '../../routes/app_routes.dart';
import '../../config/theme/theme_colors.dart';

class SavedItemsScreen extends ConsumerWidget {
  const SavedItemsScreen({Key? key}) : super(key: key);

  static const _primary    = TC.primary;
  static const _error      = TC.error;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      backgroundColor: TC.bg(context),
      appBar: AppBar(
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text('Saved Items',
            style: GoogleFonts.outfit(
                fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
      ),
      body: authState.when(
        data: (user) {
          if (user == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.favorite_outline_rounded,
                      size: 72, color: _primary),
                  const SizedBox(height: 16),
                  Text('Sign in to see saved items',
                      style: GoogleFonts.outfit(
                          fontSize: 18, fontWeight: FontWeight.w600,
                          color: TC.textPrimary(context))),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pushReplacementNamed(
                        context, AppRoutes.login),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: _primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12))),
                    child: Text('Sign In',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            );
          }

          final savedAsync = ref.watch(savedProductsProvider(user.uid));
          return savedAsync.when(
            data: (products) {
              if (products.isEmpty) return _buildEmpty(context);
              return _buildGrid(context, ref, user.uid, products);
            },
            loading: () => const Center(
              child: CircularProgressIndicator(color: _primary),
            ),
            error: (e, _) => Center(
              child: Text('Error loading saved items: $e',
                  style: GoogleFonts.inter(color: TC.error)),
            ),
          );
        },
        loading: () =>
            const Center(child: CircularProgressIndicator(color: _primary)),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96, height: 96,
              decoration: BoxDecoration(
                  color: TC.inputFill(context), shape: BoxShape.circle),
              child: const Icon(Icons.favorite_outline_rounded,
                  size: 52, color: TC.primary),
            ),
            const SizedBox(height: 20),
            Text('No saved items yet',
                style: GoogleFonts.outfit(
                    fontSize: 22, fontWeight: FontWeight.w700,
                    color: TC.textPrimary(context))),
            const SizedBox(height: 8),
            Text(
              'Tap the heart icon on any listing to save it here.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                  fontSize: 14, color: TC.textSecondary(context), height: 1.6),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: () => Navigator.pushReplacementNamed(
                  context, AppRoutes.home),
              style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 14)),
              icon: const Icon(Icons.explore_rounded, size: 18),
              label: Text('Browse Listings',
                  style: GoogleFonts.outfit(
                      fontSize: 14, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid(BuildContext context, WidgetRef ref,
      String userId, List<ProductModel> products) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.72,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: products.length,
      itemBuilder: (context, i) {
        final product = products[i];
        return _SavedCard(
          product: product,
          onUnsave: () async {
            await FirebaseSavedItemsService().toggleSaved(userId, product);
          },
        );
      },
    );
  }
}

class _SavedCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onUnsave;

  const _SavedCard({required this.product, required this.onUnsave});

  static const _primary   = TC.primary;
  static const _error     = TC.error;
  static const _cardShadow = TC.cardShadow;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.productDetail,
          arguments: product.id),
      child: Container(
        decoration: BoxDecoration(
          color: TC.card(context),
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
                color: TC.cardShadow, blurRadius: 12, offset: Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with unsave button
            Expanded(
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: TC.inputFill(context),
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(18)),
                      image: product.imageUrls.isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(product.imageUrls.first),
                              fit: BoxFit.cover)
                          : null,
                    ),
                    child: product.imageUrls.isEmpty
                        ? const Center(
                            child: Icon(Icons.image_not_supported_outlined,
                                color: Color(0xFFD1D5DB), size: 36))
                        : null,
                  ),
                  // Price badge
                  Positioned(
                    top: 8, right: 8,
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
                            color: Colors.white),
                      ),
                    ),
                  ),
                  // Unsave button
                  Positioned(
                    top: 8, left: 8,
                    child: GestureDetector(
                      onTap: onUnsave,
                      child: Container(
                        width: 32, height: 32,
                        decoration: BoxDecoration(
                          color: TC.surface(context),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.favorite_rounded,
                            color: _error, size: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Info
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.title,
                      style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: TC.textPrimary(context)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded,
                          size: 11, color: _primary),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(product.location,
                            style: GoogleFonts.inter(
                                fontSize: 11, color: TC.textSecondary(context)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
