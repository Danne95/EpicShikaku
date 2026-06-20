import 'package:flutter/material.dart';
import 'package:shikaku_puzzle/app/app.dart';
import 'package:shikaku_puzzle/app/application/settings_controller.dart';
import 'package:shikaku_puzzle/app/data/settings_repository.dart';

/// Starts the EpicShikaku application.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final settingsController = SettingsController(
    repository: const SettingsRepository(),
  );
  await settingsController.loadSettings();

  runApp(ShikakuPuzzleApp(settingsController: settingsController));
}
