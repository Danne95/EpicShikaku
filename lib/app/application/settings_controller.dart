import 'package:flutter/foundation.dart';
import 'package:shikaku_puzzle/app/data/settings_repository.dart';
import 'package:shikaku_puzzle/core/constants/puzzle_generation_constants.dart';

/// Holds user-facing application settings.
class SettingsController extends ChangeNotifier {
  /// Creates a settings controller.
  SettingsController({required this.repository});

  /// Repository used to load and save settings.
  final SettingsRepository repository;

  bool _isDarkModeEnabled = true;
  bool _isVibrationEnabled = false;
  int _boardSize = PuzzleGenerationConstants.defaultBoardSize;

  /// Whether dark mode is currently enabled.
  bool get isDarkModeEnabled => _isDarkModeEnabled;

  /// Whether haptic feedback is currently enabled.
  bool get isVibrationEnabled => _isVibrationEnabled;

  /// Selected width and height for generated square puzzle boards.
  int get boardSize => _boardSize;

  /// Loads persisted settings from local device storage.
  Future<void> loadSettings() async {
    _isDarkModeEnabled = await repository.loadDarkModeEnabled();
    _isVibrationEnabled = await repository.loadVibrationEnabled();
    _boardSize = _normalizeBoardSize(await repository.loadBoardSize());
    notifyListeners();
  }

  /// Enables or disables dark mode.
  Future<void> setDarkModeEnabled({required bool isEnabled}) async {
    if (_isDarkModeEnabled == isEnabled) {
      return;
    }

    _isDarkModeEnabled = isEnabled;
    notifyListeners();
    await repository.saveDarkModeEnabled(isEnabled: isEnabled);
  }

  /// Enables or disables haptic feedback.
  Future<void> setVibrationEnabled({required bool isEnabled}) async {
    if (_isVibrationEnabled == isEnabled) {
      return;
    }

    _isVibrationEnabled = isEnabled;
    notifyListeners();
    await repository.saveVibrationEnabled(isEnabled: isEnabled);
  }

  /// Updates the generated puzzle board size and reports whether it changed.
  Future<bool> setBoardSize({required int boardSize}) async {
    final normalizedSize = _normalizeBoardSize(boardSize);
    if (_boardSize == normalizedSize) {
      return false;
    }

    _boardSize = normalizedSize;
    notifyListeners();
    await repository.saveBoardSize(boardSize: normalizedSize);
    return true;
  }

  int _normalizeBoardSize(int? boardSize) {
    return (boardSize ?? PuzzleGenerationConstants.defaultBoardSize)
        .clamp(
          PuzzleGenerationConstants.minimumBoardSize,
          PuzzleGenerationConstants.maximumBoardSize,
        )
        .toInt();
  }
}
