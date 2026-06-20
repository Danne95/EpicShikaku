# Flows

## App Startup

1. `main.dart` starts Flutter.
2. `ShikakuPuzzleApp` creates the Material 3 app shell.
3. `PuzzleScreen` creates a `PuzzleController`.
4. The controller loads the default puzzle from JSON assets.

## Puzzle Loading

1. `AssetPuzzleRepository` reads a JSON puzzle file from `assets/puzzles`.
2. JSON is decoded into a `Puzzle`.
3. The controller clears previous state and exposes the puzzle to the UI.

## Rectangle Selection

1. The player touches a starting cell.
2. The player drags to another cell.
3. The UI highlights the current rectangular selection.
4. Releasing the drag submits the rectangle to the controller.

## Validation

1. The controller sends the selected rectangle to `PuzzleValidator`.
2. The validator checks bounds, clue count, area, and overlap.
3. Valid rectangles are added to completed regions.
4. Invalid rectangles are rejected.

## Completion Flow

1. After accepting a rectangle, the controller checks whether every cell is covered.
2. If the puzzle is complete, the controller marks the puzzle as completed.
3. The UI displays a completion dialog.
