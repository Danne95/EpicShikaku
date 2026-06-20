import 'package:flutter/foundation.dart';
import 'package:shikaku_puzzle/core/models/cell_position.dart';
import 'package:shikaku_puzzle/core/constants/puzzle_generation_constants.dart';
import 'package:shikaku_puzzle/features/puzzle/data/puzzle_repository.dart';
import 'package:shikaku_puzzle/features/puzzle/domain/puzzle.dart';
import 'package:shikaku_puzzle/features/puzzle/domain/puzzle_region.dart';
import 'package:shikaku_puzzle/features/puzzle/domain/puzzle_validation_result.dart';
import 'package:shikaku_puzzle/features/puzzle/domain/puzzle_validator.dart';

/// Coordinates puzzle loading, selections, validation, and completion state.
class PuzzleController extends ChangeNotifier {
  /// Creates a puzzle controller.
  PuzzleController({required this._repository, required this._validator});

  final PuzzleRepository _repository;
  final PuzzleValidator _validator;

  Puzzle? _puzzle;
  final List<PuzzleRegion> _acceptedRegions = [];
  PuzzleRegion? _currentSelection;
  bool _isLoading = false;
  bool _isComplete = false;
  String? _lastErrorMessage;

  /// Loaded puzzle, or null while loading.
  Puzzle? get puzzle => _puzzle;

  /// Accepted valid regions.
  List<PuzzleRegion> get acceptedRegions => List.unmodifiable(_acceptedRegions);

  /// Region currently highlighted during drag selection.
  PuzzleRegion? get currentSelection => _currentSelection;

  /// Whether the puzzle is loading.
  bool get isLoading => _isLoading;

  /// Whether the current puzzle is complete.
  bool get isComplete => _isComplete;

  /// Most recent validation or loading error.
  String? get lastErrorMessage => _lastErrorMessage;

  /// Loads the default puzzle from the repository.
  Future<void> loadDefaultPuzzle({
    int boardSize = PuzzleGenerationConstants.defaultBoardSize,
  }) async {
    await _loadPuzzle(
      () => _repository.loadDefaultPuzzle(boardSize: boardSize),
    );
  }

  /// Loads a fresh puzzle and clears the current game progress.
  Future<void> loadNewPuzzle({required int boardSize}) async {
    await _loadPuzzle(() => _repository.loadNewPuzzle(boardSize: boardSize));
  }

  Future<void> _loadPuzzle(Future<Puzzle> Function() loadPuzzle) async {
    _isLoading = true;
    _lastErrorMessage = null;
    notifyListeners();

    try {
      _puzzle = await loadPuzzle();
      _acceptedRegions.clear();
      _currentSelection = null;
      _isComplete = false;
    } catch (_) {
      _lastErrorMessage = 'Unable to load puzzle.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Updates the drag selection preview.
  void updateCurrentSelection(PuzzleRegion? selection) {
    _currentSelection = selection;
    notifyListeners();
  }

  /// Clears the current drag selection preview.
  void clearCurrentSelection() {
    updateCurrentSelection(null);
  }

  /// Attempts to accept a selected region.
  PuzzleValidationResult submitRegion(PuzzleRegion region) {
    final puzzle = _puzzle;
    if (puzzle == null) {
      return const PuzzleValidationResult.invalid('No puzzle is loaded.');
    }

    final result = _validator.validateRegion(
      puzzle: puzzle,
      candidate: region,
      acceptedRegions: _acceptedRegions,
    );

    if (result.isValid) {
      _acceptedRegions.add(region);
      _lastErrorMessage = null;
      _isComplete = _validator.isPuzzleComplete(
        puzzle: puzzle,
        acceptedRegions: _acceptedRegions,
      );
    } else {
      _lastErrorMessage = result.message;
    }

    _currentSelection = null;
    notifyListeners();
    return result;
  }

  /// Removes the accepted region containing the selected cell, if any.
  bool removeRegionAt(CellPosition position) {
    final regionIndex = _acceptedRegions.indexWhere(
      (region) => region.containsPosition(position),
    );

    if (regionIndex == -1) {
      return false;
    }

    _acceptedRegions.removeAt(regionIndex);
    _currentSelection = null;
    _isComplete = false;
    _lastErrorMessage = null;
    notifyListeners();
    return true;
  }

  /// Resets progress for the current puzzle.
  void resetProgress() {
    _acceptedRegions.clear();
    _currentSelection = null;
    _isComplete = false;
    _lastErrorMessage = null;
    notifyListeners();
  }
}
