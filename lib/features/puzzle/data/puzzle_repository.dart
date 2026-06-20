import 'package:shikaku_puzzle/features/puzzle/domain/puzzle.dart';

/// Provides puzzle definitions to the application layer.
abstract class PuzzleRepository {
  /// Loads the default puzzle.
  Future<Puzzle> loadDefaultPuzzle();
}
