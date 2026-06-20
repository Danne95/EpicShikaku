import 'dart:math';

import 'package:shikaku_puzzle/core/constants/puzzle_generation_constants.dart';
import 'package:shikaku_puzzle/features/puzzle/data/puzzle_repository.dart';
import 'package:shikaku_puzzle/features/puzzle/domain/puzzle.dart';
import 'package:shikaku_puzzle/features/puzzle/domain/puzzle_generator.dart';

/// Supplies newly generated offline puzzles to the application.
class GeneratedPuzzleRepository implements PuzzleRepository {
  /// Creates a repository backed by a local puzzle generator.
  GeneratedPuzzleRepository({Random? random}) : _random = random ?? Random();

  final Random _random;

  @override
  Future<Puzzle> loadDefaultPuzzle({required int boardSize}) {
    return Future.value(_generate(boardSize));
  }

  @override
  Future<Puzzle> loadNewPuzzle({required int boardSize}) {
    return Future.value(_generate(boardSize));
  }

  Puzzle _generate(int boardSize) {
    final cellCount = boardSize * boardSize;
    final minimumRegionCount = max(4, boardSize);
    final maximumRegionCount = max(minimumRegionCount, (cellCount / 6).ceil());

    return PuzzleGenerator(
      random: _random,
      width: boardSize,
      height: boardSize,
      minimumRegionCount: minimumRegionCount,
      maximumRegionCount: maximumRegionCount,
      minimumRegionArea: PuzzleGenerationConstants.minimumRegionArea,
      maximumRegionArea: PuzzleGenerationConstants.maximumRegionArea,
    ).generate();
  }
}
