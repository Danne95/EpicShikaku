import 'package:shikaku_puzzle/core/models/cell_position.dart';

/// A numbered Shikaku clue placed in one puzzle cell.
class Clue {
  /// Creates a clue.
  const Clue({required this.position, required this.value});

  /// Creates a clue from JSON.
  factory Clue.fromJson(Map<String, Object?> json) {
    return Clue(
      position: CellPosition(x: json['x']! as int, y: json['y']! as int),
      value: json['value']! as int,
    );
  }

  /// Cell containing the clue.
  final CellPosition position;

  /// Required rectangle area.
  final int value;

  /// Converts the clue to JSON.
  Map<String, Object?> toJson() {
    return {'x': position.x, 'y': position.y, 'value': value};
  }
}
