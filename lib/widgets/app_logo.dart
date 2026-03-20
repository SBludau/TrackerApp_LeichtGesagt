import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Small app icon used in the top-left header.
/// Paints a microphone (left) + three ascending bars (right).
class AppLogo extends StatelessWidget {
  final double size;

  const AppLogo({super.key, this.size = 34});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _LogoIconPainter()),
    );
  }
}

class _LogoIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double s = size.width / 1024;

    final Paint fill = Paint()
      ..color = AppColors.indigo
      ..style = PaintingStyle.fill;

    final Paint stroke = Paint()
      ..color = AppColors.indigo
      ..style = PaintingStyle.stroke
      ..strokeWidth = 48 * s
      ..strokeCap = StrokeCap.round;

    // Mic capsule
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(278 * s, 192 * s, 164 * s, 292 * s),
        Radius.circular(82 * s),
      ),
      fill,
    );

    // Mic arch (U-shape)
    final path = Path()
      ..moveTo(218 * s, 375 * s)
      ..cubicTo(218 * s, 602 * s, 504 * s, 602 * s, 504 * s, 375 * s);
    canvas.drawPath(path, stroke);

    // Mic stand
    canvas.drawLine(
      Offset(360 * s, 572 * s),
      Offset(360 * s, 664 * s),
      stroke,
    );

    // Mic base
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(276 * s, 646 * s, 168 * s, 40 * s),
        Radius.circular(20 * s),
      ),
      fill,
    );

    // Ascending bars
    final bars = [
      (568.0, 486.0, 200.0, 0.38),
      (666.0, 356.0, 330.0, 0.68),
      (764.0, 226.0, 460.0, 1.00),
    ];
    for (final (x, y, h, opacity) in bars) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x * s, y * s, 72 * s, h * s),
          Radius.circular(36 * s),
        ),
        Paint()
          ..color = AppColors.indigo.withValues(alpha: opacity)
          ..style = PaintingStyle.fill,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
