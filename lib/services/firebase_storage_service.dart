import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class FirebaseStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  static const String _productImagesPath = 'products';
  static const String _profileImagesPath = 'profiles';

  // Upload product image
  Future<String> uploadProductImage(File imageFile) async {
    try {
      final fileName = '${_productImagesPath}/${const Uuid().v4()}.jpg';
      final ref = _storage.ref().child(fileName);

      await ref.putFile(imageFile);
      return await ref.getDownloadURL();
    } catch (e) {
      rethrow;
    }
  }

  // Upload multiple product images
  Future<List<String>> uploadProductImages(List<File> imageFiles) async {
    try {
      final urls = <String>[];
      for (final imageFile in imageFiles) {
        final url = await uploadProductImage(imageFile);
        urls.add(url);
      }
      return urls;
    } catch (e) {
      rethrow;
    }
  }

  // Upload profile image
  Future<String> uploadProfileImage(File imageFile, String userId) async {
    try {
      final fileName = '$_profileImagesPath/$userId.jpg';
      final ref = _storage.ref().child(fileName);

      await ref.putFile(imageFile);
      return await ref.getDownloadURL();
    } catch (e) {
      rethrow;
    }
  }

  // Delete file
  Future<void> deleteFile(String fileUrl) async {
    try {
      final ref = _storage.refFromURL(fileUrl);
      await ref.delete();
    } catch (e) {
      rethrow;
    }
  }

  // Delete multiple files
  Future<void> deleteFiles(List<String> fileUrls) async {
    try {
      for (final url in fileUrls) {
        await deleteFile(url);
      }
    } catch (e) {
      rethrow;
    }
  }

  // Get file download URL
  Future<String> getDownloadUrl(String filePath) async {
    try {
      return await _storage.ref().child(filePath).getDownloadURL();
    } catch (e) {
      rethrow;
    }
  }
}
