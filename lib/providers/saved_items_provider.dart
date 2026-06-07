import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product_model.dart';
import '../services/firebase_saved_items_service.dart';

final savedItemsServiceProvider =
    Provider((ref) => FirebaseSavedItemsService());

final savedIdsProvider =
    StreamProvider.family<Set<String>, String>((ref, userId) {
  return ref.watch(savedItemsServiceProvider).savedIdsStream(userId);
});

final savedProductsProvider =
    StreamProvider.family<List<ProductModel>, String>((ref, userId) {
  return ref.watch(savedItemsServiceProvider).savedProductsStream(userId);
});
