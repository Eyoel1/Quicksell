# Firebase Quick Setup - 5 Minutes

## TL;DR - Quick Steps

### 1. Create Firebase Project (2 min)
```
https://console.firebase.google.com
→ Create project → Name: QuickSell → Create
```

### 2. Register Android App (1 min)
```
Add app → Android
Package name: com.example.quicksell
→ Register → Download google-services.json
```

### 3. Save Configuration File (30 sec)
```
Save google-services.json to:
quicksell/android/app/google-services.json
```

### 4. Get Your Credentials (1 min)

Open `android/app/google-services.json` and find:

```json
{
  "project_info": {
    "project_id": "YOUR_PROJECT_ID",           ← Copy this
    "project_number": "YOUR_MESSAGING_SENDER_ID" ← Copy this
  },
  "client": [
    {
      "client_info": {
        "mobilesdk_app_id": "YOUR_ANDROID_APP_ID" ← Copy this
      },
      "api_key": [
        {
          "current_key": "YOUR_ANDROID_API_KEY"  ← Copy this
        }
      ]
    }
  ]
}
```

### 5. Update firebase_options.dart (30 sec)

**File**: `quicksell/lib/firebase_options.dart`

Replace this:
```dart
static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'YOUR_ANDROID_API_KEY',
  appId: 'YOUR_ANDROID_APP_ID',
  messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
  projectId: 'YOUR_PROJECT_ID',
  storageBucket: 'YOUR_STORAGE_BUCKET',
);
```

With your values:
```dart
static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'AIzaSyDxCvF1234567890abcdefghijklmnopqr',
  appId: '1:123456789:android:abcdef1234567890',
  messagingSenderId: '123456789',
  projectId: 'quicksell-12345',
  storageBucket: 'quicksell-12345.appspot.com',
);
```

### 6. Get Storage Bucket (30 sec)

In Firebase Console:
```
Storage → Get started → Copy bucket name
Format: projectname.appspot.com
```

### 7. Test (30 sec)
```bash
flutter pub get
flutter run
```

---

## Credential Mapping

| Placeholder | Source | Example |
|------------|--------|---------|
| `YOUR_ANDROID_API_KEY` | `google-services.json` → `api_key[0].current_key` | `AIzaSyDxCvF...` |
| `YOUR_ANDROID_APP_ID` | `google-services.json` → `mobilesdk_app_id` | `1:123456789:android:abc...` |
| `YOUR_MESSAGING_SENDER_ID` | `google-services.json` → `project_number` | `123456789` |
| `YOUR_PROJECT_ID` | `google-services.json` → `project_id` | `quicksell-12345` |
| `YOUR_STORAGE_BUCKET` | Firebase Console → Storage | `quicksell-12345.appspot.com` |

---

## Common Issues

### ❌ "Can't find google-services.json"
✅ Make sure it's in: `quicksell/android/app/google-services.json`

### ❌ "Invalid API Key"
✅ Copy from `google-services.json` → `api_key[0].current_key`

### ❌ "Project ID not found"
✅ Copy from `google-services.json` → `project_id`

### ❌ "App won't run"
✅ Check all credentials are filled (no `YOUR_*` placeholders)

---

## Done! ✅

Your Firebase is now configured. Next:
1. Run `flutter run`
2. Test authentication
3. Test product creation
4. Read full guides for more details

---

**Need help?** Read `FIREBASE_CREDENTIALS_GUIDE.md` for detailed steps.
