import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shikaku_puzzle/app/application/settings_controller.dart';
import 'package:shikaku_puzzle/core/constants/app_metadata.dart';
import 'package:shikaku_puzzle/core/constants/puzzle_generation_constants.dart';
import 'package:shikaku_puzzle/features/puzzle/application/puzzle_controller.dart';

/// Screen that exposes user-facing application settings.
class SettingsScreen extends StatefulWidget {
  /// Creates the settings screen.
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final TextEditingController _boardSizeController;
  late final FocusNode _boardSizeFocusNode;

  @override
  void initState() {
    super.initState();
    _boardSizeController = TextEditingController();
    _boardSizeFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _boardSizeController.dispose();
    _boardSizeFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsController>(
      builder: (context, settings, child) {
        _synchronizeBoardSizeField(settings.boardSize);

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              SwitchListTile(
                title: const Text('Dark mode'),
                subtitle: const Text('Use the dark app theme.'),
                value: settings.isDarkModeEnabled,
                onChanged: (value) {
                  settings.setDarkModeEnabled(isEnabled: value);
                },
              ),
              SwitchListTile(
                title: const Text('Vibration'),
                subtitle: const Text(
                  'Vibrate for moves and puzzle completion.',
                ),
                value: settings.isVibrationEnabled,
                onChanged: (value) {
                  settings.setVibrationEnabled(isEnabled: value);
                },
              ),
              const SizedBox(height: 12),
              _BoardSizeControl(
                boardSize: settings.boardSize,
                controller: _boardSizeController,
                focusNode: _boardSizeFocusNode,
                onBoardSizeRequested: _setBoardSize,
              ),
              const Spacer(),
              Text(
                'Version ${AppMetadata.versionLabel}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 6),
              Text(
                AppMetadata.signature,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        );
      },
    );
  }

  void _synchronizeBoardSizeField(int boardSize) {
    if (_boardSizeFocusNode.hasFocus) {
      return;
    }

    final boardSizeText = boardSize.toString();
    if (_boardSizeController.text == boardSizeText) {
      return;
    }

    _boardSizeController.value = TextEditingValue(
      text: boardSizeText,
      selection: TextSelection.collapsed(offset: boardSizeText.length),
    );
  }

  Future<void> _setBoardSize(int requestedBoardSize) async {
    final settings = context.read<SettingsController>();
    final wasChanged = await settings.setBoardSize(
      boardSize: requestedBoardSize,
    );
    if (!mounted || !wasChanged) {
      return;
    }

    await context.read<PuzzleController>().loadNewPuzzle(
      boardSize: settings.boardSize,
    );
  }
}

class _BoardSizeControl extends StatelessWidget {
  const _BoardSizeControl({
    required this.boardSize,
    required this.controller,
    required this.focusNode,
    required this.onBoardSizeRequested,
  });

  final int boardSize;
  final TextEditingController controller;
  final FocusNode focusNode;
  final Future<void> Function(int boardSize) onBoardSizeRequested;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Board size', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 4),
        Text(
          'Square board size from ${PuzzleGenerationConstants.minimumBoardSize} to ${PuzzleGenerationConstants.maximumBoardSize}.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              tooltip: 'Decrease board size',
              onPressed: boardSize > PuzzleGenerationConstants.minimumBoardSize
                  ? () => onBoardSizeRequested(boardSize - 1)
                  : null,
              icon: const Icon(Icons.remove),
            ),
            SizedBox(
              width: 72,
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onSubmitted: _submitBoardSize,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ),
            IconButton(
              tooltip: 'Increase board size',
              onPressed: boardSize < PuzzleGenerationConstants.maximumBoardSize
                  ? () => onBoardSizeRequested(boardSize + 1)
                  : null,
              icon: const Icon(Icons.add),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _submitBoardSize(String value) async {
    final requestedBoardSize = int.tryParse(value);
    if (requestedBoardSize == null) {
      controller.text = boardSize.toString();
      focusNode.unfocus();
      return;
    }

    await onBoardSizeRequested(requestedBoardSize);
    controller.text = requestedBoardSize
        .clamp(
          PuzzleGenerationConstants.minimumBoardSize,
          PuzzleGenerationConstants.maximumBoardSize,
        )
        .toInt()
        .toString();
    focusNode.unfocus();
  }
}
