# Architecture

Shikaku Puzzle uses a simple layered architecture designed for a small offline Flutter application.

## Layers

### App

`lib/app` contains the application shell, top-level widget, routing entry point, and theme configuration.

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
- `data`: loading puzzle JSON from assets.

## Dependency Direction

Dependencies point inward:

`presentation -> application -> domain`

`data -> domain`

The domain layer does not depend on Flutter UI widgets or state management packages. This keeps puzzle rules testable and easy to reuse.

## State Management

The app uses Provider with a single `PuzzleController`. Provider is enough for the MVP because state is local, synchronous, and small. More complex state management would add ceremony without solving a real problem.
