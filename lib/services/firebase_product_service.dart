import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math' as math;
import '../models/product_model.dart';

class FirebaseProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create a new product
  Future<String> createProduct(ProductModel product) async {
    try {
      // Don't include the ID in the JSON when creating
      final productJson = product.toJson();
      productJson.remove('id'); // Remove the empty id field
      
      final docRef = await _firestore.collection('products').add(productJson);
      
      // Update the document with its own ID
      await docRef.update({'id': docRef.id});
      
      return docRef.id;
    } catch (e) {
      rethrow;
    }
  }

  // Get product by ID
  Future<ProductModel?> getProduct(String productId) async {
    try {
      final doc = await _firestore.collection('products').doc(productId).get();
      if (doc.exists) {
        return ProductModel.fromJson({
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        });
      }
    } catch (e) {
      rethrow;
    }
    return null;
  }

  // Get all products
  Future<List<ProductModel>> getAllProducts() async {
    try {
      final snapshot = await _firestore
          .collection('products')
          .limit(100)
          .get();

      final products = snapshot.docs
          .map((doc) => ProductModel.fromJson({
                'id': doc.id,
                ...doc.data(),
              }))
          .where((product) => product.status == ProductStatus.available)
          .toList();
      
      // Sort by createdAt in memory
      products.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      return products;
    } catch (e) {
      rethrow;
    }
  }

  // Get products by seller
  Future<List<ProductModel>> getProductsBySeller(String sellerId) async {
    try {
      final snapshot = await _firestore
          .collection('products')
          .where('sellerId', isEqualTo: sellerId)
          .get();

      final products = snapshot.docs
          .map((doc) => ProductModel.fromJson({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();
      
      // Sort by createdAt in memory
      products.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      return products;
    } catch (e) {
      rethrow;
    }
  }

  // Get products by category
  Future<List<ProductModel>> getProductsByCategory(String category) async {
    try {
      final snapshot = await _firestore
          .collection('products')
          .where('category', isEqualTo: category)
          .get();

      final products = snapshot.docs
          .map((doc) => ProductModel.fromJson({
                'id': doc.id,
                ...doc.data(),
              }))
          .where((product) => product.status == ProductStatus.available)
          .toList();
      
      // Sort by createdAt in memory
      products.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      return products;
    } catch (e) {
      rethrow;
    }
  }

  // Search products
  Future<List<ProductModel>> searchProducts(String query) async {
    try {
      // Get all products and filter in memory for simplicity
      final snapshot = await _firestore
          .collection('products')
          .get();

      final products = snapshot.docs
          .map((doc) => ProductModel.fromJson({
                'id': doc.id,
                ...doc.data(),
              }))
          .where((product) => 
              product.status == ProductStatus.available &&
              (product.title.toLowerCase().contains(query.toLowerCase()) ||
               product.description.toLowerCase().contains(query.toLowerCase())))
          .toList();
      
      // Sort by createdAt in memory
      products.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      return products;
    } catch (e) {
      rethrow;
    }
  }

  // Get nearby products
  Future<List<ProductModel>> getNearbyProducts(
    double latitude,
    double longitude,
    double radiusInKm,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('products')
          .where('status', isEqualTo: 'available')
          .get();

      final products = snapshot.docs
          .map((doc) => ProductModel.fromJson({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();

      // Filter by distance
      products.retainWhere((product) {
        final distance = _calculateDistance(
          latitude,
          longitude,
          product.latitude,
          product.longitude,
        );
        return distance <= radiusInKm;
      });

      return products;
    } catch (e) {
      rethrow;
    }
  }

  // Update product
  Future<void> updateProduct(String productId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('products').doc(productId).update(data);
    } catch (e) {
      rethrow;
    }
  }

  // Delete product
  Future<void> deleteProduct(String productId) async {
    try {
      await _firestore.collection('products').doc(productId).delete();
    } catch (e) {
      rethrow;
    }
  }

  // Like/Unlike product
  Future<void> toggleLike(String productId, String userId) async {
    try {
      final doc = await _firestore.collection('products').doc(productId).get();
      final likes = List<String>.from(doc.data()?['likes'] ?? []);

      if (likes.contains(userId)) {
        likes.remove(userId);
      } else {
        likes.add(userId);
      }

      await _firestore
          .collection('products')
          .doc(productId)
          .update({'likes': likes});
    } catch (e) {
      rethrow;
    }
  }

  // Increment view count
  Future<void> incrementViewCount(String productId) async {
    try {
      await _firestore.collection('products').doc(productId).update({
        'views': FieldValue.increment(1),
      });
    } catch (e) {
      rethrow;
    }
  }

  // Calculate distance between two coordinates (Haversine formula)
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadiusKm = 6371;

    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);

    final a = (math.sin(dLat / 2) * math.sin(dLat / 2)) +
        (math.cos(_degreesToRadians(lat1)) *
            math.cos(_degreesToRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2));

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusKm * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180);
  }
}
