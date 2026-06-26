import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shikaku_puzzle/app/application/app_update_controller.dart';
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
              Expanded(
                child: ListView(
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
                    SwitchListTile(
                      title: const Text('Sound'),
                      subtitle: const Text('Play game sound effects.'),
                      value: settings.isSoundEnabled,
                      onChanged: (value) {
                        settings.setSoundEnabled(isEnabled: value);
                      },
                    ),
                    const SizedBox(height: 12),
                    _BoardSizeControl(
                      boardSize: settings.boardSize,
                      controller: _boardSizeController,
                      focusNode: _boardSizeFocusNode,
                      onBoardSizeRequested: _setBoardSize,
                    ),
                    const SizedBox(height: 24),
                    const _UpdateSection(),
                    const SizedBox(height: 24),
                    const _PatchNotesSection(),
                  ],
                ),
              ),
              const SizedBox(height: 16),
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

class _UpdateSection extends StatelessWidget {
  const _UpdateSection();

  @override
  Widget build(BuildContext context) {
    return Consumer<AppUpdateController>(
      builder: (context, updateController, child) {
        final theme = Theme.of(context);
        final errorMessage = updateController.errorMessage;
        final buttonState = _buttonState(updateController);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Updates', style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              'Check GitHub for a newer direct-download APK.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: buttonState.onPressed,
              icon: buttonState.isBusy
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(buttonState.icon),
              label: Text(buttonState.label),
            ),
            if (errorMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                errorMessage,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  _UpdateButtonState _buttonState(AppUpdateController controller) {
    return switch (controller.status) {
      AppUpdateStatus.checking => const _UpdateButtonState.busy(
        label: 'Checking...',
      ),
      AppUpdateStatus.downloading => const _UpdateButtonState.busy(
        label: 'Getting update...',
      ),
      AppUpdateStatus.upToDate => const _UpdateButtonState(
        label: 'up to date',
        icon: Icons.check,
      ),
      AppUpdateStatus.updateAvailable ||
      AppUpdateStatus.readyToInstall => _UpdateButtonState(
        label: 'get update',
        icon: Icons.error_outline,
        onPressed: controller.getUpdate,
      ),
      AppUpdateStatus.idle || AppUpdateStatus.failed => _UpdateButtonState(
        label: 'Check for updates',
        icon: Icons.system_update_alt,
        onPressed: controller.checkForUpdates,
      ),
    };
  }
}

class _UpdateButtonState {
  const _UpdateButtonState({
    required this.label,
    required this.icon,
    this.onPressed,
  }) : isBusy = false;

  const _UpdateButtonState.busy({required this.label})
    : icon = Icons.system_update_alt,
      onPressed = null,
      isBusy = true;

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool isBusy;
}

class _PatchNotesSection extends StatelessWidget {
  const _PatchNotesSection();

  static const double _maximumNotesHeight = 180;
  static const Color _lightNoteBackground = Color(0xFFFFF3B0);
  static const Color _lightNoteBorder = Color(0xFFE2C766);
  static const Color _lightNoteText = Color(0xFF3D3420);
  static const Color _darkNoteBackground = Color(0xFF252A32);
  static const Color _darkNoteBorder = Color(0xFF4B5563);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final noteBackground = isDarkMode
        ? _darkNoteBackground
        : _lightNoteBackground;
    final noteBorder = isDarkMode ? _darkNoteBorder : _lightNoteBorder;
    final noteTextColor = isDarkMode
        ? theme.colorScheme.onSurface
        : _lightNoteText;
    final titleStyle = theme.textTheme.titleSmall?.copyWith(
      color: noteTextColor,
    );
    final bodyStyle = theme.textTheme.bodyMedium?.copyWith(
      color: noteTextColor,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Patch notes', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxHeight: _maximumNotesHeight),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: noteBackground,
            border: Border.all(color: noteBorder),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Scrollbar(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final note in AppMetadata.patchNotes) ...[
                    Text(note.title, style: titleStyle),
                    const SizedBox(height: 6),
                    for (final change in note.changes)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('- ', style: bodyStyle),
                            Expanded(child: Text(change, style: bodyStyle)),
                          ],
                        ),
                      ),
                    const SizedBox(height: 8),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
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
