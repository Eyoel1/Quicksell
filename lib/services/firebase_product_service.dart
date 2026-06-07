import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math' as math;
import '../models/product_model.dart';

class FirebaseProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ─── Stream-based (live, real-time) ─────────────────────────────────────────

  /// Live stream of all available products — fixes stale-cache/FutureProvider issue
  Stream<List<ProductModel>> getAllProductsStream() {
    return _firestore.collection('products').snapshots().map((snapshot) {
      final products = snapshot.docs
          .map((doc) {
            try {
              final data = doc.data();
              data['id'] = doc.id;
              return ProductModel.fromJson(data);
            } catch (_) {
              return null;
            }
          })
          .whereType<ProductModel>()
          .where((p) => p.status == ProductStatus.available)
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return products;
    });
  }

  /// Live stream for a single product by ID — fixes "Error loading product"
  Stream<ProductModel?> getProductStream(String productId) {
    if (productId.isEmpty) return Stream.value(null);
    return _firestore
        .collection('products')
        .doc(productId)
        .snapshots()
        .map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      try {
        final data = doc.data()!;
        data['id'] = doc.id;
        return ProductModel.fromJson(data);
      } catch (_) {
        return null;
      }
    });
  }

  /// Live stream of all products by a given seller (for My Listings)
  Stream<List<ProductModel>> getProductsBySellerStream(String sellerId) {
    return _firestore
        .collection('products')
        .where('sellerId', isEqualTo: sellerId)
        .snapshots()
        .map((snapshot) {
      final products = snapshot.docs
          .map((doc) {
            try {
              final data = doc.data();
              data['id'] = doc.id;
              return ProductModel.fromJson(data);
            } catch (_) {
              return null;
            }
          })
          .whereType<ProductModel>()
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return products;
    });
  }

  /// Live stream of products filtered by category
  Stream<List<ProductModel>> getProductsByCategoryStream(String category) {
    return _firestore
        .collection('products')
        .where('category', isEqualTo: category)
        .snapshots()
        .map((snapshot) {
      final products = snapshot.docs
          .map((doc) {
            try {
              final data = doc.data();
              data['id'] = doc.id;
              return ProductModel.fromJson(data);
            } catch (_) {
              return null;
            }
          })
          .whereType<ProductModel>()
          .where((p) => p.status == ProductStatus.available)
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return products;
    });
  }

  // ─── One-time fetches (kept for compatibility) ───────────────────────────────

  Future<ProductModel?> getProduct(String productId) async {
    if (productId.isEmpty) return null;
    try {
      final doc =
          await _firestore.collection('products').doc(productId).get();
      if (!doc.exists || doc.data() == null) return null;
      final data = doc.data()!;
      data['id'] = doc.id;
      return ProductModel.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<ProductModel>> getAllProducts() async {
    try {
      final snapshot =
          await _firestore.collection('products').limit(100).get();
      final products = snapshot.docs
          .map((doc) {
            try {
              final data = doc.data();
              data['id'] = doc.id;
              return ProductModel.fromJson(data);
            } catch (_) {
              return null;
            }
          })
          .whereType<ProductModel>()
          .where((p) => p.status == ProductStatus.available)
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return products;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<ProductModel>> getProductsBySeller(String sellerId) async {
    try {
      final snapshot = await _firestore
          .collection('products')
          .where('sellerId', isEqualTo: sellerId)
          .get();
      final products = snapshot.docs
          .map((doc) {
            try {
              final data = doc.data();
              data['id'] = doc.id;
              return ProductModel.fromJson(data);
            } catch (_) {
              return null;
            }
          })
          .whereType<ProductModel>()
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return products;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<ProductModel>> getProductsByCategory(String category) async {
    try {
      final snapshot = await _firestore
          .collection('products')
          .where('category', isEqualTo: category)
          .get();
      final products = snapshot.docs
          .map((doc) {
            try {
              final data = doc.data();
              data['id'] = doc.id;
              return ProductModel.fromJson(data);
            } catch (_) {
              return null;
            }
          })
          .whereType<ProductModel>()
          .where((p) => p.status == ProductStatus.available)
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return products;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<ProductModel>> searchProducts(String query) async {
    try {
      final snapshot = await _firestore.collection('products').get();
      final q = query.toLowerCase();
      final products = snapshot.docs
          .map((doc) {
            try {
              final data = doc.data();
              data['id'] = doc.id;
              return ProductModel.fromJson(data);
            } catch (_) {
              return null;
            }
          })
          .whereType<ProductModel>()
          .where((p) =>
              p.status == ProductStatus.available &&
              (p.title.toLowerCase().contains(q) ||
                  p.description.toLowerCase().contains(q) ||
                  p.category.name.toLowerCase().contains(q) ||
                  p.location.toLowerCase().contains(q)))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return products;
    } catch (e) {
      rethrow;
    }
  }

  // ─── Mutations ───────────────────────────────────────────────────────────────

  /// Creates a product and returns the Firestore document ID
  Future<String> createProduct(ProductModel product) async {
    try {
      final json = product.toJson()..remove('id');
      final docRef = await _firestore.collection('products').add(json);
      await docRef.update({'id': docRef.id});
      return docRef.id;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateProduct(
      String productId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('products').doc(productId).update(data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      await _firestore.collection('products').doc(productId).delete();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> markAsSold(String productId) async {
    try {
      await _firestore
          .collection('products')
          .doc(productId)
          .update({'status': ProductStatus.sold.name});
    } catch (e) {
      rethrow;
    }
  }

  /// Persists the like/unlike to Firestore (fixes local-only like bug)
  Future<void> toggleLike(String productId, String userId) async {
    try {
      final docRef = _firestore.collection('products').doc(productId);
      await _firestore.runTransaction((tx) async {
        final snap = await tx.get(docRef);
        final likes = List<String>.from(snap.data()?['likes'] ?? []);
        if (likes.contains(userId)) {
          likes.remove(userId);
        } else {
          likes.add(userId);
        }
        tx.update(docRef, {'likes': likes});
      });
    } catch (e) {
      rethrow;
    }
  }

  // ─── Viewer tracking (for seller discount offers) ─────────────────────────

  /// Records that [userId] viewed [productId].
  /// Stored as a lightweight subcollection so the seller can later
  /// send discount offers to everyone who has seen the listing.
  Future<void> trackViewer(String productId, String userId) async {
    try {
      await _firestore
          .collection('products')
          .doc(productId)
          .collection('viewers')
          .doc(userId)
          .set({
        'userId': userId,
        'viewedAt': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));
    } catch (_) {
      // Non-critical — silently ignore
    }
  }

  /// Live stream of viewer IDs for a product (seller-side).
  Stream<List<String>> getViewerIdsStream(String productId) {
    return _firestore
        .collection('products')
        .doc(productId)
        .collection('viewers')
        .snapshots()
        .map((s) => s.docs.map((d) => d.id).toList());
  }

  Future<void> incrementViewCount(String productId) async {
    try {
      await _firestore
          .collection('products')
          .doc(productId)
          .update({'views': FieldValue.increment(1)});
    } catch (_) {
      // Non-critical — silently ignore
    }
  }

  // ─── Geo ─────────────────────────────────────────────────────────────────────

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
      return snapshot.docs
          .map((doc) {
            try {
              final data = doc.data();
              data['id'] = doc.id;
              return ProductModel.fromJson(data);
            } catch (_) {
              return null;
            }
          })
          .whereType<ProductModel>()
          .where((p) =>
              _calculateDistance(
                  latitude, longitude, p.latitude, p.longitude) <=
              radiusInKm)
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const r = 6371.0;
    final dLat = _toRad(lat2 - lat1);
    final dLon = _toRad(lon2 - lon1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRad(lat1)) *
            math.cos(_toRad(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    return r * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }

  double _toRad(double deg) => deg * math.pi / 180;
}
