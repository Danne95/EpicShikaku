/// A zero-based coordinate inside a puzzle grid.
class CellPosition {
  /// Creates a grid coordinate.
  const CellPosition({required this.x, required this.y});

  /// Horizontal coordinate starting at zero from the left.
  final int x;

  /// Vertical coordinate starting at zero from the top.
  final int y;

  @override
  bool operator ==(Object other) {
    return other is CellPosition && other.x == x && other.y == y;
  }

  @override
  int get hashCode => Object.hash(x, y);

  @override
  String toString() => 'CellPosition(x: $x, y: $y)';
}
