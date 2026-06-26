import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shikaku_puzzle/app/application/settings_controller.dart';
import 'package:shikaku_puzzle/app/data/settings_repository.dart';
import 'package:shikaku_puzzle/core/constants/puzzle_generation_constants.dart';

/// Verifies app settings defaults and persistence behavior.
void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('uses dark mode, sound, and disables vibration by default', () async {
    final controller = SettingsController(
      repository: const SettingsRepository(),
    );

    await controller.loadSettings();

    expect(controller.isDarkModeEnabled, isTrue);
    expect(controller.isVibrationEnabled, isFalse);
    expect(controller.isSoundEnabled, isTrue);
    expect(controller.boardSize, PuzzleGenerationConstants.defaultBoardSize);
  });

  test('persists setting changes', () async {
    final controller = SettingsController(
      repository: const SettingsRepository(),
    );

    await controller.loadSettings();
    await controller.setDarkModeEnabled(isEnabled: false);
    await controller.setVibrationEnabled(isEnabled: false);
    await controller.setSoundEnabled(isEnabled: false);
    await controller.setBoardSize(boardSize: 8);

    final reloadedController = SettingsController(
      repository: const SettingsRepository(),
    );
    await reloadedController.loadSettings();

    expect(reloadedController.isDarkModeEnabled, isFalse);
    expect(reloadedController.isVibrationEnabled, isFalse);
    expect(reloadedController.isSoundEnabled, isFalse);
    expect(reloadedController.boardSize, 8);
  });

  test('keeps board size within supported limits', () async {
    final controller = SettingsController(
      repository: const SettingsRepository(),
    );

    await controller.setBoardSize(boardSize: 99);

    expect(controller.boardSize, PuzzleGenerationConstants.maximumBoardSize);
  });
}
