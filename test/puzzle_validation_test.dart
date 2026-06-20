import 'package:flutter_test/flutter_test.dart';
import 'package:shikaku_puzzle/features/puzzle/domain/puzzle.dart';
import 'package:shikaku_puzzle/features/puzzle/domain/puzzle_region.dart';
import 'package:shikaku_puzzle/features/puzzle/domain/puzzle_validator.dart';

/// Verifies Shikaku selection validation rules.
void main() {
  late Puzzle puzzle;
  late PuzzleValidator validator;

  setUp(() {
    puzzle = Puzzle.fromJson({
      'width': 5,
      'height': 5,
      'clues': [
        {'x': 0, 'y': 0, 'value': 4},
        {'x': 3, 'y': 0, 'value': 6},
      ],
    });
    validator = const PuzzleValidator();
  });

  group('PuzzleValidator', () {
    test('accepts a region with one clue and matching area', () {
      final result = validator.validateRegion(
        puzzle: puzzle,
        candidate: const PuzzleRegion(left: 0, top: 0, right: 1, bottom: 1),
        acceptedRegions: const [],
      );

      expect(result.isValid, isTrue);
    });

    test('rejects a region with the wrong area', () {
      final result = validator.validateRegion(
        puzzle: puzzle,
        candidate: const PuzzleRegion(left: 0, top: 0, right: 0, bottom: 0),
        acceptedRegions: const [],
      );

      expect(result.isValid, isFalse);
      expect(result.message, contains('area'));
    });

    test('rejects a region with more than one clue', () {
      final result = validator.validateRegion(
        puzzle: puzzle,
        candidate: const PuzzleRegion(left: 0, top: 0, right: 4, bottom: 0),
        acceptedRegions: const [],
      );

      expect(result.isValid, isFalse);
      expect(result.message, contains('exactly one clue'));
    });

    test('rejects overlapping regions', () {
      final result = validator.validateRegion(
        puzzle: puzzle,
        candidate: const PuzzleRegion(left: 1, top: 1, right: 2, bottom: 2),
        acceptedRegions: const [
          PuzzleRegion(left: 0, top: 0, right: 1, bottom: 1),
        ],
      );

      expect(result.isValid, isFalse);
      expect(result.message, contains('overlaps'));
    });
  });
}
