import 'package:flutter_test/flutter_test.dart';
import 'package:shikaku_puzzle/core/models/cell_position.dart';
import 'package:shikaku_puzzle/features/puzzle/domain/puzzle.dart';
import 'package:shikaku_puzzle/features/puzzle/domain/puzzle_region.dart';

/// Verifies core puzzle model behavior.
void main() {
  group('Puzzle model', () {
    test('parses puzzle JSON', () {
      final puzzle = Puzzle.fromJson({
        'width': 5,
        'height': 5,
        'clues': [
          {'x': 0, 'y': 0, 'value': 4},
        ],
      });

      expect(puzzle.width, 5);
      expect(puzzle.height, 5);
      expect(puzzle.cellCount, 25);
      expect(puzzle.clues.single.value, 4);
    });

    test('finds clues by position', () {
      final puzzle = Puzzle.fromJson({
        'width': 5,
        'height': 5,
        'clues': [
          {'x': 2, 'y': 1, 'value': 3},
        ],
      });

      expect(puzzle.clueAt(const CellPosition(x: 2, y: 1))?.value, 3);
      expect(puzzle.clueAt(const CellPosition(x: 0, y: 0)), isNull);
    });

    test('calculates region area and overlap', () {
      const first = PuzzleRegion(left: 0, top: 0, right: 1, bottom: 1);
      const second = PuzzleRegion(left: 1, top: 1, right: 2, bottom: 2);
      const third = PuzzleRegion(left: 3, top: 3, right: 4, bottom: 4);

      expect(first.area, 4);
      expect(first.overlaps(second), isTrue);
      expect(first.overlaps(third), isFalse);
    });
  });
}
