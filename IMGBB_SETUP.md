# ImgBB Image Storage Setup Guide

This guide explains how to use ImgBB for image storage in QuickSell instead of Firebase Storage.

## Why ImgBB?

- ✅ Free tier with 32MB file size limit
- ✅ No complex authentication setup
- ✅ Simple REST API
- ✅ Fast image delivery
- ✅ Easy to implement
- ✅ No Firebase Storage quota concerns

## API Key

Your ImgBB API Key: `cacb15cc48eab34c568a7b2322c7fe61`

**Location in Code**: `lib/services/imgbb_storage_service.dart`

## How It Works

### 1. Image Upload Flow

```
User selects image
    ↓
Image picker opens
    ↓
User picks image(s)
    ↓
Validate image (size, format)
    ↓
Upload to ImgBB API
    ↓
Get image URL
    ↓
Store URL in Firestore
```

### 2. Supported Formats

- JPG/JPEG
- PNG
- GIF
- WebP

### 3. Size Limits

- **Free Tier**: 32MB per image
- **Recommended**: Keep images under 5MB for faster uploads

## Implementation Details

### ImgBB Storage Service

**File**: `lib/services/imgbb_storage_service.dart`

Key methods:

```dart
// Upload single image
Future<String> uploadImage(File imageFile)

// Upload multiple images
Future<List<String>> uploadImages(List<File> imageFiles)

// Upload profile image
Future<String> uploadProfileImage(File imageFile, String userId)

// Validate image before upload
bool validateImage(File imageFile)

// Delete image (requires delete token)
Future<void> deleteImage(String deleteToken)
```

### Create Product Screen

**File**: `lib/screens/product/create_product_screen.dart`

Features:
- ✅ Select multiple images
- ✅ Preview selected images
- ✅ Remove images before upload
- ✅ Upload to ImgBB
- ✅ Show upload progress
- ✅ Display success message
- ✅ Store URLs for product creation

## Usage Example

### In Your Code

```dart
import 'package:image_picker/image_picker.dart';
import 'lib/services/imgbb_storage_service.dart';

// Initialize service
final storageService = ImgBBStorageService();
final imagePicker = ImagePicker();

// Pick image
final pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);

// Validate
if (storageService.validateImage(File(pickedFile.path))) {
  // Upload
  final imageUrl = await storageService.uploadImage(File(pickedFile.path));
  print('Image uploaded: $imageUrl');
}
```

### Upload Multiple Images

```dart
final pickedFiles = await imagePicker.pickMultiImage();
final imageFiles = pickedFiles.map((file) => File(file.path)).toList();

final urls = await storageService.uploadImages(imageFiles);
print('Uploaded ${urls.length} images');
```

## API Response Format

### Successful Upload

```json
{
  "success": true,
  "data": {
    "id": "abc123",
    "url": "https://i.ibb.co/abc123/image.jpg",
    "display_url": "https://ibb.co/abc123",
    "delete_url": "https://ibb.co/abc123/delete/token123",
    "delete_token": "token123"
  }
}
```

### Failed Upload

```json
{
  "success": false,
  "error": "Error message"
}
```

## Error Handling

The service includes comprehensive error handling:

```dart
try {
  final url = await storageService.uploadImage(imageFile);
} catch (e) {
  print('Upload failed: $e');
  // Handle error
}
```

Common errors:
- **File too large**: Image exceeds 32MB
- **Unsupported format**: File is not JPG, PNG, GIF, or WebP
- **Network error**: No internet connection
- **API error**: ImgBB API returned an error

## Storing URLs in Firestore

After uploading, store the URL in your product document:

```dart
// In ProductModel
final product = ProductModel(
  id: 'product123',
  title: 'Laptop',
  imageUrls: ['https://i.ibb.co/abc123/image.jpg'],
  // ... other fields
);

// Save to Firestore
await firestore.collection('products').doc(product.id).set(product.toJson());
```

## Displaying Images

Use `CachedNetworkImage` for better performance:

```dart
import 'package:cached_network_image/cached_network_image.dart';

CachedNetworkImage(
  imageUrl: 'https://i.ibb.co/abc123/image.jpg',
  placeholder: (context, url) => CircularProgressIndicator(),
  errorWidget: (context, url, error) => Icon(Icons.error),
)
```

