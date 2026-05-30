# Firebase Credentials Setup Guide

This guide shows you how to get your Firebase credentials and update the `firebase_options.dart` file.

## Step 1: Create Firebase Project

### 1.1 Go to Firebase Console
- Visit: https://console.firebase.google.com
- Click **"Create a project"** or **"Add project"**

### 1.2 Enter Project Details
- **Project name**: `QuickSell` (or your preferred name)
- **Enable Google Analytics**: Optional (you can skip)
- Click **"Create project"**

### 1.3 Wait for Project Creation
- Firebase will create your project (takes 1-2 minutes)
- You'll see a success message

---

## Step 2: Register Android App

### 2.1 Add Android App
1. In Firebase Console, click **"Add app"** → **Android**
2. Enter package name: `com.example.quicksell`
3. Click **"Register app"**

### 2.2 Download google-services.json
1. Click **"Download google-services.json"**
2. Save the file to: `quicksell/android/app/google-services.json`

### 2.3 Get Android Credentials
From the Firebase Console, go to **Project Settings** (gear icon):

1. Click **"Project Settings"**
2. Go to **"Service Accounts"** tab
3. Click **"Generate New Private Key"**
4. A JSON file will download - open it and find:
   - `project_id` → YOUR_PROJECT_ID
   - `private_key_id` → Part of YOUR_ANDROID_API_KEY

**Alternative - Get from google-services.json:**
1. Open `android/app/google-services.json`
2. Find these values:
   ```json
   {
     "project_info": {
       "project_id": "YOUR_PROJECT_ID",
       "project_number": "YOUR_MESSAGING_SENDER_ID"
     },
     "client": [
       {
         "client_info": {
           "mobilesdk_app_id": "YOUR_ANDROID_APP_ID"
         },
         "api_key": [
           {
             "current_key": "YOUR_ANDROID_API_KEY"
           }
         ]
       }
     ]
   }
   ```

---

## Step 3: Get Firebase Credentials

### Method 1: From Firebase Console (Recommended)

#### Get API Key:
1. Go to Firebase Console
2. Click **"Project Settings"** (gear icon)
3. Go to **"API keys"** tab
4. You'll see your API keys listed
5. Copy the **Browser API key** or create a new one

#### Get Project ID:
1. In **Project Settings** → **General** tab
2. Find **"Project ID"** field
3. Copy the value

#### Get Messaging Sender ID:
1. In **Project Settings** → **General** tab
2. Find **"Project number"** field
3. This is your **Messaging Sender ID**

#### Get App ID:
1. In **Project Settings** → **General** tab
2. Scroll down to **"Your apps"** section
3. Find your Android app
4. Copy the **App ID** (format: `1:123456789:android:abcdef123456`)

#### Get Storage Bucket:
1. Go to **Storage** in left menu
2. Click **"Get started"** if not already set up
3. Your bucket name appears at the top (format: `projectname.appspot.com`)

---

### Method 2: From google-services.json

Open `android/app/google-services.json` and extract:

```json
{
  "project_info": {
    "project_id": "YOUR_PROJECT_ID",           // ← Project ID
    "project_number": "YOUR_MESSAGING_SENDER_ID" // ← Messaging Sender ID
  },
  "client": [
    {
      "client_info": {
        "mobilesdk_app_id": "YOUR_ANDROID_APP_ID" // ← App ID
      },
      "api_key": [
        {
          "current_key": "YOUR_ANDROID_API_KEY"  // ← API Key
        }
      ]
    }
  ]
}
```

---

## Step 4: Update firebase_options.dart

### 4.1 Open the File
- File: `quicksell/lib/firebase_options.dart`

### 4.2 Find the Android Section
Look for this code:
```dart
static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'YOUR_ANDROID_API_KEY',
  appId: 'YOUR_ANDROID_APP_ID',
  messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
  projectId: 'YOUR_PROJECT_ID',
  storageBucket: 'YOUR_STORAGE_BUCKET',
);
```

### 4.3 Replace with Your Credentials

