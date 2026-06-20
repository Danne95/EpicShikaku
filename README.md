# EpicShikaku

EpicShikaku is a fully offline Flutter application for playing Shikaku logic puzzles on Android.

Current version: `1.0.0`

## Requirements

- Flutter stable, preferably Flutter 3.44.0 or newer
- Android SDK configured for Flutter
- Java 17 for Android release builds

## Setup

```sh
flutter pub get
flutter run
```

Run tests:

```sh
flutter test
```

Build an APK:

```sh
flutter build apk --release
```

## Project Shape

- `lib/app` contains the app shell and Material 3 theme.
- `lib/core` contains shared models, services, utilities, and constants.
- `lib/features/puzzle` contains the puzzle feature split into domain, application, presentation, and data layers.
- `assets/puzzles` contains JSON puzzle definitions for future curated packs.
- New games currently use an offline rectangle-partition generator.
- `docs` contains architecture, decisions, game rules, user flows, roadmap, and AI-agent context.

## Android Builds

Every push to `main` runs tests, builds a release APK, uploads an Actions artifact, and updates the GitHub Release matching the version in `pubspec.yaml`.

For the current version, pushes update release `v1.0.0` and replace its `EpicShikaku.apk` asset. Increase the version in `pubspec.yaml` when you want the next push to create a new release.
