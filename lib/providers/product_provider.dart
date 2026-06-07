import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/firebase_product_service.dart';
import '../models/product_model.dart';

final productServiceProvider = Provider((ref) => FirebaseProductService());

/// Live stream of all available products.
/// Switched from FutureProvider → StreamProvider so newly created products
/// appear instantly without needing a manual refresh.
final allProductsProvider = StreamProvider<List<ProductModel>>((ref) {
  return ref.watch(productServiceProvider).getAllProductsStream();
});

/// Live stream of a single product.
/// Switched from FutureProvider → StreamProvider to fix "Error loading product".
final productByIdProvider =
    StreamProvider.family<ProductModel?, String>((ref, productId) {
  return ref.watch(productServiceProvider).getProductStream(productId);
});

/// Live stream of a seller's own listings (for My Listings screen).
final productsBySellerProvider =
    StreamProvider.family<List<ProductModel>, String>((ref, sellerId) {
  return ref.watch(productServiceProvider).getProductsBySellerStream(sellerId);
});

/// Live stream of products in a specific category.
final productsByCategoryProvider =
    StreamProvider.family<List<ProductModel>, String>((ref, category) {
  return ref
      .watch(productServiceProvider)
      .getProductsByCategoryStream(category);
});

/// One-time search — rebuilt on every query change via ref.watch.
final searchProductsProvider =
    FutureProvider.family<List<ProductModel>, String>((ref, query) async {
  return ref.watch(productServiceProvider).searchProducts(query);
});
