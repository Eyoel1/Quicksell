import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

class FirebaseSavedItemsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<Set<String>> savedIdsStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('savedItems')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.id).toSet());
  }

  Future<bool> isSaved(String userId, String productId) async {
    final doc = await _firestore
        .collection('users')
        .doc(userId)
        .collection('savedItems')
        .doc(productId)
        .get();
    return doc.exists;
  }

  Future<void> toggleSaved(String userId, ProductModel product) async {
    final ref = _firestore
        .collection('users')
        .doc(userId)
        .collection('savedItems')
        .doc(product.id);
    final doc = await ref.get();
    if (doc.exists) {
      await ref.delete();
    } else {
      await ref.set({
        'productId': product.id,
        'title': product.title,
        'price': product.price,
        'imageUrl': product.imageUrls.isNotEmpty ? product.imageUrls.first : null,
        'sellerId': product.sellerId,
        'savedAt': DateTime.now().toIso8601String(),
      });
    }
  }

  Stream<List<ProductModel>> savedProductsStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('savedItems')
        .snapshots()
        .asyncMap((snapshot) async {
      final products = <ProductModel>[];
      for (final saved in snapshot.docs) {
        final productId = saved.id;
        final productDoc =
            await _firestore.collection('products').doc(productId).get();
        if (productDoc.exists && productDoc.data() != null) {
          final data = productDoc.data()!;
          data['id'] = productDoc.id;
          try {
            products.add(ProductModel.fromJson(data));
          } catch (_) {}
        }
      }
      products.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return products;
    });
  }
}
