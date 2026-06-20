import 'package:flutter/material.dart';
import 'package:shikaku_puzzle/core/constants/puzzle_ui_constants.dart';
import 'package:shikaku_puzzle/core/models/cell_position.dart';
import 'package:shikaku_puzzle/core/utilities/rectangle_math.dart';
import 'package:shikaku_puzzle/features/puzzle/domain/puzzle.dart';
import 'package:shikaku_puzzle/features/puzzle/domain/puzzle_region.dart';
import 'package:shikaku_puzzle/features/puzzle/domain/puzzle_validation_result.dart';

/// Interactive grid used to select and display Shikaku regions.
class PuzzleBoard extends StatefulWidget {
  /// Creates a puzzle board.
  const PuzzleBoard({
    required this.puzzle,
    required this.acceptedRegions,
    required this.currentSelection,
    required this.onSelectionChanged,
    required this.onSelectionSubmitted,
    required this.onAcceptedRegionPressed,
    super.key,
  });

  /// Puzzle definition to render.
  final Puzzle puzzle;

  /// Accepted regions to display.
  final List<PuzzleRegion> acceptedRegions;

  /// Current drag preview region.
  final PuzzleRegion? currentSelection;

  /// Called when drag selection changes.
  final ValueChanged<PuzzleRegion?> onSelectionChanged;

  /// Called when drag selection is released.
  final PuzzleValidationResult Function(PuzzleRegion region)
  onSelectionSubmitted;

  /// Called when the player presses an already accepted region.
  final bool Function(CellPosition position) onAcceptedRegionPressed;

  @override
  State<PuzzleBoard> createState() => _PuzzleBoardState();
}

class _PuzzleBoardState extends State<PuzzleBoard> {
  CellPosition? _dragStart;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boardSize = _boardSizeFor(constraints);
        final cellSize = boardSize / widget.puzzle.width;
        final boardColorScheme = PuzzleUiConstants.colorSchemeFor(
          Theme.of(context).brightness,
        );

        return GestureDetector(
          onTapUp: (details) => _handleTapUp(details, cellSize),
          onPanStart: (details) => _handlePanStart(details, cellSize),
          onPanUpdate: (details) => _handlePanUpdate(details, cellSize),
          onPanEnd: (_) => _handlePanEnd(),
          onPanCancel: _handlePanCancel,
          child: SizedBox.square(
            dimension: boardSize,
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(
                  width: PuzzleUiConstants.boardBorderWidth,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              child: Stack(
                children: [
                  _RegionLayer(
                    puzzle: widget.puzzle,
                    acceptedRegions: widget.acceptedRegions,
                    currentSelection: widget.currentSelection,
                    colorScheme: boardColorScheme,
                  ),
                  _GridLayer(puzzle: widget.puzzle),
                  _AcceptedRegionBorderLayer(
                    puzzle: widget.puzzle,
                    acceptedRegions: widget.acceptedRegions,
                    borderColor: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.78),
                  ),
                  _ClueLayer(
                    puzzle: widget.puzzle,
                    clueColor: boardColorScheme.clueColor,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  double _boardSizeFor(BoxConstraints constraints) {
    final shortestSide = constraints.maxWidth < constraints.maxHeight
        ? constraints.maxWidth
        : constraints.maxHeight;

    return shortestSide.clamp(0, PuzzleUiConstants.maxBoardSize).toDouble();
  }

  void _handlePanStart(DragStartDetails details, double cellSize) {
    final position = _positionForOffset(details.localPosition, cellSize);
    if (position == null) {
      return;
    }

    _dragStart = position;
    widget.onSelectionChanged(RectangleMath.fromCorners(position, position));
  }

  void _handleTapUp(TapUpDetails details, double cellSize) {
    final position = _positionForOffset(details.localPosition, cellSize);
    if (position == null || !_isAcceptedRegionPosition(position)) {
      return;
    }

    widget.onAcceptedRegionPressed(position);
  }

  void _handlePanUpdate(DragUpdateDetails details, double cellSize) {
    final start = _dragStart;
    final position = _positionForOffset(details.localPosition, cellSize);
    if (start == null || position == null) {
      return;
    }

    widget.onSelectionChanged(RectangleMath.fromCorners(start, position));
  }

  void _handlePanEnd() {
    final selection = widget.currentSelection;
    if (selection != null) {
      widget.onSelectionSubmitted(selection);
    }

    _dragStart = null;
  }

  void _handlePanCancel() {
    _dragStart = null;
    widget.onSelectionChanged(null);
  }

  bool _isAcceptedRegionPosition(CellPosition position) {
    return widget.acceptedRegions.any(
      (region) => region.containsPosition(position),
    );
  }

  CellPosition? _positionForOffset(Offset offset, double cellSize) {
    final x = (offset.dx / cellSize).floor();
    final y = (offset.dy / cellSize).floor();
    final position = CellPosition(x: x, y: y);

    return widget.puzzle.containsPosition(position) ? position : null;
  }
}

class _RegionLayer extends StatelessWidget {
  const _RegionLayer({
    required this.puzzle,
    required this.acceptedRegions,
    required this.currentSelection,
    required this.colorScheme,
  });

  final Puzzle puzzle;
  final List<PuzzleRegion> acceptedRegions;
  final PuzzleRegion? currentSelection;
  final PuzzleBoardColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _RegionPainter(
        puzzle: puzzle,
        acceptedRegions: acceptedRegions,
        currentSelection: currentSelection,
        colorScheme: colorScheme,
      ),
      size: Size.infinite,
    );
  }
}

class _GridLayer extends StatelessWidget {
  const _GridLayer({required this.puzzle});

  final Puzzle puzzle;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _GridPainter(
        puzzle: puzzle,
        lineColor: Theme.of(context).colorScheme.outline,
      ),
      size: Size.infinite,
    );
  }
}

class _AcceptedRegionBorderLayer extends StatelessWidget {
  const _AcceptedRegionBorderLayer({
    required this.puzzle,
    required this.acceptedRegions,
    required this.borderColor,
  });

