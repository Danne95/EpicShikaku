import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shikaku_puzzle/app/application/settings_controller.dart';
import 'package:shikaku_puzzle/features/puzzle/application/puzzle_controller.dart';
import 'package:shikaku_puzzle/features/puzzle/presentation/puzzle_screen.dart';
import 'package:shikaku_puzzle/features/settings/presentation/settings_screen.dart';

/// Top-level navigation shell for the app.
class AppShell extends StatefulWidget {
  /// Creates the app shell.
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  var _isShowingSettings = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: _isShowingSettings
            ? IconButton(
                tooltip: 'Back to puzzle',
                onPressed: _showPuzzle,
                icon: const Icon(Icons.arrow_back),
              )
            : null,
        title: Text(_isShowingSettings ? 'Settings' : 'EpicShikaku'),
        actions: [
          if (_isShowingSettings)
            IconButton(
              tooltip: 'Puzzle',
              onPressed: _showPuzzle,
              icon: const Icon(Icons.grid_view_outlined),
            )
          else ...[
            IconButton(
              tooltip: 'New puzzle',
              onPressed: () {
                context.read<PuzzleController>().loadNewPuzzle(
                  boardSize: context.read<SettingsController>().boardSize,
                );
              },
              icon: const Icon(Icons.refresh),
            ),
            IconButton(
              tooltip: 'Settings',
              onPressed: _showSettings,
              icon: const Icon(Icons.settings_outlined),
            ),
          ],
        ],
      ),
      body: SafeArea(
        child: _isShowingSettings
            ? const SettingsScreen()
            : const PuzzleScreen(),
      ),
    );
  }

  void _showSettings() {
    setState(() {
      _isShowingSettings = true;
    });
  }

  void _showPuzzle() {
    setState(() {
      _isShowingSettings = false;
    });
  }
}
