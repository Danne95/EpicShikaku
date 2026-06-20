import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shikaku_puzzle/features/puzzle/application/puzzle_controller.dart';
import 'package:shikaku_puzzle/features/puzzle/presentation/widgets/puzzle_board.dart';

/// Main screen for playing a Shikaku puzzle.
class PuzzleScreen extends StatefulWidget {
  /// Creates the puzzle screen.
  const PuzzleScreen({super.key});

  @override
  State<PuzzleScreen> createState() => _PuzzleScreenState();
}

class _PuzzleScreenState extends State<PuzzleScreen> {
  bool _completionDialogShown = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<PuzzleController>(
      builder: (context, controller, child) {
        _showCompletionDialogIfNeeded(context, controller);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Shikaku Puzzle'),
            actions: [
              IconButton(
                tooltip: 'Reset puzzle',
                onPressed: controller.resetProgress,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _buildBody(controller),
            ),
          ),
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
          child: Center(
            child: PuzzleBoard(
              puzzle: puzzle,
              acceptedRegions: controller.acceptedRegions,
              currentSelection: controller.currentSelection,
              onSelectionChanged: controller.updateCurrentSelection,
              onSelectionSubmitted: controller.submitRegion,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 40,
          child: Center(
            child: Text(
              controller.lastErrorMessage ?? 'Drag across cells to create rectangles.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }

  void _showCompletionDialogIfNeeded(
    BuildContext context,
    PuzzleController controller,
  ) {
    if (!controller.isComplete) {
      _completionDialogShown = false;
    }

    if (!controller.isComplete || _completionDialogShown) {
      return;
    }

    _completionDialogShown = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      showDialog<void>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Puzzle complete'),
            content: const Text('Every cell is covered by a valid rectangle.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Done'),
              ),
            ],
          );
        },
      );
    });
  }
}