  final Puzzle puzzle;
  final List<PuzzleRegion> acceptedRegions;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _AcceptedRegionBorderPainter(
        puzzle: puzzle,
        acceptedRegions: acceptedRegions,
        borderColor: borderColor,
      ),
      size: Size.infinite,
    );
  }
}

class _ClueLayer extends StatelessWidget {
  const _ClueLayer({required this.puzzle, required this.clueColor});

  final Puzzle puzzle;
  final Color clueColor;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cellSize = constraints.maxWidth / puzzle.width;

        return Stack(
          children: [
            for (final clue in puzzle.clues)
              Positioned(
                left: clue.position.x * cellSize,
                top: clue.position.y * cellSize,
                width: cellSize,
                height: cellSize,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(2),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        clue.value.toString(),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: clueColor,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _RegionPainter extends CustomPainter {
  const _RegionPainter({
    required this.puzzle,
    required this.acceptedRegions,
    required this.currentSelection,
    required this.colorScheme,
  });

  final Puzzle puzzle;
  final List<PuzzleRegion> acceptedRegions;
  final PuzzleRegion? currentSelection;
  final PuzzleBoardColorScheme colorScheme;

  @override
  void paint(Canvas canvas, Size size) {
    final cellSize = size.width / puzzle.width;

    for (var index = 0; index < acceptedRegions.length; index++) {
      final color =
          colorScheme.regionColors[index % colorScheme.regionColors.length];
      _paintRegion(canvas, acceptedRegions[index], cellSize, color);
    }

    final selection = currentSelection;
    if (selection != null) {
      _paintRegion(canvas, selection, cellSize, colorScheme.selectionColor);
    }
  }

  void _paintRegion(
    Canvas canvas,
    PuzzleRegion region,
    double cellSize,
    Color color,
  ) {
    final rect = Rect.fromLTRB(
      region.left * cellSize,
      region.top * cellSize,
      (region.right + 1) * cellSize,
      (region.bottom + 1) * cellSize,
    );
    final paint = Paint()..color = color;

    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(_RegionPainter oldDelegate) {
    return oldDelegate.acceptedRegions != acceptedRegions ||
        oldDelegate.currentSelection != currentSelection ||
        oldDelegate.colorScheme != colorScheme;
  }
}

class _GridPainter extends CustomPainter {
  const _GridPainter({required this.puzzle, required this.lineColor});

  final Puzzle puzzle;
  final Color lineColor;

  @override
  void paint(Canvas canvas, Size size) {
    final cellSize = size.width / puzzle.width;
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = PuzzleUiConstants.cellBorderWidth;

    for (var x = 1; x < puzzle.width; x++) {
      final offset = x * cellSize;
      canvas.drawLine(Offset(offset, 0), Offset(offset, size.height), paint);
    }

    for (var y = 1; y < puzzle.height; y++) {
      final offset = y * cellSize;
      canvas.drawLine(Offset(0, offset), Offset(size.width, offset), paint);
    }
  }

  @override
  bool shouldRepaint(_GridPainter oldDelegate) {
    return oldDelegate.puzzle != puzzle || oldDelegate.lineColor != lineColor;
  }
}

class _AcceptedRegionBorderPainter extends CustomPainter {
  const _AcceptedRegionBorderPainter({
    required this.puzzle,
    required this.acceptedRegions,
    required this.borderColor,
  });

  final Puzzle puzzle;
  final List<PuzzleRegion> acceptedRegions;
  final Color borderColor;

  @override
  void paint(Canvas canvas, Size size) {
    final cellSize = size.width / puzzle.width;
    final paint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = PuzzleUiConstants.acceptedRegionBorderWidth;

    for (final region in acceptedRegions) {
      final rect = Rect.fromLTRB(
        region.left * cellSize,
        region.top * cellSize,
        (region.right + 1) * cellSize,
        (region.bottom + 1) * cellSize,
      );
      canvas.drawRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(_AcceptedRegionBorderPainter oldDelegate) {
    return oldDelegate.puzzle != puzzle ||
        oldDelegate.acceptedRegions != acceptedRegions ||
        oldDelegate.borderColor != borderColor;
  }
}
