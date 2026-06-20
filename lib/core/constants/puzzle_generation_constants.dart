/// Limits and defaults for locally generated puzzles.
class PuzzleGenerationConstants {
  const PuzzleGenerationConstants._();

  /// Default width and height for square puzzle boards.
  static const defaultBoardSize = 5;

  /// Smallest supported square board size.
  static const minimumBoardSize = 4;

  /// Largest supported square board size.
  static const maximumBoardSize = 12;

  /// Smallest area allowed for a generated clue region.
  static const minimumRegionArea = 2;

  /// Largest area allowed for a generated clue region.
  static const maximumRegionArea = 12;

  /// Minimum cell gap preferred between generated clues.
  static const preferredClueGap = 2;
}
