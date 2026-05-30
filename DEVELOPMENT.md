# QuickSell Development Guide

This guide provides information for developers working on the QuickSell project.

## Code Structure

### Architecture Pattern: MVVM + Riverpod

The project follows a clean architecture pattern with:
- **Models**: Data structures and business logic
- **Services**: Firebase and external service integrations
- **Providers**: State management using Riverpod
- **Screens**: UI components and pages
- **Routes**: Navigation management

### Folder Organization

```
lib/
├── config/          # Configuration files (theme, constants)
├── models/          # Data models
├── services/        # Business logic and API calls
├── providers/       # Riverpod state management
├── routes/          # Navigation routes
├── screens/         # UI screens
└── utils/           # Utility functions and helpers
```

## Coding Standards

### Naming Conventions

- **Classes**: PascalCase (e.g., `UserModel`, `LoginScreen`)
- **Functions/Methods**: camelCase (e.g., `getUserProfile()`, `handleLogin()`)
- **Variables**: camelCase (e.g., `userName`, `isLoading`)
- **Constants**: camelCase (e.g., `maxRetries`, `defaultTimeout`)
- **Files**: snake_case (e.g., `user_model.dart`, `login_screen.dart`)

### Code Style

```dart
// Good: Clear and readable
Future<UserModel?> getUserProfile(String uid) async {
  try {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists) {
      return UserModel.fromJson(doc.data() as Map<String, dynamic>);
    }
  } catch (e) {
    rethrow;
  }
  return null;
}

// Bad: Unclear and hard to maintain
Future<UserModel?> gup(String u) async {
  try {
    var d = await _fs.collection('users').doc(u).get();
    if (d.exists) {
      return UserModel.fromJson(d.data() as Map<String, dynamic>);
    }
  } catch (e) {
    rethrow;
  }
  return null;
}
```

### Documentation

```dart
/// Fetches user profile from Firestore.
/// 
/// Returns null if user not found or on error.
/// 
/// Parameters:
///   - uid: The user's unique identifier
/// 
/// Throws: Rethrows any Firestore exceptions
Future<UserModel?> getUserProfile(String uid) async {
  // Implementation
}
```

## Working with Riverpod

### Creating Providers

```dart
// Simple provider
final authServiceProvider = Provider((ref) => FirebaseAuthService());

// Future provider
final currentUserProvider = FutureProvider<UserModel?>((ref) async {
  final authService = ref.watch(authServiceProvider);
  final user = authService.currentUser;
  if (user != null) {
    return await authService.getUserProfile(user.uid);
  }
  return null;
});

// Family provider (with parameters)
final userProfileProvider = FutureProvider.family<UserModel?, String>(
  (ref, uid) async {
    final authService = ref.watch(authServiceProvider);
    return await authService.getUserProfile(uid);
  },
);
```

### Using Providers in Widgets

```dart
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    
    return userAsync.when(
      data: (user) => Text(user?.displayName ?? 'Unknown'),
      loading: () => const CircularProgressIndicator(),
      error: (err, stack) => Text('Error: $err'),
    );
  }
}
```

## Firebase Integration

### Authentication Service

```dart
// Sign up
final user = await authService.signUp(
  email: 'user@example.com',
  password: 'password123',
  displayName: 'John Doe',
);

// Login
final user = await authService.login(
  email: 'user@example.com',
  password: 'password123',
);

// Sign out
await authService.signOut();
```

### Product Service

```dart
// Create product
final productId = await productService.createProduct(product);

// Get product
final product = await productService.getProduct(productId);

// Search products
final results = await productService.searchProducts('laptop');

// Get nearby products
final nearby = await productService.getNearbyProducts(
  latitude: 40.7128,
  longitude: -74.0060,
  radiusInKm: 5.0,
);
```

### Chat Service

```dart
// Get or create conversation
final conversationId = await chatService.getOrCreateConversation(
  userId1: 'user1',
  userId2: 'user2',
  productId: 'product123',
);

// Send message
await chatService.sendMessage(message);

// Get messages stream
final messagesStream = chatService.getMessages(conversationId);
```

## Testing

### Unit Tests

```dart
void main() {
  group('UserModel', () {
    test('fromJson creates UserModel correctly', () {
      final json = {
        'uid': 'user123',
        'email': 'test@example.com',
        'displayName': 'Test User',
        'createdAt': DateTime.now().toIso8601String(),
      };
      
      final user = UserModel.fromJson(json);
      
      expect(user.uid, 'user123');
      expect(user.email, 'test@example.com');
    });
  });
}
```

### Widget Tests

```dart
void main() {
  testWidgets('LoginScreen renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(TextField), findsWidgets);
  });
}
```

## Common Tasks

### Adding a New Screen

1. Create screen file in `lib/screens/feature/feature_screen.dart`
2. Add route in `lib/routes/app_routes.dart`
3. Create provider if needed in `lib/providers/`
4. Update navigation in parent screen

### Adding a New Model

1. Create model file in `lib/models/`
2. Implement `fromJson()` and `toJson()` methods
3. Add `copyWith()` method for immutability
4. Add documentation

### Adding a New Service

1. Create service file in `lib/services/`
2. Implement methods for Firebase operations
3. Add error handling
4. Create provider in `lib/providers/`

### Adding a New Provider

1. Create provider in `lib/providers/`
2. Use appropriate provider type (Provider, FutureProvider, etc.)
3. Add documentation
4. Use in widgets with `ref.watch()`

## Debugging

### Enable Debug Logging

```dart
import 'package:logger/logger.dart';

final logger = Logger();

logger.d('Debug message');
logger.i('Info message');
logger.w('Warning message');
logger.e('Error message');
```

### Firebase Emulator (Optional)

```bash
# Start Firebase emulator
firebase emulators:start

# Connect app to emulator
// In main.dart
await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
```

### Hot Reload Tips

- Hot reload works for most changes
- Full rebuild needed for:
  - Native code changes
  - Package changes
  - Build configuration changes

## Performance Optimization

### Image Optimization

```dart
// Use cached network image
CachedNetworkImage(
  imageUrl: 'https://example.com/image.jpg',
  placeholder: (context, url) => const CircularProgressIndicator(),
  errorWidget: (context, url, error) => const Icon(Icons.error),
)
```

### List Performance

```dart
// Use ListView.builder for large lists
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) => ItemTile(item: items[index]),
)
```

### State Management

```dart
// Use select to watch only specific fields
final userName = ref.watch(
  userProvider.select((user) => user?.displayName),
);
```

## Git Workflow

### Branch Naming

- Feature: `feature/feature-name`
- Bug fix: `bugfix/bug-name`
- Hotfix: `hotfix/issue-name`

### Commit Messages

```
feat: Add user authentication
fix: Resolve product search issue
docs: Update README
style: Format code
refactor: Reorganize file structure
test: Add unit tests for UserModel
```

### Pull Request Process

1. Create feature branch
2. Make changes and commit
3. Push to remote
4. Create pull request
5. Request review
6. Address feedback
7. Merge to main

## Useful Commands

```bash
# Clean build
flutter clean

# Get dependencies
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
```

## Resources

- [Flutter Best Practices](https://flutter.dev/docs/testing/best-practices)
- [Riverpod Documentation](https://riverpod.dev)
- [Firebase Flutter Guide](https://firebase.flutter.dev)
- [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)

## Contributing

1. Follow the code standards
2. Write tests for new features
3. Update documentation
4. Create descriptive commit messages
5. Request review before merging

---

**Happy coding! 🎉**
