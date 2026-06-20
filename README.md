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

Pushes to `main` run tests, build a release APK, and store it as a GitHub Actions artifact.

To publish a GitHub Release with the APK attached, push a version tag such as `v1.0.0`. You can also start the workflow manually from GitHub Actions and enter a release tag. The workflow creates or updates the matching GitHub Release and attaches `EpicShikaku.apk`.
