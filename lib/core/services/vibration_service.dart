import 'package:flutter/services.dart';

/// Triggers device vibration through the native Android vibrator service.
class VibrationService {
  const VibrationService._();

  static const _channel = MethodChannel('shikaku_puzzle/vibration');

  /// Vibrates for a normal accepted move.
  static Future<void> vibrateMove() async {
    await _channel.invokeMethod<void>('vibrate', 35);
  }

  /// Vibrates for puzzle completion.
  static Future<void> vibrateWin() async {
    await _channel.invokeMethod<void>('vibrate', 140);
  }
}
