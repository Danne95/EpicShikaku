import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shikaku_puzzle/app/application/app_update_controller.dart';
import 'package:shikaku_puzzle/app/application/settings_controller.dart';
import 'package:shikaku_puzzle/app/data/app_update_service.dart';
import 'package:shikaku_puzzle/app/data/settings_repository.dart';
import 'package:shikaku_puzzle/app/presentation/app_shell.dart';
import 'package:shikaku_puzzle/app/theme/app_theme.dart';
import 'package:shikaku_puzzle/features/puzzle/application/puzzle_controller.dart';
import 'package:shikaku_puzzle/features/puzzle/data/generated_puzzle_repository.dart';
import 'package:shikaku_puzzle/features/puzzle/domain/puzzle_validator.dart';

/// Root widget for the EpicShikaku application.
class ShikakuPuzzleApp extends StatelessWidget {
  /// Creates the application shell.
  const ShikakuPuzzleApp({
    this.settingsController,
    this.updateController,
    super.key,
  });

  /// Preloaded app settings used during normal application startup.
  final SettingsController? settingsController;

  /// Optional update controller used by tests.
  final AppUpdateController? updateController;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        if (settingsController == null)
          ChangeNotifierProvider(
            create: (_) =>
                SettingsController(repository: const SettingsRepository())
                  ..loadSettings(),
          )
        else
          ChangeNotifierProvider<SettingsController>.value(
            value: settingsController!,
          ),
        ChangeNotifierProvider(
          create: (context) {
            final settings = context.read<SettingsController>();

            return PuzzleController(
              repository: GeneratedPuzzleRepository(),
              validator: const PuzzleValidator(),
            )..loadDefaultPuzzle(boardSize: settings.boardSize);
          },
        ),
        if (updateController == null)
          ChangeNotifierProvider(
            create: (_) => AppUpdateController(service: AppUpdateService()),
          )
        else
          ChangeNotifierProvider<AppUpdateController>.value(
            value: updateController!,
          ),
      ],
      child: Consumer<SettingsController>(
        builder: (context, settings, child) {
          return MaterialApp(
            title: 'EpicShikaku',
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: settings.isDarkModeEnabled
                ? ThemeMode.dark
                : ThemeMode.light,
            home: const AppShell(),
          );
        },
      ),
    );
  }
}
