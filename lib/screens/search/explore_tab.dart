import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/theme/app_theme.dart';
import '../../widgets/aether_ui_widgets.dart';
import '../../models/product_model.dart';

class ExploreTab extends ConsumerStatefulWidget {
  const ExploreTab({Key? key}) : super(key: key);

  @override
  ConsumerState<ExploreTab> createState() => _ExploreTabState();
}

class _ExploreTabState extends ConsumerState<ExploreTab> {
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _exploreCategories = [
    {
      'title': 'Electronics',
      'subtitle': '2,341 items',
      'icon': Icons.devices_rounded,
      'color': AppTheme.categoryElectronicsTint,
      'category': ProductCategory.electronics,
    },
    {
      'title': 'Fashion & Clothing',
      'subtitle': '5,672 items',
      'icon': Icons.checkroom_rounded,
      'color': AppTheme.categoryAccessoriesTint,
      'category': ProductCategory.fashion,
    },
    {
      'title': 'Home & Garden',
      'subtitle': '1,234 items',
      'icon': Icons.home_rounded,
      'color': AppTheme.categoryComputersTint,
      'category': ProductCategory.home,
    },
    {
      'title': 'Sports & Outdoors',
      'subtitle': '890 items',
      'icon': Icons.sports_basketball_rounded,
      'color': AppTheme.categoryPhonesTint,
      'category': ProductCategory.sports,
    },
    {
      'title': 'Books & Media',
      'subtitle': '456 items',
      'icon': Icons.book_rounded,
      'color': AppTheme.categoryOthersTint,
      'category': ProductCategory.books,
    },
    {
      'title': 'Toys & Hobbies',
      'subtitle': '678 items',
      'icon': Icons.toys_rounded,
      'color': AppTheme.categoryAccessoriesTint,
      'category': ProductCategory.toys,
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(),
          _buildSearchBar(),
          _buildSectionHeader('Browse Categories'),
          _buildCategoriesGrid(),
          _buildSectionHeader('Trending Searches'),
          _buildTrendingTags(),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 100,
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Explore',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimaryColor,
                    ),
                  ),
                  Text(
                    'Discover new items',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.explore_rounded,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
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
          hintText: 'Search categories, items...',
          onChanged: (value) {
            // Implement search
          },
        ),
      ).animate().fadeIn(delay: 100.ms).slideY(begin: -0.1, end: 0),
    );
  }

  Widget _buildSectionHeader(String title) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
        child: Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimaryColor,
          ),
        ),
      ).animate().fadeIn(delay: 200.ms),
    );
  }

  Widget _buildCategoriesGrid() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.3,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        delegate: SliverChildBuilderDelegate((context, index) {
          final category = _exploreCategories[index];
          return StaggeredGridItem(
            index: index,
            delay: 60,
            child: _buildCategoryCard(category),
          );
        }, childCount: _exploreCategories.length),
      ),
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> category) {
    return GestureDetector(
      onTap: () {
        // Navigate to category products
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              category['color'].withOpacity(0.8),
              category['color'].withOpacity(0.5),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: category['color'].withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background decoration
            Positioned(
              right: -20,
              bottom: -20,
              child: Icon(
                category['icon'],
                size: 100,
                color: Colors.white.withOpacity(0.2),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Icon(
                      category['icon'],
                      color: category['color'],
                      size: 24,
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category['title'],
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimaryColor,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        category['subtitle'],
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondaryColor,
                          fontWeight: FontWeight.w500,
                        ),
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

  Widget _buildTrendingTags() {
    final tags = [
      'iPhone',
      'Laptops',
      'Furniture',
      'Books',
      'Gaming',
      'Cameras',
      'Shoes',
      'Watches',
    ];

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Wrap(
          spacing: 10,
          runSpacing: 10,
          children: tags.asMap().entries.map((entry) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppTheme.primaryColor.withOpacity(0.2),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.trending_up_rounded,
                    size: 16,
                    color: AppTheme.primaryColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    entry.value,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textPrimaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: (300 + entry.key * 50).ms).scale();
          }).toList(),
        ),
      ),
    );
  }
}
