import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ImgBBStorageService {
  static const String _apiKey = 'cacb15cc48eab34c568a7b2322c7fe61';
  static const String _baseUrl = 'https://api.imgbb.com/1/upload';

  /// Upload a single image to ImgBB
  /// Returns the image URL on success
  Future<String> uploadImage(File imageFile) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(_baseUrl));

      // Add API key
      request.fields['key'] = _apiKey;

      // Add image file
      request.files.add(
        http.MultipartFile(
          'image',
          imageFile.readAsBytes().asStream(),
          imageFile.lengthSync(),
          filename: imageFile.path.split('/').last,
        ),
      );

      // Send request
      final response = await request.send();
      final responseData = await response.stream.toBytes();
      final responseString = String.fromCharCodes(responseData);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(responseString);
        if (jsonResponse['success'] == true) {
          return jsonResponse['data']['url'] as String;
        } else {
          throw Exception('ImgBB upload failed: ${jsonResponse['error']}');
        }
      } else {
        throw Exception('Failed to upload image: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Upload multiple images to ImgBB
  /// Returns a list of image URLs
  Future<List<String>> uploadImages(List<File> imageFiles) async {
    try {
      final urls = <String>[];
      for (final imageFile in imageFiles) {
        final url = await uploadImage(imageFile);
        urls.add(url);
      }
      return urls;
    } catch (e) {
      rethrow;
    }
  }

  /// Upload profile image to ImgBB
  /// Returns the image URL
  Future<String> uploadProfileImage(File imageFile, String userId) async {
    try {
      return await uploadImage(imageFile);
    } catch (e) {
      rethrow;
    }
  }

  /// Delete image from ImgBB (requires delete token)
  /// Note: ImgBB free tier doesn't support direct deletion via API
  /// You would need to delete manually or use the delete token from upload response
  Future<void> deleteImage(String deleteToken) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        body: {'delete': deleteToken},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete image: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Get image info from ImgBB
  /// Returns image metadata
  Future<Map<String, dynamic>> getImageInfo(String imageUrl) async {
    try {
      // Extract image ID from URL
      final imageId = imageUrl.split('/').last.split('.').first;

      final response = await http.get(
        Uri.parse('$_baseUrl?key=$_apiKey&image=$imageId'),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['success'] == true) {
          return jsonResponse['data'] as Map<String, dynamic>;
        } else {
          throw Exception('Failed to get image info');
        }
      } else {
        throw Exception('Failed to get image info: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Validate image file before upload
  /// Checks file size and format
  bool validateImage(File imageFile) {
    try {
      final fileSizeInMB = imageFile.lengthSync() / (1024 * 1024);

      // ImgBB free tier limit is 32MB
      if (fileSizeInMB > 32) {
        throw Exception('Image size exceeds 32MB limit');
      }

      final supportedFormats = ['jpg', 'jpeg', 'png', 'gif', 'webp'];
      final fileExtension = imageFile.path.split('.').last.toLowerCase();

      if (!supportedFormats.contains(fileExtension)) {
        throw Exception('Unsupported image format: $fileExtension');
      }

      return true;
    } catch (e) {
      rethrow;
    }
  }

  /// Get API key (for reference)
  String getApiKey() => _apiKey;

  /// Get base URL (for reference)
  String getBaseUrl() => _baseUrl;
}
