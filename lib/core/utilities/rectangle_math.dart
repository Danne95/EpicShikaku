import 'package:shikaku_puzzle/core/models/cell_position.dart';
import 'package:shikaku_puzzle/features/puzzle/domain/puzzle_region.dart';

/// Creates normalized rectangular regions from two grid positions.
class RectangleMath {
  const RectangleMath._();

  /// Returns a region whose bounds include both positions.
  static PuzzleRegion fromCorners(CellPosition start, CellPosition end) {
    final left = start.x < end.x ? start.x : end.x;
    final right = start.x > end.x ? start.x : end.x;
    final top = start.y < end.y ? start.y : end.y;
    final bottom = start.y > end.y ? start.y : end.y;

    return PuzzleRegion(
      left: left,
      top: top,
      right: right,
      bottom: bottom,
    );
  }
}
