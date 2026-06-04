# QuickSell

A Flutter-based local marketplace app for buying and selling items in your community.

## Features

- ✅ User Authentication (Firebase)
- ✅ Product Listings with Images
- ✅ Real-time Search & Filtering
- ✅ Chat System
- ✅ Product Sharing
- ✅ User Profiles

## Tech Stack

- **Flutter 3.12.0+** - Mobile framework
- **Firebase** - Authentication & Database
- **Riverpod** - State management
- **ImgBB** - Image hosting

## Quick Start

```bash
# Install dependencies
flutter pub get

# Run the app
flutter run
```

## Setup

1. **Firebase Configuration**
   - Create project at [Firebase Console](https://console.firebase.google.com)
   - Enable Email/Password authentication
   - Add `google-services.json` to `android/app/`
   - Update `lib/firebase_options.dart`

2. **ImgBB Setup**
   - Get API key from [ImgBB](https://imgbb.com)
   - Update in `lib/services/imgbb_storage_service.dart`

## Build APK

```bash
flutter build apk --release
```

APK will be at: `build/app/outputs/flutter-apk/app-release.apk`

## Support

- GitHub: [Issues](https://github.com/Eyoel1/Quicksell/issues)
- Email: support@quicksell.com

---

**QuickSell** - Making local commerce simple 🚀
