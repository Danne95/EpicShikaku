# Flows

## App Startup

1. `main.dart` initializes Flutter bindings.
2. `SettingsController` loads persisted theme, vibration, and board-size settings.
3. `ShikakuPuzzleApp` creates the Material 3 app shell with those settings.
4. `PuzzleController` requests a generated puzzle using the saved board size.
5. `AppShell` shows the puzzle screen by default.

## Puzzle Loading

1. `GeneratedPuzzleRepository` requests a new board from `PuzzleGenerator`.
2. The generator partitions the board into non-overlapping rectangles.
3. The generator keeps region areas from 2 through 12 and places one clue in each rectangle using its area as the clue value.
4. The controller clears previous state and exposes the puzzle to the UI.

## New Puzzle Flow

1. The player presses the refresh icon in the top app bar or the New puzzle button after completion.
2. `PuzzleController` requests a new generated puzzle.
3. The current accepted regions and completion state are cleared.

## Rectangle Selection

1. The player touches a starting cell.
2. The player drags to another cell.
3. The UI highlights the current rectangular selection.
4. Releasing the drag submits the rectangle to the controller.

## Region Removal

1. The player taps an already accepted rectangle.
2. The board sends the tapped cell position to `PuzzleController`.
3. The controller removes the accepted region containing that cell.
4. Completion state is cleared because the board is no longer fully covered.

## Validation

1. The controller sends the selected rectangle to `PuzzleValidator`.
2. The validator checks bounds, clue count, area, and overlap.
3. Valid rectangles are added to completed regions.
4. Invalid rectangles are rejected.

## Completion Flow

1. After accepting a rectangle, the controller checks whether every cell is covered.
2. If the puzzle is complete, the controller marks the puzzle as completed.
3. If vibration is enabled, the UI triggers completion haptic feedback.
4. The board plays a short confetti effect and shows a New puzzle button below the board.

## Settings Flow

1. The player opens settings from the cog icon in the top app bar.
2. The player toggles dark mode, vibration, or sound.
3. The player can enter a square board size from 4 to 12 or adjust it with the minus and plus controls.
4. Changing board size persists the value and starts a new generated puzzle.
5. `SettingsController` updates immediately and persists values with shared preferences.
6. The Material app rebuilds with the selected theme mode.

## Direct APK Update Flow

1. The player opens settings from the cog icon in the top app bar.
2. The player taps Check for updates.
3. `AppUpdateController` asks `AppUpdateService` to compare the installed Android version with the latest public GitHub release.
4. The latest release must contain an accepted APK asset, either labeled `EpicShikaku.apk` or named `EpicShikaku.apk` / `app-release.apk`.
5. If a newer version exists, the player can download the APK.
6. After download, the player taps Install update.
7. If Android has not granted install-from-this-source permission to EpicShikaku, the app opens the relevant Android settings screen.
8. Once permission is available, the app hands the APK to Android's package installer and the player confirms the update.
