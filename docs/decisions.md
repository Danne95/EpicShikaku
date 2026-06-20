# Decisions

## 2026-06-20

### Decision

Use Flutter, Dart, Material 3, and Android-first project defaults.

### Reason

The application is intended for Android APK distribution and does not need backend, cloud, or web infrastructure.

### Alternatives considered

Native Android with Kotlin was considered, but Flutter gives a simpler path to cross-platform expansion later.

## 2026-06-20

### Decision

Use Provider for state management.

### Reason

The MVP has one local game controller and simple synchronous updates. Provider keeps state explicit without introducing unnecessary architecture.

### Alternatives considered

Riverpod was considered. It is powerful, but the MVP does not need provider graphs, generated providers, or advanced dependency overrides.

## 2026-06-20

### Decision

Keep puzzle rules in the domain layer and UI behavior in presentation widgets.

### Reason

Separating rules from widgets makes validation easy to test and easier for future AI agents to modify safely.

### Alternatives considered

Putting validation directly in widgets was rejected because it would make tests and future refactors harder.

## 2026-06-20

### Decision

Store puzzles as JSON assets.

### Reason

JSON is easy to review, edit, generate, and ship offline in the APK.

### Alternatives considered

Hard-coded puzzles were rejected because they would be harder to expand into puzzle packs.
