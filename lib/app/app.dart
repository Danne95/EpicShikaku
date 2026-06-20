import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shikaku_puzzle/app/theme/app_theme.dart';
import 'package:shikaku_puzzle/features/puzzle/application/puzzle_controller.dart';
import 'package:shikaku_puzzle/features/puzzle/data/asset_puzzle_repository.dart';
import 'package:shikaku_puzzle/features/puzzle/domain/puzzle_validator.dart';
import 'package:shikaku_puzzle/features/puzzle/presentation/puzzle_screen.dart';

/// Root widget for the Shikaku Puzzle application.
class ShikakuPuzzleApp extends StatelessWidget {
  /// Creates the application shell.
  const ShikakuPuzzleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PuzzleController(
        repository: const AssetPuzzleRepository(),
        validator: const PuzzleValidator(),
      )..loadDefaultPuzzle(),
      child: MaterialApp(
        title: 'Shikaku Puzzle',
        theme: AppTheme.light(),
        home: const PuzzleScreen(),
      ),
    );
  }
}
