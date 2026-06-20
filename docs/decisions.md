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

Keep JSON puzzle assets for future curated puzzle packs.

### Reason

JSON is easy to review, edit, generate, and ship offline in the APK. Current gameplay uses generated puzzles, while JSON assets remain available for future puzzle packs.

### Alternatives considered

Hard-coded puzzles were rejected because they would be harder to expand into puzzle packs.

## 2026-06-20

### Decision

Add settings as an app-level controller and use shared preferences for local persistence.

### Reason

Theme and vibration affect the whole application and should survive app restarts without introducing backend or cloud services.

### Alternatives considered

Keeping settings only in memory was simpler, but it would reset user preferences every time the app restarts.

## 2026-06-20

### Decision

Expose settings from a cog icon in the top app bar.

### Reason

The app has one primary activity: solving the current puzzle. Moving settings to the top bar keeps the board as the main surface and removes bottom navigation chrome from gameplay.

### Alternatives considered

Bottom navigation was used temporarily when settings were introduced. It was removed because settings are secondary and do not need equal weight with the puzzle.

## 2026-06-20

### Decision

Keep puzzle board colors in explicit light and dark board color schemes.

### Reason

The board needs different clue contrast and region palettes in light and dark modes. Centralizing these colors in PuzzleUiConstants makes future color sets easier to add without spreading palette decisions across widgets.

### Alternatives considered

Deriving every board color from the Material color scheme was considered, but hand-picked region palettes give clearer contrast for puzzle cells.

## 2026-06-20

### Decision

Generate new puzzles by recursively splitting the board into rectangles.

### Reason

A rectangle partition guarantees full coverage without overlap. Placing one clue with the matching area inside each rectangle produces a fully offline puzzle with at least one valid solution.

### Alternatives considered

Selecting arbitrary clue positions and searching for a solution was considered, but it adds avoidable solver complexity for the first generator.

## 2026-06-20

### Decision

Expose a persisted square board-size setting with a range of 4 to 12.

### Reason

The range gives players meaningful variation while keeping cells and clue values usable on a phone screen. The selected size is applied to every newly generated puzzle.

### Alternatives considered

Allowing unrestricted sizes was considered, but it would create impractical grid density and reduce clue readability on Android devices.

## 2026-06-20

### Decision

Constrain generated clue areas to 2 through 12 and prefer spaced clue positions.

### Reason

Area-one regions are trivial, very large regions create unhelpful high values, and adjacent clues reduce visual clarity. Balanced splits and spacing-aware placement make generated boards more readable and varied.

### Alternatives considered

Fully random rectangle splits were used initially, but they produced too many area-one and oversized clues.

## 2026-06-20

### Decision

Show completion feedback in the puzzle screen instead of a confirmation dialog.

### Reason

Confetti and an immediate New puzzle button make completion feel rewarding while keeping the player in the game flow.

### Alternatives considered

A modal completion dialog was used initially, but it added an unnecessary confirmation step before the next game.
