# Gray Day Tracker

A Flutter app for tracking daily habits and keeping streaks going.

## Features

- Create and manage trackers with a name, emoji, and color.
- Track elapsed days and your best streak for each habit.
- Set daily reminder notifications on Android.
- Save your profile name and optional photo.
- Store tracker and profile data locally on the device; there is no cloud sync.

## Requirements

- Flutter SDK with Dart `^3.12.2`
- An Android device/emulator or the Linux desktop target

## Run locally

```sh
flutter pub get
flutter run
```

On Linux desktop, you can select the Linux target explicitly:

```sh
flutter run -d linux
```

Android may prompt for notification and exact-alarm permissions when the app starts. Reminder notifications are currently Android-specific.

## Verify and build

```sh
flutter analyze
flutter test
flutter build apk --release
```

## Project structure

- `lib/screens/` — tracker, detail, and profile screens
- `lib/models/` — tracker and profile data models
- `lib/services/` — local storage and notifications
- `lib/widgets/` — reusable UI components
- `assets/` — app images and icons
- `test/` — Flutter tests