## Deleting Images

ImgBB provides delete tokens for image deletion:

```dart
// Get delete token from upload response
final deleteToken = uploadResponse['data']['delete_token'];

// Delete image
await storageService.deleteImage(deleteToken);
```

**Note**: Store delete tokens in Firestore if you need to delete images later.

## Best Practices

### 1. Validate Before Upload
```dart
if (!storageService.validateImage(imageFile)) {
  print('Invalid image');
  return;
}
```

### 2. Show Upload Progress
```dart
for (int i = 0; i < images.length; i++) {
  print('Uploading ${i + 1}/${images.length}');
  final url = await storageService.uploadImage(images[i]);
}
```

### 3. Handle Errors Gracefully
```dart
try {
  final url = await storageService.uploadImage(imageFile);
} catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Upload failed: $e')),
  );
}
```

### 4. Compress Images
```dart
// Use image_picker with quality setting
final pickedFile = await imagePicker.pickImage(
  source: ImageSource.gallery,
  imageQuality: 80,  // 0-100
  maxHeight: 1000,
  maxWidth: 1000,
);
```

### 5. Cache Images Locally
```dart
// Use cached_network_image for better performance
CachedNetworkImage(
  imageUrl: imageUrl,
  cacheManager: CacheManager.instance,
)
```

## Troubleshooting

### Images Not Uploading

1. Check internet connection
2. Verify image file exists
3. Check image size (< 32MB)
4. Check image format (JPG, PNG, GIF, WebP)
5. Check API key is correct

### Slow Upload Speed

1. Compress images before upload
2. Reduce image quality
3. Check internet connection
4. Upload one image at a time

### Images Not Displaying

1. Check image URL is correct
2. Verify image was uploaded successfully
3. Check network connectivity
4. Use CachedNetworkImage for caching

## API Limits

- **Free Tier**: 32MB per image
- **Rate Limit**: No strict rate limit for free tier
- **Bandwidth**: Unlimited
- **Storage**: Unlimited

## Security Considerations

### API Key Protection

⚠️ **Important**: Your API key is currently in the source code.

For production, consider:

1. **Environment Variables**
   ```dart
   const String apiKey = String.fromEnvironment('IMGBB_API_KEY');
   ```

2. **Backend Proxy**
   - Send images to your backend
   - Backend uploads to ImgBB
   - Backend returns URL to app

3. **Firebase Cloud Functions**
   - Create Cloud Function to handle uploads
   - Function uses API key (not exposed to client)

### Image Privacy

- ImgBB URLs are public by default
- Anyone with the URL can view the image
- For private images, use Firebase Storage instead

## Migration from Firebase Storage

If you were using Firebase Storage:

1. **Remove Firebase Storage dependency**
   ```yaml
   # Remove from pubspec.yaml
   firebase_storage: ^11.5.0
   ```

2. **Replace service**
   ```dart
   // Old
   final url = await firebaseStorageService.uploadImage(file);
   
   // New
   final url = await imgbbStorageService.uploadImage(file);
   ```

3. **Update imports**
   ```dart
   // Old
   import 'services/firebase_storage_service.dart';
   
   // New
   import 'services/imgbb_storage_service.dart';
   ```

## Alternative Services

If you want to switch later:

- **Firebase Storage**: More features, requires Firebase setup
- **AWS S3**: More control, requires AWS account
- **Cloudinary**: Advanced image processing
- **Imgur**: Similar to ImgBB

## Support

- **ImgBB Website**: https://imgbb.com
- **ImgBB API Docs**: https://api.imgbb.com
- **ImgBB Support**: https://imgbb.com/contact

## Summary

✅ ImgBB is configured and ready to use  
✅ API key is set in `imgbb_storage_service.dart`  
✅ Create product screen is integrated  
✅ Image validation is implemented  
✅ Error handling is in place  

**Next Steps**:
1. Test image upload in create product screen
2. Verify images appear in Firestore
3. Test image display in product detail screen
4. Monitor upload performance

---

**Version**: 1.0.0  
**Last Updated**: May 28, 2026  
**Status**: Ready for Use ✅
