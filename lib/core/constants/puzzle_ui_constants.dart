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

  /// Outline width for accepted puzzle regions.
  static const acceptedRegionBorderWidth = 2.4;

  /// Radius used for simple UI containers.
  static const cornerRadius = 8.0;

  /// Light-mode board colors.
  static const lightColorScheme = PuzzleBoardColorScheme(
    clueColor: Color(0xFF111827),
    selectionColor: Color(0xFFC7D2FE),
    regionColors: [
      Color(0xFFD8E8DF),
      Color(0xFFF2D6AD),
      Color(0xFFD3E0F3),
      Color(0xFFF0C9C9),
      Color(0xFFDCECCF),
      Color(0xFFE0D4EF),
    ],
  );

  /// Dark-mode board colors.
  static const darkColorScheme = PuzzleBoardColorScheme(
    clueColor: Color(0xFFF9FAFB),
    selectionColor: Color(0xFF334155),
    regionColors: [
      Color(0xFF245142),
      Color(0xFF665036),
      Color(0xFF304967),
      Color(0xFF663D3D),
      Color(0xFF405D35),
      Color(0xFF514065),
    ],
  );

  /// Returns the board colors for the active theme brightness.
  static PuzzleBoardColorScheme colorSchemeFor(Brightness brightness) {
    return brightness == Brightness.dark ? darkColorScheme : lightColorScheme;
  }
}

/// Theme-specific colors used by the puzzle board.
class PuzzleBoardColorScheme {
  /// Creates a puzzle board color scheme.
  const PuzzleBoardColorScheme({
    required this.clueColor,
    required this.selectionColor,
    required this.regionColors,
  });

  /// Text color for clue numbers.
  final Color clueColor;

  /// Fill color for the current drag selection.
  final Color selectionColor;

  /// Colors cycled through accepted puzzle regions.
  final List<Color> regionColors;
}
