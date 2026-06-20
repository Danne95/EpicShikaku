import 'dart:convert';

import 'package:shikaku_puzzle/core/constants/puzzle_asset_paths.dart';
import 'package:shikaku_puzzle/core/services/json_asset_loader.dart';
import 'package:shikaku_puzzle/features/puzzle/data/puzzle_repository.dart';
import 'package:shikaku_puzzle/features/puzzle/domain/puzzle.dart';

/// Loads puzzle definitions from bundled JSON assets.
class AssetPuzzleRepository implements PuzzleRepository {
  /// Creates an asset-backed repository.
  const AssetPuzzleRepository({
    this.assetLoader = const JsonAssetLoader(),
  });

  /// Asset loader used to read bundled JSON files.
  final JsonAssetLoader assetLoader;

  @override
  Future<Puzzle> loadDefaultPuzzle() async {
    final jsonText = await assetLoader.loadString(PuzzleAssetPaths.sample5x5);
    final jsonMap = Map<String, Object?>.from(jsonDecode(jsonText) as Map);

    return Puzzle.fromJson(jsonMap);
  }
}
