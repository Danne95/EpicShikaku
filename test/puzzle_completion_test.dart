import 'package:flutter_test/flutter_test.dart';
import 'package:shikaku_puzzle/features/puzzle/domain/puzzle.dart';
import 'package:shikaku_puzzle/features/puzzle/domain/puzzle_region.dart';
import 'package:shikaku_puzzle/features/puzzle/domain/puzzle_validator.dart';

/// Verifies puzzle completion detection.
void main() {
  group('Win condition', () {
    test('detects a completed puzzle', () {
      final puzzle = Puzzle.fromJson({
        'width': 5,
        'height': 5,
        'clues': [
          {'x': 0, 'y': 0, 'value': 4},
          {'x': 3, 'y': 0, 'value': 6},
          {'x': 1, 'y': 2, 'value': 6},
          {'x': 0, 'y': 3, 'value': 3},
          {'x': 4, 'y': 4, 'value': 6},
        ],
      });

      final isComplete = const PuzzleValidator().isPuzzleComplete(
        puzzle: puzzle,
        acceptedRegions: const [
          PuzzleRegion(left: 0, top: 0, right: 1, bottom: 1),
          PuzzleRegion(left: 2, top: 0, right: 4, bottom: 1),
          PuzzleRegion(left: 0, top: 2, right: 0, bottom: 4),
          PuzzleRegion(left: 1, top: 2, right: 2, bottom: 4),
          PuzzleRegion(left: 3, top: 2, right: 4, bottom: 4),
        ],
      );

      expect(isComplete, isTrue);
    });

    test('rejects incomplete coverage', () {
      final puzzle = Puzzle.fromJson({
        'width': 2,
        'height': 2,
        'clues': [
          {'x': 0, 'y': 0, 'value': 2},
        ],
      });

      final isComplete = const PuzzleValidator().isPuzzleComplete(
        puzzle: puzzle,
        acceptedRegions: const [
          PuzzleRegion(left: 0, top: 0, right: 1, bottom: 0),
        ],
      );

      expect(isComplete, isFalse);
    });
  });
}
