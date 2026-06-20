import 'package:shikaku_puzzle/core/models/cell_position.dart';
import 'package:shikaku_puzzle/features/puzzle/domain/clue.dart';

/// A Shikaku puzzle definition loaded from JSON.
class Puzzle {
  /// Creates a puzzle.
  const Puzzle({
    required this.width,
    required this.height,
    required this.clues,
  });

  /// Creates a puzzle from JSON.
  factory Puzzle.fromJson(Map<String, Object?> json) {
    final rawClues = json['clues']! as List<Object?>;

    return Puzzle(
      width: json['width']! as int,
      height: json['height']! as int,
      clues: rawClues
          .map((item) => Clue.fromJson(Map<String, Object?>.from(item! as Map)))
          .toList(growable: false),
    );
  }

  /// Puzzle width in cells.
  final int width;

  /// Puzzle height in cells.
  final int height;

  /// Numbered clues inside the puzzle.
  final List<Clue> clues;

  /// Total cell count.
  int get cellCount => width * height;

  /// Returns whether a position is inside the puzzle bounds.
  bool containsPosition(CellPosition position) {
    return position.x >= 0 &&
        position.y >= 0 &&
        position.x < width &&
        position.y < height;
  }

  /// Returns the clue at the given position, if one exists.
  Clue? clueAt(CellPosition position) {
    for (final clue in clues) {
      if (clue.position == position) {
        return clue;
      }
    }

    return null;
  }
}
