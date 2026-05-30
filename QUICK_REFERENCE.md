# QuickSell Quick Reference Guide

## 🚀 Quick Start

```bash
cd quicksell
flutter pub get
flutter run
```

## 📁 Project Structure at a Glance

```
lib/
├── main.dart                          # App entry point
├── firebase_options.dart              # Firebase config
├── config/theme/app_theme.dart        # UI theme
├── models/                            # Data models
│   ├── user_model.dart
│   ├── product_model.dart
│   └── message_model.dart
├── services/                          # Firebase services
│   ├── firebase_auth_service.dart
│   ├── firebase_product_service.dart
│   ├── firebase_storage_service.dart
│   └── firebase_chat_service.dart
├── providers/                         # State management
│   ├── auth_provider.dart
│   └── product_provider.dart
├── routes/app_routes.dart             # Navigation
└── screens/                           # UI screens
    ├── auth/
    ├── home/
    ├── product/
    ├── chat/
    └── profile/
```

## 🔑 Key Files to Edit

### 1. Firebase Configuration
**File**: `lib/firebase_options.dart`
```dart
// Update with your Firebase credentials
static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'YOUR_API_KEY',
  appId: 'YOUR_APP_ID',
  messagingSenderId: 'YOUR_SENDER_ID',
  projectId: 'YOUR_PROJECT_ID',
  storageBucket: 'YOUR_BUCKET',
);
```

### 2. App Theme
**File**: `lib/config/theme/app_theme.dart`
- Customize colors, fonts, and styles
- Light and dark theme support

### 3. Routes
**File**: `lib/routes/app_routes.dart`
- Add new routes here
- Update navigation paths

## 🎯 Common Tasks

### Add a New Screen
1. Create file: `lib/screens/feature/feature_screen.dart`
2. Add route in `lib/routes/app_routes.dart`
3. Create provider if needed in `lib/providers/`

### Add a New Model
1. Create file: `lib/models/new_model.dart`
2. Implement `fromJson()` and `toJson()`
3. Add `copyWith()` method

### Add a New Service
1. Create file: `lib/services/new_service.dart`
2. Implement Firebase operations
3. Create provider in `lib/providers/`

### Use State Management
```dart
// In a ConsumerWidget
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(myProvider);
    return data.when(
      data: (value) => Text(value),
      loading: () => CircularProgressIndicator(),
      error: (err, stack) => Text('Error: $err'),
    );
  }
}
```

## 📦 Dependencies

### Core
- `flutter` - UI framework
- `firebase_core` - Firebase initialization
- `firebase_auth` - Authentication
- `cloud_firestore` - Database
- `firebase_storage` - File storage

### State Management
- `riverpod` - State management
- `flutter_riverpod` - Flutter integration

### UI
- `google_fonts` - Typography
- `flutter_svg` - SVG support
- `cached_network_image` - Image caching

### Utilities
- `image_picker` - Image selection
- `geolocator` - Location services
- `uuid` - ID generation
- `logger` - Logging

## 🔐 Firebase Setup Checklist

- [ ] Create Firebase project
- [ ] Enable Authentication (Email/Password)
- [ ] Create Firestore Database
- [ ] Set up Storage bucket
- [ ] Download `google-services.json` (Android)
- [ ] Download `GoogleService-Info.plist` (iOS)
- [ ] Update `firebase_options.dart`
- [ ] Configure Firestore security rules
- [ ] Configure Storage security rules

## 🎨 Theme Colors

```dart
// Primary Colors
primaryColor: #2563EB (Blue)
secondaryColor: #10B981 (Green)
accentColor: #F59E0B (Amber)
errorColor: #EF4444 (Red)

// Background
backgroundColor: #F9FAFB (Light Gray)
surfaceColor: #FFFFFF (White)

// Text
textPrimaryColor: #1F2937 (Dark Gray)
textSecondaryColor: #6B7280 (Medium Gray)
```

## 📱 Screen Routes

| Screen | Route | File |
|--------|-------|------|
| Login | `/login` | `screens/auth/login_screen.dart` |
| Sign Up | `/signup` | `screens/auth/signup_screen.dart` |
| Home | `/home` | `screens/home/home_screen.dart` |
| Product Detail | `/product-detail` | `screens/product/product_detail_screen.dart` |
| Create Product | `/create-product` | `screens/product/create_product_screen.dart` |
| Chat | `/chat` | `screens/chat/chat_screen.dart` |
| Profile | `/profile` | `screens/profile/profile_screen.dart` |

