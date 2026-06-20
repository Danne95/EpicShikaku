import 'package:shikaku_puzzle/core/models/cell_position.dart';
import 'package:shikaku_puzzle/features/puzzle/domain/clue.dart';
import 'package:shikaku_puzzle/features/puzzle/domain/puzzle.dart';
import 'package:shikaku_puzzle/features/puzzle/domain/puzzle_region.dart';
import 'package:shikaku_puzzle/features/puzzle/domain/puzzle_validation_result.dart';

/// Validates Shikaku region selections and completion state.
class PuzzleValidator {
  /// Creates a puzzle validator.
  const PuzzleValidator();

  /// Validates a candidate region against the puzzle and accepted regions.
  PuzzleValidationResult validateRegion({
    required Puzzle puzzle,
    required PuzzleRegion candidate,
    required List<PuzzleRegion> acceptedRegions,
  }) {
    if (!_isInsidePuzzle(puzzle, candidate)) {
      return const PuzzleValidationResult.invalid(
        'Selection is outside the board.',
      );
    }

    if (_overlapsAcceptedRegion(candidate, acceptedRegions)) {
      return const PuzzleValidationResult.invalid(
        'Selection overlaps an existing region.',
      );
    }

    final clues = _cluesInsideRegion(puzzle, candidate);
    if (clues.length != 1) {
      return const PuzzleValidationResult.invalid(
        'Selection must contain exactly one clue.',
      );
    }

    final clue = clues.single;
    if (candidate.area != clue.value) {
      return PuzzleValidationResult.invalid(
        'Selection area must equal ${clue.value}.',
      );
    }

    return const PuzzleValidationResult.valid();
  }

  /// Returns whether all cells are covered by accepted regions.
  bool isPuzzleComplete({
    required Puzzle puzzle,
    required List<PuzzleRegion> acceptedRegions,
  }) {
    final coveredCells = <CellPosition>{};

    for (final region in acceptedRegions) {
      final result = validateRegion(
        puzzle: puzzle,
        candidate: region,
        acceptedRegions: acceptedRegions
            .where((item) => item != region)
            .toList(),
      );

      if (!result.isValid) {
        return false;
      }

      for (var y = region.top; y <= region.bottom; y++) {
        for (var x = region.left; x <= region.right; x++) {
          coveredCells.add(CellPosition(x: x, y: y));
        }
      }
    }

    return coveredCells.length == puzzle.cellCount;
  }

  bool _isInsidePuzzle(Puzzle puzzle, PuzzleRegion region) {
    return puzzle.containsPosition(
          CellPosition(x: region.left, y: region.top),
        ) &&
        puzzle.containsPosition(
          CellPosition(x: region.right, y: region.bottom),
        );
  }

  bool _overlapsAcceptedRegion(
    PuzzleRegion candidate,
    List<PuzzleRegion> acceptedRegions,
  ) {
    return acceptedRegions.any(candidate.overlaps);
  }

  List<Clue> _cluesInsideRegion(Puzzle puzzle, PuzzleRegion region) {
    return puzzle.clues
        .where((clue) => region.containsPosition(clue.position))
        .toList(growable: false);
  }
}
