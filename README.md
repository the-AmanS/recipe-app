# Firebase Recipe App 🍳

A Flutter mobile app functioning as a personal recipe book with Firebase Firestore integration.

## Features

- Create, read, update, and delete recipes
- Real-time updates from Firebase
- Material 3 design
- Responsive UI

## Firebase Setup

### 1. Create a Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/).
2. Click **Add project** and follow the setup wizard.
3. Register your app with a package name (e.g., `com.example.firebase_recipe_app`).
4. Download the configuration files:
   - `google-services.json` for Android
   - `GoogleService-Info.plist` for iOS

### 2. Add Firebase Config Files to Flutter Project

- For Android: Place `google-services.json` in `android/app/`
- For iOS: Place `GoogleService-Info.plist` in `ios/Runner/`

### 3. Create Flutter Project

Run the following command in your terminal:

```bash
flutter create .
```

### 4. Update Android Project

1. Open `android/build.gradle` and add in `dependencies`:

```gradle
classpath 'com.google.gms:google-services:4.4.0'
```

2. Open `android/app/build.gradle` and add at the bottom:

```gradle
apply plugin: 'com.google.gms.google-services'
```

### 5. Add Firebase Packages

Update your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^3.24.0
  firebase_auth: ^5.15.0
  cloud_firestore: ^5.21.0
  firebase_storage: ^12.5.0
  firebase_storage_web: ^12.5.0
```

Run:

```bash
flutter pub get
```

### 6. Initialize Firebase in Flutter

Update `main.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}
```

### 7. Run the App

1. Connect a device or start an emulator.
2. Run the project:

```bash
flutter run
```

Your Flutter app is now connected to Firebase and ready to use.