## 🔄 Navigation Examples

```dart
// Push named route
Navigator.pushNamed(context, AppRoutes.home);

// Push with arguments
Navigator.pushNamed(
  context,
  AppRoutes.productDetail,
  arguments: 'product_id',
);

// Replace route
Navigator.pushReplacementNamed(context, AppRoutes.home);

// Pop back
Navigator.pop(context);
```

## 📊 Data Models

### UserModel
```dart
UserModel(
  uid: 'user123',
  email: 'user@example.com',
  displayName: 'John Doe',
  profileImageUrl: 'url',
  location: 'New York',
  latitude: 40.7128,
  longitude: -74.0060,
  rating: 4.8,
  reviewCount: 45,
)
```

### ProductModel
```dart
ProductModel(
  id: 'product123',
  sellerId: 'seller123',
  title: 'Laptop',
  description: 'Used laptop',
  price: 500.0,
  category: ProductCategory.electronics,
  condition: ProductCondition.good,
  status: ProductStatus.available,
  imageUrls: ['url1', 'url2'],
  location: 'New York',
  latitude: 40.7128,
  longitude: -74.0060,
)
```

### MessageModel
```dart
MessageModel(
  id: 'msg123',
  senderId: 'user1',
  receiverId: 'user2',
  conversationId: 'conv123',
  text: 'Hello!',
  timestamp: DateTime.now(),
  isRead: false,
)
```

## 🛠️ Useful Commands

```bash
# Clean and rebuild
flutter clean
flutter pub get

# Run code generation
flutter pub run build_runner build

# Format code
dart format lib/

# Analyze code
flutter analyze

# Run tests
flutter test

# Build APK
flutter build apk --release

# Build iOS
flutter build ios --release

# View logs
flutter logs

# Hot reload
# Press 'r' in terminal while running
```

## 🐛 Debugging

### Enable Logging
```dart
import 'package:logger/logger.dart';

final logger = Logger();
logger.d('Debug message');
logger.i('Info message');
logger.w('Warning message');
logger.e('Error message');
```

### Check Firebase Connection
```dart
// In main.dart
print('Firebase initialized: ${Firebase.apps.isNotEmpty}');
```

### View Firestore Data
- Go to Firebase Console → Firestore Database
- Browse collections and documents

## 📚 Documentation Files

- `README.md` - Project overview
- `SETUP_GUIDE.md` - Detailed setup instructions
- `DEVELOPMENT.md` - Development guidelines
- `PROJECT_SUMMARY.md` - Complete project summary
- `QUICK_REFERENCE.md` - This file

## 🔗 Useful Links

- [Flutter Docs](https://flutter.dev/docs)
- [Firebase Docs](https://firebase.google.com/docs)
- [Riverpod Docs](https://riverpod.dev)
- [Dart Docs](https://dart.dev/guides)
- [Material Design](https://material.io/design)

## ⚡ Performance Tips

1. Use `ListView.builder` for large lists
2. Use `CachedNetworkImage` for images
3. Use `select` in Riverpod to watch specific fields
4. Lazy load data when possible
5. Use `const` constructors

## 🔒 Security Reminders

- Never commit Firebase credentials
- Use environment variables for secrets
- Validate all user inputs
- Implement proper Firestore security rules
- Use HTTPS for all API calls
- Hash passwords (Firebase handles this)

## 📞 Support

- Check `SETUP_GUIDE.md` for setup issues
- Check `DEVELOPMENT.md` for coding questions
- Review Firebase documentation
- Check Flutter documentation
- Open GitHub issues for bugs

## 🎓 Learning Path

1. **Start**: Read `README.md` and `PROJECT_SUMMARY.md`
2. **Setup**: Follow `SETUP_GUIDE.md`
3. **Develop**: Read `DEVELOPMENT.md`
4. **Code**: Use this quick reference
5. **Deploy**: Follow deployment section in `SETUP_GUIDE.md`

---

**Last Updated**: May 28, 2026  
**Version**: 1.0.0  
**Status**: Ready for Development ✅
