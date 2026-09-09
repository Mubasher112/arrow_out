import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../domain/models/arrow_direction.dart';
import '../../domain/models/arrow_state.dart';
import '../theme/app_theme.dart';

/// Custom Painter drawing vibrant rounded directional arrows with bevel and shadow.
class ArrowPainter extends CustomPainter {
  final ArrowDirection direction;
  final ArrowState state;
  final bool isHighlighted;

  ArrowPainter({
    required this.direction,
    required this.state,
    this.isHighlighted = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;

    // Determine angle based on direction
    double angleInRadians = 0;
    switch (direction) {
      case ArrowDirection.up:
        angleInRadians = -math.pi / 2;
        break;
      case ArrowDirection.down:
        angleInRadians = math.pi / 2;
        break;
      case ArrowDirection.left:
        angleInRadians = math.pi;
        break;
      case ArrowDirection.right:
        angleInRadians = 0;
        break;
    }

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angleInRadians);

    // Arrow fill colors
    Color arrowColor = AppTheme.arrowDefault;
    if (state == ArrowState.blocked) {
      arrowColor = AppTheme.arrowBlocked;
    } else if (isHighlighted) {
      arrowColor = AppTheme.goldStar;
    }

    final Paint arrowPaint = Paint()
      ..color = arrowColor
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    // Draw Arrow path relative to local origin (0, 0)
    final path = Path();
    final arrowLen = radius * 0.7;
    final headWidth = radius * 0.45;
    final shaftWidth = radius * 0.22;

    // Arrow tip pointing right (angle = 0)
    path.moveTo(arrowLen, 0); // Tip
    path.lineTo(arrowLen * 0.2, -headWidth); // Upper head corner
    path.lineTo(arrowLen * 0.2, -shaftWidth); // Upper shaft corner
    path.lineTo(-arrowLen * 0.7, -shaftWidth); // Tail top
    path.quadraticBezierTo(-arrowLen * 0.85, 0, -arrowLen * 0.7, shaftWidth); // Curved tail bottom
    path.lineTo(arrowLen * 0.2, shaftWidth); // Lower shaft corner
    path.lineTo(arrowLen * 0.2, headWidth); // Lower head corner
    path.close();

    // Shadow
    canvas.drawPath(
      path.shift(const Offset(1, 2)),
      Paint()
        ..color = Colors.black.withAlpha(80)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );

    // Main arrow body
    canvas.drawPath(path, arrowPaint);

    // Inner highlight bevel line
    final highlightPath = Path()
      ..moveTo(arrowLen * 0.8, 0)
      ..lineTo(arrowLen * 0.25, -headWidth * 0.6)
      ..lineTo(arrowLen * 0.25, -shaftWidth * 0.5)
      ..lineTo(-arrowLen * 0.5, -shaftWidth * 0.5);

    canvas.drawPath(
      highlightPath,
      Paint()
        ..color = Colors.white.withAlpha(120)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..strokeCap = StrokeCap.round,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant ArrowPainter oldDelegate) {
    return oldDelegate.direction != direction ||
        oldDelegate.state != state ||
        oldDelegate.isHighlighted != isHighlighted;
  }
}
