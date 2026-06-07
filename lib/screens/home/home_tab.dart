import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../config/theme/app_theme.dart';
import '../../widgets/aether_ui_widgets.dart';
import '../../providers/product_provider.dart';
import '../../models/product_model.dart';
import '../product/product_detail_screen.dart';
import '../search/search_screen.dart';

class HomeTab extends ConsumerStatefulWidget {
  const HomeTab({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends ConsumerState<HomeTab> {
  final TextEditingController _searchController = TextEditingController();
  ProductCategory? _selectedCategory;

  final List<Map<String, dynamic>> _categories = [
    {'name': 'All', 'icon': Icons.apps_rounded, 'value': null},
    {
      'name': 'Phones',
      'icon': Icons.smartphone_rounded,
      'value': ProductCategory.electronics,
    },
    {
      'name': 'Electronics',
      'icon': Icons.devices_rounded,
      'value': ProductCategory.electronics,
    },
    {
      'name': 'Fashion',
      'icon': Icons.checkroom_rounded,
      'value': ProductCategory.fashion,
    },
    {'name': 'Home', 'icon': Icons.home_rounded, 'value': ProductCategory.home},
    {
      'name': 'Sports',
      'icon': Icons.sports_basketball_rounded,
      'value': ProductCategory.sports,
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = _selectedCategory == null
        ? ref.watch(allProductsProvider)
        : ref.watch(productsByCategoryProvider(_selectedCategory!.name));

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(context),
          _buildSearchBar(),
          _buildCategoriesRow(),
          _buildProductsHeader(),
          _buildProductsGrid(productsAsync),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: AppTheme.surfaceColor,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(gradient: AppTheme.aetherGradient),
          padding: const EdgeInsets.only(
            top: 50,
            left: 20,
            right: 20,
            bottom: 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryColor.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.shopping_bag_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'QuickSell',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: AppTheme.textPrimaryColor,
                              ),
                        ),
                        Text(
                          'Find what you need',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppTheme.textSecondaryColor),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.notifications_rounded),
                    onPressed: () {},
                    color: AppTheme.textPrimaryColor,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildSearchBar() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: AnimatedSearchBar(
          controller: _searchController,
          hintText: 'Search products...',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SearchScreen()),
            );
          },
        ),
      ).animate().fadeIn(delay: 100.ms).slideY(begin: -0.1, end: 0),
    );
  }

  Widget _buildCategoriesRow() {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 50,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: _categories.length,
          itemBuilder: (context, index) {
            final category = _categories[index];
            final isSelected = _selectedCategory == category['value'];

            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: CategoryChip(
                label: category['name'],
                isSelected: isSelected,
                onTap: () {
                  setState(() {
                    _selectedCategory = category['value'];
                  });
                },
                tintColor: AppTheme.getCategoryTint(category['name']),
              ),
            ).animate().fadeIn(delay: (200 + index * 50).ms).scale();
          },
        ),
      ),
    );
  }

  Widget _buildProductsHeader() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _selectedCategory == null ? 'Latest Items' : 'Filtered Results',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimaryColor,
              ),
            ),
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.tune_rounded, size: 18),
              label: const Text('Filter'),
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.primaryColor,
              ),
            ),
          ],
        ),
      ).animate().fadeIn(delay: 300.ms),
    );
  }

  Widget _buildProductsGrid(AsyncValue<List<Product>> productsAsync) {
    return productsAsync.when(
      data: (products) {
        if (products.isEmpty) {
          return SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 80,
                    color: AppTheme.textSecondaryColor.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No products found',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            delegate: SliverChildBuilderDelegate((context, index) {
              final product = products[index];
              return StaggeredGridItem(
                index: index,
                delay: 60,
                child: _buildProductCard(product),
              );
            }, childCount: products.length),
          ),
        );
      },
      loading: () => SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) => _buildLoadingCard(),
            childCount: 6,
          ),
        ),
      ),
      error: (error, stack) => SliverFillRemaining(
        child: Center(child: Text('Error: ${error.toString()}')),
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    final categoryTint = AppTheme.getCategoryTint(product.category.name);

    return TiltCard(
      categoryTintColor: categoryTint,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(productId: product.id),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  Hero(
                    tag: 'product-${product.id}',
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                        color: categoryTint.withOpacity(0.2),
                      ),
                      child: product.images.isNotEmpty
                          ? ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(16),
                              ),
                              child: CachedNetworkImage(
                                imageUrl: product.images.first,
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                            )
                          : const Center(
                              child: Icon(
                                Icons.image_not_supported_rounded,
                                size: 48,
                                color: AppTheme.textSecondaryColor,
                              ),
                            ),
                    ),
                  ),
                  // Favorite button
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.favorite_border_rounded),
                        iconSize: 20,
                        padding: const EdgeInsets.all(8),
                        onPressed: () {},
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Product Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimaryColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    PriceBadge(
                      price: '\$${product.price.toStringAsFixed(2)}',
                      isNegotiable: false,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.inputFillColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 16,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppTheme.inputFillColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 16,
                    width: 100,
                    decoration: BoxDecoration(
                      color: AppTheme.inputFillColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    height: 24,
                    width: 80,
                    decoration: BoxDecoration(
                      color: AppTheme.inputFillColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
