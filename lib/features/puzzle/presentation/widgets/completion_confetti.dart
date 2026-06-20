import 'dart:math';

import 'package:flutter/material.dart';

/// Draws a short confetti celebration driven by an external animation.
class CompletionConfetti extends AnimatedWidget {
  /// Creates a board completion confetti effect.
  const CompletionConfetti({required Animation<double> animation, super.key})
    : super(listenable: animation);

  Animation<double> get _animation => listenable as Animation<double>;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _CompletionConfettiPainter(progress: _animation.value),
        size: Size.infinite,
      ),
    );
  }
}

class _CompletionConfettiPainter extends CustomPainter {
  const _CompletionConfettiPainter({required this.progress});

  final double progress;

  static const _colors = <Color>[
    Color(0xFFEF476F),
    Color(0xFFFFD166),
    Color(0xFF06D6A0),
    Color(0xFF118AB2),
    Color(0xFF9B5DE5),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0) {
      return;
    }

    for (var index = 0; index < 48; index++) {
      final seed = index * 0.618;
      final startX = (seed % 1) * size.width;
      final startY = ((seed * 1.73) % 0.24) * size.height;
      final drift = sin(progress * pi * 3 + seed * pi) * 28;
      final x = startX + drift;
      final y = startY + progress * size.height * 0.9;
      final opacity = (1 - progress).clamp(0.0, 1.0);
      final paint = Paint()
        ..color = _colors[index % _colors.length].withValues(alpha: opacity);

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(progress * pi * 2 + seed);
      canvas.drawRect(
        Rect.fromCenter(center: Offset.zero, width: 7, height: 4),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_CompletionConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
