# Android Development Guide - QuickSell

Due to Firebase web package compatibility issues, we recommend developing on Android emulator or physical device instead of Chrome.

## Why Android Instead of Chrome?

✅ **Android Benefits**:
- Full Firebase support
- All features work (camera, location, storage)
- Better testing experience
- Closer to production environment

❌ **Chrome Issues**:
- Firebase web packages have compatibility issues
- Some features don't work (camera, location)
- Not ideal for mobile app testing

## Setup Android Emulator

### Option 1: Android Studio (Recommended)

1. **Open Android Studio**
   - Launch Android Studio

2. **Open Device Manager**
   - Click: Tools → Device Manager

3. **Create Virtual Device**
   - Click: Create Device
   - Select: Pixel 6 (or any device)
   - Select: Android 13 or higher
   - Click: Finish

4. **Start Emulator**
   - Click: Play button next to device
   - Wait for emulator to start (1-2 minutes)

### Option 2: Command Line

```bash
# List available emulators
flutter emulators

# Launch emulator
flutter emulators --launch emulator-5554
```

## Run QuickSell on Android

### Step 1: Start Emulator
```bash
# Android Studio: Click play button
# Or command line:
flutter emulators --launch emulator-5554
```

### Step 2: Run App
```bash
cd quicksell
flutter run
```

### Step 3: Select Device
When prompted, select the Android emulator.

## Troubleshooting

### Emulator Won't Start
```bash
# Check if emulator exists
flutter emulators

# If not, create one in Android Studio
# Tools → Device Manager → Create Device
```

### App Won't Install
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter run
```

### Firebase Errors
- Make sure `google-services.json` is in `android/app/`
- Verify Firebase credentials in `lib/firebase_options.dart`

## Testing Features

Once running on Android emulator, you can test:

✅ **Authentication**
- Sign up
- Login
- Password reset

✅ **Products**
- Create product
- Upload images to ImgBB
- View product details

✅ **Chat**
- Send messages
- View conversations

✅ **Location**
- Get current location
- Find nearby products

✅ **Camera**
- Take photos
- Pick from gallery

## Performance Tips

1. **Allocate More RAM**
   - Android Studio → Settings → Emulator
   - Increase RAM to 4GB or more

2. **Use Snapshots**
   - Save emulator state
   - Faster startup next time

3. **Close Unnecessary Apps**
   - Free up system resources
   - Better emulator performance

## Physical Device (Alternative)

If you have an Android phone:

1. **Enable Developer Mode**
   - Settings → About Phone
   - Tap Build Number 7 times
   - Go back to Settings → Developer Options
   - Enable USB Debugging

2. **Connect Phone**
   - Connect via USB cable
   - Allow USB debugging on phone

3. **Run App**
   ```bash
   flutter run
   ```

## Next Steps

1. Start Android emulator
2. Run `flutter run`
3. Test authentication
4. Test product creation
5. Test image upload
6. Test chat features

## Useful Commands

```bash
# List devices
flutter devices

# Run on specific device
flutter run -d emulator-5554

# Run with verbose output
flutter run -v

# Run in release mode
flutter run --release
```

## Documentation

- [Flutter Android Setup](https://flutter.dev/docs/get-started/install/linux#android-setup)
- [Android Emulator](https://developer.android.com/studio/run/emulator)
- [Firebase Android Setup](https://firebase.flutter.dev/docs/overview)

---

**Status**: Ready for Android Development ✅  
**Next**: Start emulator and run `flutter run`
