import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/aether_ui_widgets.dart';
import '../config/theme/app_theme.dart';
import 'home/home_tab.dart';
import 'search/explore_tab.dart';
import 'profile/saved_items_screen.dart';
import 'profile/profile_screen.dart';
import 'product/create_product_screen.dart';

class MainNavScreen extends ConsumerStatefulWidget {
  const MainNavScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends ConsumerState<MainNavScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeTab(),
    const ExploreTab(),
    const SavedItemsScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onSellPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateProductScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: OrbitBottomNav(
        selectedIndex: _selectedIndex,
        onTap: _onItemTapped,
        floatingActionButton: PulsingSellOrb(onPressed: _onSellPressed),
      ),
    );
  }
}
