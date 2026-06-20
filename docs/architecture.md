# Architecture

EpicShikaku uses a simple layered architecture designed for a small offline Flutter application.

## Layers

### App

`lib/app` contains the application shell, top-level widget, app-level settings state, routing entry point, and theme configuration.

### Core

`lib/core` contains shared code that does not belong to one feature:

- `models`: reusable value objects.
- `services`: reusable app-level services.
- `utilities`: helper functions with no feature ownership.
- `constants`: shared constants.

### Feature: Puzzle

`lib/features/puzzle` owns the playable Shikaku experience.

- `domain`: puzzle rules, entities, and validation logic.
- `application`: mutable game state and orchestration.
- `presentation`: Flutter widgets and screens.
- `data`: generated puzzle and JSON asset repositories.

### Feature: Settings

`lib/features/settings` owns the settings presentation. Settings state and persistence live under `lib/app` because theme, vibration, and board size are app-level concerns.

## Dependency Direction

Dependencies point inward:

`presentation -> application -> domain`

`data -> domain`

Settings use `settings presentation -> app settings controller -> app settings repository`.

The domain layer does not depend on Flutter UI widgets or state management packages. This keeps puzzle rules testable and easy to reuse.

PuzzleGenerator lives in the puzzle domain layer. It creates a non-overlapping rectangle partition, keeps generated region areas between 2 and 12, and places one clue per rectangle. This ensures generated boards have at least one valid solution.

## State Management

The app uses Provider for `PuzzleController` and `SettingsController`. `main.dart` loads persisted settings before creating the app, so the first generated board uses the saved board size. Provider is enough because state is local, small, and does not require complex dependency graphs.
