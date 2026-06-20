import 'package:flutter/material.dart';

/// Visual constants for the puzzle board UI.
class PuzzleUiConstants {
  const PuzzleUiConstants._();

  /// Maximum board width on large screens.
  static const maxBoardSize = 560.0;

  /// Board border width in logical pixels.
  static const boardBorderWidth = 2.0;

  /// Cell border width in logical pixels.
  static const cellBorderWidth = 0.7;

  /// Radius used for simple UI containers.
  static const cornerRadius = 8.0;

  /// Colors cycled through accepted puzzle regions.
  static const regionColors = <Color>[
    Color(0xFFB7E4C7),
    Color(0xFFFFD6A5),
    Color(0xFFA0C4FF),
    Color(0xFFFFADAD),
    Color(0xFFCAFFBF),
    Color(0xFFE9D5FF),
  ];
}
