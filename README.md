# Todo List App

## Project Overview
This is a Flutter todo app for managing daily tasks. It lets you add, edit, and delete tasks, set priorities and due dates, organize work with categories and lists, and track progress with basic stats. The app stores data locally on the device, so it works offline.

## Features
- Add, edit, and delete tasks
- Mark tasks as complete or incomplete
- Set task priority, category, and due date
- Organize tasks with lists and subtasks
- Search tasks and filter them by status
- View simple stats and progress charts
- Use onboarding, profile, and settings screens
- Switch between light, dark, and system themes
- Save data locally with Hive

## Requirements
- Flutter 3.38.7 or later
- Dart 3.10.7 or later
- Android SDK 21+ for Android development
- Xcode for iOS and macOS development

## Installation
1. Clone the repository.
2. Open the project folder.
3. Run `flutter pub get` to install dependencies.

## How to Run
1. Start an emulator or connect a device.
2. Run `flutter run`.
3. Use `flutter run -d chrome` for web or `flutter run -d windows` for Windows.
4. Run `flutter test` to check the tests.
5. Run `flutter analyze` to check for code issues.

## Build and Release
Use these commands from the project root when you want a release build.

### Android APK
```bash
flutter build apk --release
```

### Android App Bundle (Play Store)
```bash
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
```

### Windows
```bash
flutter build windows --release
```

For Android signing, use `android/key.properties.example` as a template and add your own keystore details before creating final release files.

## Usage
1. Open the app.
2. Complete the onboarding screen if it appears on first launch.
3. Add a task from the home screen.
4. Enter a title and choose the category, priority, and due date.
5. Tap a task to open its details and edit or delete it if needed.
6. Use search, filters, stats, profile, and settings from the app navigation.

## Troubleshooting
- If packages are missing, run `flutter clean` and then `flutter pub get`.
- If the app does not start, make sure an emulator is running or a device is connected.
- If Android build errors appear, check that the Android SDK is installed correctly.
- If tests fail after changes, run `flutter test` again after fixing the code.

