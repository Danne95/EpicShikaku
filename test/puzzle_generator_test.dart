import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:shikaku_puzzle/core/constants/puzzle_generation_constants.dart';
import 'package:shikaku_puzzle/features/puzzle/domain/puzzle_generator.dart';

/// Verifies generated puzzle structure.
void main() {
  test('generates balanced clue areas with unique clue cells', () {
    final puzzle = PuzzleGenerator(
      random: Random(7),
      width: 12,
      height: 12,
      minimumRegionCount: 18,
      maximumRegionCount: 24,
    ).generate();
    final cluePositions = puzzle.clues.map((clue) => clue.position).toSet();
    final totalClueArea = puzzle.clues.fold<int>(
      0,
      (total, clue) => total + clue.value,
    );

    expect(puzzle.width, 12);
    expect(puzzle.height, 12);
    expect(puzzle.clues.length, greaterThanOrEqualTo(18));
    expect(cluePositions.length, puzzle.clues.length);
    expect(totalClueArea, puzzle.cellCount);
    expect(
      puzzle.clues.every(
        (clue) =>
            clue.value >= PuzzleGenerationConstants.minimumRegionArea &&
            clue.value <= PuzzleGenerationConstants.maximumRegionArea,
      ),
      isTrue,
    );
  });
}