**Example:**
```dart
static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'AIzaSyDxCvF1234567890abcdefghijklmnopqr',
  appId: '1:123456789:android:abcdef1234567890',
  messagingSenderId: '123456789',
  projectId: 'quicksell-12345',
  storageBucket: 'quicksell-12345.appspot.com',
);
```

### 4.4 Also Update iOS (Optional)
If you plan to build for iOS, update the iOS section similarly:
```dart
static const FirebaseOptions ios = FirebaseOptions(
  apiKey: 'YOUR_IOS_API_KEY',
  appId: 'YOUR_IOS_APP_ID',
  messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
  projectId: 'YOUR_PROJECT_ID',
  storageBucket: 'YOUR_STORAGE_BUCKET',
  iosBundleId: 'com.example.quicksell',
);
```

---

## Step 5: Verify Setup

### 5.1 Check Android Build Files
Verify `android/app/google-services.json` exists

### 5.2 Check firebase_options.dart
Verify all credentials are filled in (no `YOUR_*` placeholders)

### 5.3 Run the App
```bash
flutter pub get
flutter run
```

---

## Complete Example

Here's a complete example of what your `firebase_options.dart` should look like:

```dart
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDxCvF1234567890abcdefghijklmnopqr',
    appId: '1:123456789:web:abcdef1234567890',
    messagingSenderId: '123456789',
    projectId: 'quicksell-12345',
    authDomain: 'quicksell-12345.firebaseapp.com',
    storageBucket: 'quicksell-12345.appspot.com',
    measurementId: 'G-ABCDEF1234',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDxCvF1234567890abcdefghijklmnopqr',
    appId: '1:123456789:android:abcdef1234567890',
    messagingSenderId: '123456789',
    projectId: 'quicksell-12345',
    storageBucket: 'quicksell-12345.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDxCvF1234567890abcdefghijklmnopqr',
    appId: '1:123456789:ios:abcdef1234567890',
    messagingSenderId: '123456789',
    projectId: 'quicksell-12345',
    storageBucket: 'quicksell-12345.appspot.com',
    iosBundleId: 'com.example.quicksell',
  );
}
```

---

## Troubleshooting

### Issue: "Project ID not found"
**Solution**: 
1. Go to Firebase Console
2. Click Project Settings (gear icon)
3. Go to General tab
4. Copy the Project ID

### Issue: "API Key not working"
**Solution**:
1. Go to Firebase Console
2. Click Project Settings
3. Go to API keys tab
4. Make sure the key is enabled
5. Copy the correct key

### Issue: "App ID mismatch"
**Solution**:
1. Make sure package name matches: `com.example.quicksell`
2. Get App ID from google-services.json
3. Format should be: `1:123456789:android:abcdef1234567890`

### Issue: "Storage bucket not found"
**Solution**:
1. Go to Firebase Console
2. Click Storage in left menu
3. If not set up, click "Get started"
4. Bucket name format: `projectname.appspot.com`

---

## Security Notes

⚠️ **Important**: Your API key is now in the source code.

For production:
1. Use environment variables
2. Use Firebase Security Rules
3. Restrict API key usage in Firebase Console
4. Never commit credentials to public repositories

---

## Next Steps

1. ✅ Create Firebase project
2. ✅ Register Android app
3. ✅ Download google-services.json
4. ✅ Get credentials
5. ✅ Update firebase_options.dart
6. ✅ Run `flutter pub get`
7. ✅ Run `flutter run`

---

## Quick Checklist

- [ ] Firebase project created
- [ ] Android app registered
- [ ] google-services.json downloaded to `android/app/`
- [ ] API Key obtained
- [ ] Project ID obtained
- [ ] Messaging Sender ID obtained
- [ ] App ID obtained
- [ ] Storage Bucket obtained
- [ ] firebase_options.dart updated
- [ ] No `YOUR_*` placeholders remain
- [ ] `flutter pub get` runs successfully
- [ ] `flutter run` works

---

## Support

- **Firebase Docs**: https://firebase.google.com/docs
- **Flutter Firebase**: https://firebase.flutter.dev
- **Firebase Console**: https://console.firebase.google.com

---

**Version**: 1.0.0  
**Last Updated**: May 28, 2026  
**Status**: Ready to Use ✅
