# Todo List App

[![Flutter](https://img.shields.io/badge/Flutter-3.3%2B-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.3%2B-0175C2?logo=dart)](https://dart.dev)
[![Platforms](https://img.shields.io/badge/Platforms-Android%20%7C%20iOS%20%7C%20Web%20%7C%20Windows%20%7C%20Linux%20%7C%20macOS-2ea44f)](#supported-platforms)
[![Download APK](https://img.shields.io/badge/Download-Latest%20APK-orange)](https://github.com/Remanth1/Flutter-Todo-List-App/raw/main/apk/Tasks-app.apk)

A production-style Flutter to-do application with offline-first local storage, clean project layering, task organization, reminders, and progress analytics.

## Table of Contents
- [Overview](#overview)
- [Feature Set](#feature-set)
- [Supported Platforms](#supported-platforms)
- [Project Architecture](#project-architecture)
- [Project Structure](#project-structure)
- [Tech Stack](#tech-stack)
- [Getting Started](#getting-started)
- [Run Commands](#run-commands)
- [Testing and Analysis](#testing-and-analysis)
- [Build and Release](#build-and-release)
- [Android Signing Setup](#android-signing-setup)
- [Scripts](#scripts)
- [Data Storage](#data-storage)
- [Usage Flow](#usage-flow)
- [Troubleshooting](#troubleshooting)
- [Roadmap](#roadmap)
- [Contributing](#contributing)
- [License](#license)

## Overview
This app is built for personal task management with a focus on speed and local reliability.

Primary goals:
- Keep task management simple and fast.
- Support real-world planning with priorities, due dates, recurrence, reminders, and subtasks.
- Provide meaningful statistics for productivity tracking.
- Work fully offline with local persistence using Hive.

## Feature Set

### Task Management
- Create, edit, and delete tasks.
- Mark tasks complete or incomplete.
- Pin important tasks.
- Reorder tasks and subtasks.
- Add subtasks with parent-child relationships.
- Undo deletion from snackbar actions.

### Organization
- Group tasks into task lists.
- Add tags and filter by selected tag.
- Search tasks from the main board.
- Filter tasks by status and date group:
	- all
	- today
	- tomorrow
	- upcoming
	- overdue
	- completed
	- archived

### Planning and Scheduling
- Set due dates.
- Set priority levels: low, medium, high.
- Set recurrence: none, daily, weekly, custom interval days.
- Configure reminder lead time (minutes before due time).
- Use timezone-aware local notifications.

### Insights and Productivity
- See all-time metrics:
	- completed tasks
	- active tasks
	- current streak
	- completion percentage
- Review charts for:
	- completed tasks over the last 7 days
	- priority distribution
	- overall completion split
- Read generated insight summaries on the stats screen.

### User Experience
- Onboarding flow.
- Splash screen entry.
- Profile screen.
- Settings screen.
- Stats screen.
- Light, dark, and system theme modes.

## Supported Platforms
The repository includes platform folders and build configurations for:
- Android
- iOS
- Web
- Windows
- Linux
- macOS

## Project Architecture
The project follows a clean layered structure.

- domain: entities, repository contracts, and use cases.
- data: local data sources and repository implementations.
- presentation: screens, widgets, and state notifiers/providers.
- core: app-wide concerns such as routing, dependency wiring, constants, theme, and utilities.

State management uses Riverpod. Navigation uses go_router. Persistence uses Hive.

## Project Structure
```text
lib/
	core/
		constants/   # Hive box names and shared constants
		di/          # Riverpod providers and dependency wiring
		router/      # go_router route definitions
		theme/       # App theme configuration
		utils/       # Utilities such as notifications
	data/
		datasources/ # Local data adapters and persistence entry points
		models/      # Storage models/records
		repositories/# Repository implementations
	domain/
		entities/    # Core business entities (Task, filters, etc.)
		repositories/# Repository contracts
		usecases/    # Business operations
	presentation/
		tasks/       # Task board screens, providers, widgets
		stats/       # Statistics screens and providers
		user/        # Splash, onboarding, profile, settings
```

## Tech Stack

### Core
- Flutter
- Dart SDK >= 3.3.0 < 4.0.0
- Material UI

### App Dependencies
- flutter_riverpod
- hive_flutter
- go_router
- fl_chart
- flutter_local_notifications
- timezone
- intl
- google_fonts
- lottie
- uuid

### Development Dependencies
- flutter_test
- flutter_lints
- hive_generator
- build_runner
- flutter_launcher_icons

## Getting Started

### Prerequisites
- Flutter SDK installed and available in PATH.
- Dart SDK compatible with the Flutter version in use.
- For Android: Android SDK and an emulator/device.
- For iOS/macOS builds: Xcode and CocoaPods on macOS.

### Installation
1. Clone the repository.
2. Open the project root.
3. Install dependencies:

```bash
flutter pub get
```

## Run Commands

### Default
```bash
flutter run
```

### Platform-specific examples
```bash
flutter run -d chrome
flutter run -d windows
flutter run -d linux
flutter run -d android
```

Tip: use flutter devices to list valid device IDs.

## Testing and Analysis
Run these before creating pull requests or release builds.

```bash
flutter analyze
flutter test
```

## Build and Release
Use these from the project root.

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

### Linux
```bash
flutter build linux --release
```

## Android Signing Setup
To sign Android release builds:

1. Copy android/key.properties.example to android/key.properties.
2. Fill these fields in android/key.properties:
	 - keyAlias
	 - keyPassword
	 - storeFile
	 - storePassword
3. Build again with:

```bash
flutter build apk --release
```

APK download for visitors:
- https://github.com/Remanth1/Flutter-Todo-List-App/raw/main/apk/Tasks-app.apk

## Scripts
Utilities are available in scripts/ for icon management and APK validation.

- scripts/generate_icon.ps1
	- Windows PowerShell helper to run flutter_launcher_icons.
- scripts/generate_icon.sh
	- Shell script alternative for Unix-like systems.
- scripts/generate_icon.py
	- Python utility for icon generation workflow.
- scripts/verify_apk_icon.py
	- Checks whether launcher icon resources are present in the generated APK.

## Data Storage
The app stores data locally using Hive.

Configured boxes:
- tasks_box_v2
- task_lists_box_v2
- settings_box_v1
- user_box_v1

Storage behavior:
- Offline-first by design.
- No remote backend required.
- Data remains on the user device unless app storage is cleared or app is uninstalled.

## Usage Flow
1. Open the app.
2. Complete onboarding when shown.
3. Add a task from the home board.
4. Set optional due date, priority, tags, recurrence, and reminders.
5. Use filters/search/tags to focus on relevant tasks.
6. Track progress from the stats screen.
7. Manage profile and app preferences from profile/settings.

## Troubleshooting
- Dependencies fail to resolve:
	- Run flutter clean
	- Run flutter pub get
- Build issues after SDK changes:
	- Run flutter doctor
	- Re-run flutter pub get
- Notification problems:
	- Verify OS notification permissions.
	- Check device battery optimization settings.
- Android release build/signing errors:
	- Re-check android/key.properties values and keystore path.
- App not launching:
	- Confirm emulator is running or a physical device is connected.

## Roadmap
Potential future improvements:
- Data export/import (backup and restore)
- Optional cloud sync
- More advanced analytics and reporting
- Collaboration/shared lists

## Contributing
Contributions are welcome.

Recommended contribution workflow:
1. Fork the repository.
2. Create a feature branch.
3. Run analysis and tests locally.
4. Open a pull request with clear change notes.

Quality checks before PR:
- flutter analyze
- flutter test

## License
No license file is currently present in the repository root.
If you plan to open-source distribution terms, add a license file and update this section.

