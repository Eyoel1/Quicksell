import 'package:flutter/material.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/product/product_detail_screen.dart';
import '../screens/product/create_product_screen.dart';
import '../screens/product/edit_product_screen.dart';
import '../screens/product/seller_offer_screen.dart';
import '../screens/chat/chat_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/profile/saved_items_screen.dart';
import '../screens/search/search_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../models/product_model.dart';

class AppRoutes {
  static const String onboarding    = '/onboarding';
  static const String splash        = '/';
  static const String login         = '/login';
  static const String signup        = '/signup';
  static const String home          = '/home';
  static const String productDetail = '/product-detail';
  static const String createProduct = '/create-product';
  static const String editProduct   = '/edit-product';
  static const String sellerOffer   = '/seller-offer';
  static const String chat          = '/chat';
  static const String profile       = '/profile';
  static const String savedItems    = '/saved-items';
  static const String search        = '/search';

  static final Map<String, WidgetBuilder> routes = {
    login:        (context) => const LoginScreen(),
    signup:       (context) => const SignupScreen(),
    home:         (context) => const HomeScreen(),
    profile:      (context) => const ProfileScreen(),
    createProduct:(context) => const CreateProductScreen(),
    savedItems:   (context) => const SavedItemsScreen(),
    search:       (context) => const SearchScreen(),
    onboarding:   (context) => const OnboardingScreen(),
  };

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case productDetail:
        final productId = settings.arguments as String?;
        return _slide(
          ProductDetailScreen(productId: productId ?? ''),
          settings,
        );

      case editProduct:
        final product = settings.arguments as ProductModel?;
        return _slide(
          EditProductScreen(product: product!),
          settings,
        );

      case sellerOffer:
        final product = settings.arguments as ProductModel?;
        return _slide(
          SellerOfferScreen(product: product!),
          settings,
        );

      case chat:
        final args = settings.arguments as Map<String, dynamic>?;
        return _slide(
          ChatScreen(
            initialConversationId: args?['conversationId'] as String?,
            receiverId:            args?['receiverId']     as String?,
            receiverName:          args?['receiverName']   as String?,
          ),
          settings,
        );

      default:
        return _slide(
          const Scaffold(body: Center(child: Text('Page not found'))),
          settings,
        );
    }
  }

  static PageRouteBuilder _slide(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) => SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
        child: child,
      ),
      transitionDuration: const Duration(milliseconds: 280),
    );
  }
}
