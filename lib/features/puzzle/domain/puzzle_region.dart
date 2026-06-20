import 'package:shikaku_puzzle/core/models/cell_position.dart';

/// A rectangular region selected on the puzzle board.
class PuzzleRegion {
  /// Creates a rectangular puzzle region with inclusive bounds.
  const PuzzleRegion({
    required this.left,
    required this.top,
    required this.right,
    required this.bottom,
  }) : assert(left <= right),
       assert(top <= bottom);

  /// Left edge in grid coordinates.
  final int left;

  /// Top edge in grid coordinates.
  final int top;

  /// Right edge in grid coordinates.
  final int right;

  /// Bottom edge in grid coordinates.
  final int bottom;

  /// Number of cells inside the region.
  int get area => (right - left + 1) * (bottom - top + 1);

  /// Returns whether the region contains a position.
  bool containsPosition(CellPosition position) {
    return position.x >= left &&
        position.x <= right &&
        position.y >= top &&
        position.y <= bottom;
  }

  /// Returns whether this region overlaps another region.
  bool overlaps(PuzzleRegion other) {
    return left <= other.right &&
        right >= other.left &&
        top <= other.bottom &&
        bottom >= other.top;
  }
}
