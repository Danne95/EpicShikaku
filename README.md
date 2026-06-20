# EpicShikaku

EpicShikaku is a fully offline Flutter application for playing Shikaku logic puzzles on Android.

Current version: `1.0.0`

## Requirements

- Flutter stable, preferably Flutter 3.44.0 or newer
- Android SDK configured for Flutter

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

## GitHub Releases

The enabled Android workflow at `.github/workflows/android_release.yml` builds a release APK, runs tests, and uploads the APK as an artifact on pushes to `main`. It can also be started manually from the GitHub Actions page.

To publish GitHub Releases later, extend the workflow by adding release creation after the APK build. Common options are `softprops/action-gh-release` for tag-triggered releases or the GitHub CLI for scripted release notes.
