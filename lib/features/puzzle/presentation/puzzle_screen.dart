import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shikaku_puzzle/app/application/settings_controller.dart';
import 'package:shikaku_puzzle/core/models/cell_position.dart';
import 'package:shikaku_puzzle/core/services/vibration_service.dart';
import 'package:shikaku_puzzle/features/puzzle/application/puzzle_controller.dart';
import 'package:shikaku_puzzle/features/puzzle/domain/puzzle_region.dart';
import 'package:shikaku_puzzle/features/puzzle/domain/puzzle_validation_result.dart';
import 'package:shikaku_puzzle/features/puzzle/presentation/widgets/completion_confetti.dart';
import 'package:shikaku_puzzle/features/puzzle/presentation/widgets/puzzle_board.dart';

/// Main screen for playing a Shikaku puzzle.
class PuzzleScreen extends StatefulWidget {
  /// Creates the puzzle screen.
  const PuzzleScreen({super.key});

  @override
  State<PuzzleScreen> createState() => _PuzzleScreenState();
}

class _PuzzleScreenState extends State<PuzzleScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _confettiController;
  bool _completionHandled = false;

  @override
  void initState() {
    super.initState();
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PuzzleController>(
      builder: (context, controller, child) {
        _handleCompletionState(controller);

        return Padding(
          padding: const EdgeInsets.all(16),
          child: _buildBody(controller),
        );
      },
    );
  }

  Widget _buildBody(PuzzleController controller) {
    if (controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final puzzle = controller.puzzle;
    if (puzzle == null) {
      return Center(
        child: Text(controller.lastErrorMessage ?? 'No puzzle loaded.'),
      );
    }

    return Column(
      children: [
        Expanded(
          child: Stack(
            fit: StackFit.expand,
            children: [
              Center(
                child: PuzzleBoard(
                  puzzle: puzzle,
                  acceptedRegions: controller.acceptedRegions,
                  currentSelection: controller.currentSelection,
                  onSelectionChanged: controller.updateCurrentSelection,
                  onSelectionSubmitted: _submitRegion,
                  onAcceptedRegionPressed: _removeAcceptedRegion,
                ),
              ),
              if (controller.isComplete)
                CompletionConfetti(animation: _confettiController),
            ],
          ),
        ),
        if (controller.isComplete) ...[
          const SizedBox(height: 12),
          Text(
            'Puzzle complete',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: _loadNewPuzzle,
            icon: const Icon(Icons.refresh),
            label: const Text('New puzzle'),
          ),
        ],
        const SizedBox(height: 16),
        SizedBox(
          height: 40,
          child: Center(
            child: Text(
              controller.lastErrorMessage ??
                  'Drag to create rectangles. Tap a completed region to remove it.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }

  PuzzleValidationResult _submitRegion(PuzzleRegion region) {
    final controller = context.read<PuzzleController>();
    final settings = context.read<SettingsController>();
    final result = controller.submitRegion(region);

    if (settings.isVibrationEnabled && result.isValid) {
      VibrationService.vibrateMove();
    }

    return result;
  }

  bool _removeAcceptedRegion(CellPosition position) {
    final controller = context.read<PuzzleController>();
    final settings = context.read<SettingsController>();
    final wasRemoved = controller.removeRegionAt(position);

    if (settings.isVibrationEnabled && wasRemoved) {
      VibrationService.vibrateMove();
    }

    return wasRemoved;
  }

  void _loadNewPuzzle() {
    final settings = context.read<SettingsController>();
    context.read<PuzzleController>().loadNewPuzzle(
      boardSize: settings.boardSize,
    );
  }

  void _handleCompletionState(PuzzleController controller) {
    if (!controller.isComplete) {
      _completionHandled = false;
      return;
    }

    if (_completionHandled) {
      return;
    }

    _completionHandled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      final settings = context.read<SettingsController>();
      if (settings.isVibrationEnabled) {
        VibrationService.vibrateWin();
      }
      _confettiController.forward(from: 0);
    });
  }
}
