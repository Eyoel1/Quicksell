import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/firebase_product_service.dart';
import '../models/product_model.dart';

final productServiceProvider = Provider((ref) => FirebaseProductService());

final allProductsProvider = FutureProvider<List<ProductModel>>((ref) async {
  final productService = ref.watch(productServiceProvider);
  return await productService.getAllProducts();
});

final productByIdProvider = FutureProvider.family<ProductModel?, String>(
  (ref, productId) async {
    final productService = ref.watch(productServiceProvider);
    return await productService.getProduct(productId);
  },
);

final productsBySellerProvider =
    FutureProvider.family<List<ProductModel>, String>(
  (ref, sellerId) async {
    final productService = ref.watch(productServiceProvider);
    return await productService.getProductsBySeller(sellerId);
  },
);

final productsByCategoryProvider =
    FutureProvider.family<List<ProductModel>, String>(
  (ref, category) async {
    final productService = ref.watch(productServiceProvider);
    return await productService.getProductsByCategory(category);
  },
);

final searchProductsProvider = FutureProvider.family<List<ProductModel>, String>(
  (ref, query) async {
    final productService = ref.watch(productServiceProvider);
    return await productService.searchProducts(query);
  },
);

final nearbyProductsProvider =
    FutureProvider.family<List<ProductModel>, Map<String, dynamic>>(
  (ref, params) async {
    final productService = ref.watch(productServiceProvider);
    return await productService.getNearbyProducts(
      params['latitude'] as double,
      params['longitude'] as double,
      params['radius'] as double,
    );
  },
);
