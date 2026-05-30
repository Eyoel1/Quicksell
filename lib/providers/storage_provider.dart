import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/imgbb_storage_service.dart';

final storageServiceProvider = Provider((ref) => ImgBBStorageService());

final uploadImageProvider = FutureProvider.family<String, File>(
  (ref, imageFile) async {
    final storageService = ref.watch(storageServiceProvider);
    return await storageService.uploadImage(imageFile);
  },
);

final uploadImagesProvider = FutureProvider.family<List<String>, List<File>>(
  (ref, imageFiles) async {
    final storageService = ref.watch(storageServiceProvider);
    return await storageService.uploadImages(imageFiles);
  },
);

final validateImageProvider = Provider.family<bool, File>(
  (ref, imageFile) {
    final storageService = ref.watch(storageServiceProvider);
    return storageService.validateImage(imageFile);
  },
);
