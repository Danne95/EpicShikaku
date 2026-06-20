import 'package:shared_preferences/shared_preferences.dart';

/// Persists user-facing application settings on the device.
class SettingsRepository {
  /// Creates a settings repository.
  const SettingsRepository();

  static const _darkModeKey = 'settings.dark_mode_enabled';
  static const _vibrationKey = 'settings.vibration_enabled';
  static const _boardSizeKey = 'settings.board_size';

  /// Loads whether dark mode is enabled.
  Future<bool> loadDarkModeEnabled() async {
    final preferences = await SharedPreferences.getInstance();

    return preferences.getBool(_darkModeKey) ?? true;
  }

  /// Loads whether vibration feedback is enabled.
  Future<bool> loadVibrationEnabled() async {
    final preferences = await SharedPreferences.getInstance();

    return preferences.getBool(_vibrationKey) ?? false;
  }

  /// Loads the selected square board size.
  Future<int?> loadBoardSize() async {
    final preferences = await SharedPreferences.getInstance();

    return preferences.getInt(_boardSizeKey);
  }

  /// Saves whether dark mode is enabled.
  Future<void> saveDarkModeEnabled({required bool isEnabled}) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_darkModeKey, isEnabled);
  }

  /// Saves whether vibration feedback is enabled.
  Future<void> saveVibrationEnabled({required bool isEnabled}) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_vibrationKey, isEnabled);
  }

  /// Saves the selected square board size.
  Future<void> saveBoardSize({required int boardSize}) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setInt(_boardSizeKey, boardSize);
  }
}
