import 'dart:math';

import 'package:shikaku_puzzle/core/constants/puzzle_generation_constants.dart';
import 'package:shikaku_puzzle/core/models/cell_position.dart';
import 'package:shikaku_puzzle/features/puzzle/domain/clue.dart';
import 'package:shikaku_puzzle/features/puzzle/domain/puzzle.dart';
import 'package:shikaku_puzzle/features/puzzle/domain/puzzle_region.dart';

/// Creates solvable Shikaku puzzles by partitioning a board into rectangles.
class PuzzleGenerator {
  /// Creates a generator for rectangular Shikaku boards.
  PuzzleGenerator({
    Random? random,
    this.width = 5,
    this.height = 5,
    this.minimumRegionCount = 5,
    this.maximumRegionCount = 8,
    this.minimumRegionArea = PuzzleGenerationConstants.minimumRegionArea,
    this.maximumRegionArea = PuzzleGenerationConstants.maximumRegionArea,
  }) : _random = random ?? Random(),
       assert(width > 0),
       assert(height > 0),
       assert(minimumRegionCount > 0),
       assert(minimumRegionCount <= maximumRegionCount),
       assert(maximumRegionCount <= width * height),
       assert(minimumRegionArea > 0),
       assert(minimumRegionArea <= maximumRegionArea);

  final Random _random;

  /// Board width in cells.
  final int width;

  /// Board height in cells.
  final int height;

  /// Lowest number of rectangular regions to generate.
  final int minimumRegionCount;

  /// Highest number of rectangular regions to generate.
  final int maximumRegionCount;

  /// Smallest area allowed for a generated rectangle.
  final int minimumRegionArea;

  /// Largest area allowed for a generated rectangle.
  final int maximumRegionArea;

  /// Generates a new puzzle with at least one valid solution.
  Puzzle generate() {
    final regions = <PuzzleRegion>[
      PuzzleRegion(left: 0, top: 0, right: width - 1, bottom: height - 1),
    ];
    final targetRegionCount = _targetRegionCount();

    while (_needsMoreSplits(regions, targetRegionCount)) {
      final regionIndexes = _preferredRegionIndexes(regions);
      if (regionIndexes.isEmpty) {
        break;
      }

      final index = regionIndexes[_random.nextInt(regionIndexes.length)];
      final region = regions.removeAt(index);
      regions.insertAll(index, _splitRegion(region));
    }

    return Puzzle(width: width, height: height, clues: _createClues(regions));
  }

  int _targetRegionCount() {
    final range = maximumRegionCount - minimumRegionCount + 1;
    return minimumRegionCount + _random.nextInt(range);
  }

  bool _needsMoreSplits(List<PuzzleRegion> regions, int targetRegionCount) {
    return regions.length < targetRegionCount ||
        regions.any((region) => region.area > maximumRegionArea);
  }

  List<int> _preferredRegionIndexes(List<PuzzleRegion> regions) {
    final splittableIndexes = <int>[
      for (var index = 0; index < regions.length; index++)
        if (_splitOptionsFor(regions[index]).isNotEmpty) index,
    ];
    if (splittableIndexes.isEmpty) {
      return const [];
    }

    final largestArea = splittableIndexes
        .map((index) => regions[index].area)
        .reduce(max);

    return [
      for (final index in splittableIndexes)
        if (regions[index].area >= largestArea - maximumRegionArea ~/ 2) index,
    ];
  }

  List<PuzzleRegion> _splitRegion(PuzzleRegion region) {
    final options = _splitOptionsFor(region)
      ..sort((first, second) {
        return _areaDifference(first).compareTo(_areaDifference(second));
      });
    final preferredOptionCount = min(3, options.length);

    return options[_random.nextInt(preferredOptionCount)];
  }

  List<List<PuzzleRegion>> _splitOptionsFor(PuzzleRegion region) {
    final options = <List<PuzzleRegion>>[];

    for (var splitX = region.left + 1; splitX <= region.right; splitX++) {
      final splitRegions = _splitVertically(region, splitX);
      if (_hasMinimumArea(splitRegions)) {
        options.add(splitRegions);
      }
    }

    for (var splitY = region.top + 1; splitY <= region.bottom; splitY++) {
      final splitRegions = _splitHorizontally(region, splitY);
      if (_hasMinimumArea(splitRegions)) {
        options.add(splitRegions);
      }
    }

    return options;
  }

  List<PuzzleRegion> _splitVertically(PuzzleRegion region, int splitX) {
    return [
      PuzzleRegion(
        left: region.left,
        top: region.top,
        right: splitX - 1,
        bottom: region.bottom,
      ),
      PuzzleRegion(
        left: splitX,
        top: region.top,
        right: region.right,
        bottom: region.bottom,
      ),
    ];
  }

  List<PuzzleRegion> _splitHorizontally(PuzzleRegion region, int splitY) {
    return [
      PuzzleRegion(
        left: region.left,
        top: region.top,
        right: region.right,
        bottom: splitY - 1,
      ),
      PuzzleRegion(
        left: region.left,
        top: splitY,
        right: region.right,
        bottom: region.bottom,
      ),
    ];
  }

  bool _hasMinimumArea(List<PuzzleRegion> regions) {
    return regions.every((region) => region.area >= minimumRegionArea);
  }

  int _areaDifference(List<PuzzleRegion> regions) {
    return (regions.first.area - regions.last.area).abs();
  }

  List<Clue> _createClues(List<PuzzleRegion> regions) {
    final sortedRegions = [...regions]
      ..sort((first, second) => second.area.compareTo(first.area));
    final clues = <Clue>[];

    for (final region in sortedRegions) {
      final position = _cluePositionFor(region, clues);
      clues.add(Clue(position: position, value: region.area));
    }

    return clues;
  }

  CellPosition _cluePositionFor(PuzzleRegion region, List<Clue> clues) {
    final candidates = <CellPosition>[];
    for (var y = region.top; y <= region.bottom; y++) {
      for (var x = region.left; x <= region.right; x++) {
        candidates.add(CellPosition(x: x, y: y));
      }
    }

    final wellSpacedCandidates = candidates
        .where((candidate) {
          return clues.every(
            (clue) => _hasPreferredGap(candidate, clue.position),
          );
        })
        .toList(growable: false);

    if (wellSpacedCandidates.isNotEmpty) {
      return wellSpacedCandidates[_random.nextInt(wellSpacedCandidates.length)];
    }

    return _furthestCandidate(candidates, clues);
  }

  bool _hasPreferredGap(CellPosition first, CellPosition second) {
    final horizontalDistance = (first.x - second.x).abs();
    final verticalDistance = (first.y - second.y).abs();

    return horizontalDistance >= PuzzleGenerationConstants.preferredClueGap ||
        verticalDistance >= PuzzleGenerationConstants.preferredClueGap;
  }

  CellPosition _furthestCandidate(
    List<CellPosition> candidates,
    List<Clue> clues,
  ) {
    var furthestDistance = -1;
    var furthestCandidates = <CellPosition>[];

    for (final candidate in candidates) {
      final nearestDistance = clues
          .map((clue) => _chebyshevDistance(candidate, clue.position))
          .reduce(min);

      if (nearestDistance > furthestDistance) {
        furthestDistance = nearestDistance;
        furthestCandidates = [candidate];
      } else if (nearestDistance == furthestDistance) {
        furthestCandidates.add(candidate);
      }
    }

    return furthestCandidates[_random.nextInt(furthestCandidates.length)];
  }

  int _chebyshevDistance(CellPosition first, CellPosition second) {
    return max((first.x - second.x).abs(), (first.y - second.y).abs());
  }
}
