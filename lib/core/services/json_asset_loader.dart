import 'package:flutter/services.dart';

/// Reads JSON text from bundled Flutter assets.
class JsonAssetLoader {
  /// Creates an asset loader.
  const JsonAssetLoader();

  /// Loads a JSON asset as a string.
  Future<String> loadString(String assetPath) {
    return rootBundle.loadString(assetPath);
  }
}
