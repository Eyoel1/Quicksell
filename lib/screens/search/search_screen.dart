import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../routes/app_routes.dart';
import '../../providers/product_provider.dart';
import '../../models/product_model.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late TextEditingController _searchController;
  String _searchQuery = '';

  // ── Colors ────────────────────────────────────────────────────────────────
  static const _surface = Color(0xFFFFFFFF);
  static const _primary = Color(0xFF2979FF);
  static const _textPrimary = Color(0xFF101828);
  static const _textSecondary = Color(0xFF667085);
  static const _inputFill = Color(0xFFEAF1FF);
  static const _cardShadow = Color(0x0A101828);

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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

  // ── Empty search prompt ───────────────────────────────────────────────────
  Widget _buildEmptySearch() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_rounded,
            size: 80,
            color: _primary.withOpacity(0.2),
          ),
          const SizedBox(height: 16),
          Text(
            'Search QuickSell',
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Find phones, laptops, furniture and more',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: _textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ── No results ────────────────────────────────────────────────────────────
  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 80,
            color: _primary.withOpacity(0.2),
          ),
          const SizedBox(height: 16),
          Text(
            'No results found',
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Try a different search term',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: _textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ── Results list ──────────────────────────────────────────────────────────
  Widget _buildResultsList(List<ProductModel> products) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return GestureDetector(
          onTap: () => Navigator.pushNamed(
            context,
            AppRoutes.productDetail,
            arguments: product.id,
          ),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: _cardShadow,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // Image thumbnail
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                  child: Container(
                    width: 100,
                    height: 100,
                    color: _getCategoryTint(product.category),
                    child: product.imageUrls.isNotEmpty
                        ? Image.network(
                            product.imageUrls[0],
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Icon(
                              _getCategoryIcon(product.category),
                              color: _getCategoryIconColor(product.category)
                                  .withOpacity(0.4),
                              size: 36,
                            ),
                          )
                        : Icon(
                            _getCategoryIcon(product.category),
                            color: _getCategoryIconColor(product.category)
                                .withOpacity(0.4),
                            size: 36,
                          ),
                  ),
                ),
                // Info panel
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.title,
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          product.description,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: _textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '\$${product.price.toStringAsFixed(2)}',
                              style: GoogleFonts.outfit(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: _primary,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: _inputFill,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                product.condition.name,
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: _primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final searchResults = ref.watch(searchProductsProvider(_searchQuery));

    return Scaffold(
      backgroundColor: const Color(0xFFF2F5FB),
      appBar: AppBar(
        backgroundColor: _primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: TextField(
          controller: _searchController,
          autofocus: true,
          style: GoogleFonts.inter(color: Colors.white, fontSize: 15),
          cursorColor: Colors.white,
          decoration: InputDecoration(
            hintText: 'Search products...',
            hintStyle:
                GoogleFonts.inter(color: Colors.white60, fontSize: 15),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: EdgeInsets.zero,
            filled: false,
          ),
          onChanged: (v) => setState(() => _searchQuery = v),
        ),
        actions: [
          if (_searchQuery.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close_rounded, color: Colors.white),
              onPressed: () {
                _searchController.clear();
                setState(() => _searchQuery = '');
              },
            ),
        ],
      ),
      body: _searchQuery.isEmpty
          ? _buildEmptySearch()
          : searchResults.when(
              data: (products) => products.isEmpty
                  ? _buildNoResults()
                  : _buildResultsList(products),
              loading: () => const Center(
                child: CircularProgressIndicator(color: _primary),
              ),
              error: (e, _) => Center(
                child: Text(
                  'Error: $e',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: _textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
    );
  }
}
