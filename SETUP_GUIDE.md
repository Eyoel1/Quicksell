# QuickSell Setup Guide

This guide will help you set up the QuickSell application from scratch.

## Prerequisites

Before you begin, ensure you have the following installed:

- **Flutter SDK**: Version 3.12.0 or higher
  - Download from: https://flutter.dev/docs/get-started/install
- **Dart SDK**: Comes with Flutter
- **Android Studio** or **Xcode** (for emulator/device testing)
- **Firebase CLI** (optional but recommended)
- **Git** for version control

## Step 1: Flutter Setup

### Verify Flutter Installation
```bash
flutter --version
flutter doctor
```

The `flutter doctor` command will show you any missing dependencies.

### Update Flutter
```bash
flutter upgrade
```

## Step 2: Project Setup

### Clone or Create Project
```bash
# If cloning
git clone <repository-url>
cd quicksell

# Or create new
flutter create quicksell
cd quicksell
```

### Install Dependencies
```bash
flutter pub get
```

### Generate Build Files (if needed)
```bash
flutter pub run build_runner build
```

## Step 3: Firebase Configuration

### Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click "Create a new project"
3. Enter project name: "QuickSell"
4. Enable Google Analytics (optional)
5. Create the project

### Android Setup

1. In Firebase Console, click "Add app" → Android
2. Enter package name: `com.example.quicksell`
3. Download `google-services.json`
4. Place it in: `android/app/google-services.json`
5. Update `android/build.gradle`:
   ```gradle
   buildscript {
     dependencies {
       classpath 'com.google.gms:google-services:4.3.15'
     }
   }
   ```
6. Update `android/app/build.gradle`:
   ```gradle
   apply plugin: 'com.google.gms.google-services'
   ```

### iOS Setup

1. In Firebase Console, click "Add app" → iOS
2. Enter bundle ID: `com.example.quicksell`
3. Download `GoogleService-Info.plist`
4. Open `ios/Runner.xcworkspace` in Xcode
5. Drag `GoogleService-Info.plist` into Xcode
6. Ensure it's added to all targets

### Update Firebase Options

Edit `lib/firebase_options.dart` with your Firebase credentials:

```dart
static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'YOUR_ANDROID_API_KEY',
  appId: 'YOUR_ANDROID_APP_ID',
  messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
  projectId: 'YOUR_PROJECT_ID',
  storageBucket: 'YOUR_STORAGE_BUCKET',
);
```

## Step 4: Firebase Services Configuration

### Enable Authentication

1. Go to Firebase Console → Authentication
2. Click "Get started"
3. Enable "Email/Password" provider
4. (Optional) Enable other providers (Google, Facebook, etc.)

### Create Firestore Database

1. Go to Firebase Console → Firestore Database
2. Click "Create database"
3. Start in test mode (for development)
4. Choose your region
5. Create the database

### Set Up Storage

1. Go to Firebase Console → Storage
2. Click "Get started"
3. Start in test mode
4. Choose your region
5. Create the bucket

### Configure Security Rules

#### Firestore Rules
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      allow read: if request.auth.uid != null;
      allow write: if request.auth.uid == userId;
    }
    
    // Products collection
    match /products/{productId} {
      allow read: if request.auth.uid != null;
      allow create: if request.auth.uid != null;
      allow update, delete: if request.auth.uid == resource.data.sellerId;
    }
    
    // Conversations collection
    match /conversations/{conversationId} {
      allow read, write: if request.auth.uid in [resource.data.userId1, resource.data.userId2];
      
      match /messages/{messageId} {
        allow read, write: if request.auth.uid in [resource.data.senderId, resource.data.receiverId];
      }
    }
  }
}
```

#### Storage Rules
```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /products/{allPaths=**} {
      allow read: if request.auth.uid != null;
      allow write: if request.auth.uid != null;
    }
    
    match /profiles/{userId}/{allPaths=**} {
      allow read: if request.auth.uid != null;
      allow write: if request.auth.uid == userId;
    }
  }
}
```

## Step 5: Run the Application

### Android
```bash
flutter run -d android
```

### iOS
```bash
flutter run -d ios
```

### Web (if configured)
```bash
flutter run -d chrome
```

## Step 6: Development

### Hot Reload
During development, use hot reload for faster iteration:
```bash
flutter run
# Then press 'r' to hot reload
```

### Build APK (Android)
```bash
flutter build apk --release
```

### Build IPA (iOS)
```bash
flutter build ios --release
```

## Troubleshooting

### Common Issues

#### 1. Firebase Initialization Error
- Ensure `google-services.json` (Android) or `GoogleService-Info.plist` (iOS) is properly placed
- Verify Firebase credentials in `firebase_options.dart`

#### 2. Dependency Issues
```bash
flutter clean
flutter pub get
flutter pub run build_runner build
```

#### 3. Build Errors
```bash
flutter clean
flutter pub cache repair
flutter pub get
```

#### 4. Emulator Issues
```bash
# List available emulators
flutter emulators

# Launch emulator
flutter emulators --launch <emulator_id>
```

### Check Logs
```bash
flutter logs
```

## Environment Variables

Create a `.env` file in the project root (optional):
```
FIREBASE_PROJECT_ID=your_project_id
FIREBASE_API_KEY=your_api_key
```

## Testing

### Run Tests
```bash
flutter test
```

### Run Specific Test
```bash
flutter test test/services/firebase_auth_service_test.dart
```

## Performance Optimization

### Build Release Version
```bash
flutter build apk --release
flutter build ios --release
```

### Enable Obfuscation
```bash
flutter build apk --obfuscate --split-debug-info=./symbols
```

## Deployment

### Android Play Store
1. Create a keystore
2. Update `android/key.properties`
3. Build signed APK/AAB
4. Upload to Play Store

### iOS App Store
1. Create App ID in Apple Developer
2. Create provisioning profiles
3. Build signed IPA
4. Upload using Transporter

## Additional Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Dart Documentation](https://dart.dev/guides)
- [Material Design](https://material.io/design)

## Support

For issues or questions:
1. Check the [Flutter FAQ](https://flutter.dev/docs/resources/faq)
2. Search [Stack Overflow](https://stackoverflow.com/questions/tagged/flutter)
3. Open an issue on GitHub
4. Contact support@quicksell.com

---

**Happy coding! 🚀**
