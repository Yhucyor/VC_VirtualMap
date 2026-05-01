import 'package:flutter/material.dart';

class UteMapLogo extends StatelessWidget {
  const UteMapLogo({
    super.key,
    this.size = 120,
    this.primaryColor,
    this.secondaryColor,
  });

  final double size;
  final Color? primaryColor;
  final Color? secondaryColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final mainColor = primaryColor ?? colorScheme.primary;
    final accentColor = secondaryColor ?? colorScheme.secondary;

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _CamapusLogoPainter(
          mainColor: mainColor,
          accentColor: accentColor,
          surfaceColor: colorScheme.surface,
          textColor: colorScheme.onSurface,
        ),
      ),
    );
  }
}

class _CamapusLogoPainter extends CustomPainter {
  const _CamapusLogoPainter({
    required this.mainColor,
    required this.accentColor,
    required this.surfaceColor,
    required this.textColor,
  });

  final Color mainColor;
  final Color accentColor;
  final Color surfaceColor;
  final Color textColor;

  @override
  void paint(Canvas canvas, Size size) {
    final shortest = size.shortestSide;
    final center = Offset(size.width / 2, size.height / 2);
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.16)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

    final badgeRect = Rect.fromCenter(
      center: center,
      width: shortest * 0.84,
      height: shortest * 0.84,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        badgeRect.translate(0, shortest * 0.035),
        Radius.circular(shortest * 0.22),
      ),
      shadowPaint,
    );

    final badgePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          mainColor,
          Color.lerp(mainColor, const Color(0xFF1B5E7A), 0.45)!,
        ],
      ).createShader(badgeRect);
    canvas.drawRRect(
      RRect.fromRectAndRadius(badgeRect, Radius.circular(shortest * 0.22)),
      badgePaint,
    );

    final foldPaint = Paint()..color = Colors.white.withValues(alpha: 0.20);
    for (final dx in [-0.18, 0.0, 0.18]) {
      final fold = Rect.fromCenter(
        center: center.translate(shortest * dx, shortest * 0.02),
        width: shortest * 0.17,
        height: shortest * 0.54,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(fold, Radius.circular(shortest * 0.04)),
        foldPaint,
      );
    }

    final routePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = shortest * 0.035
      ..strokeCap = StrokeCap.round;
    final route = Path()
      ..moveTo(center.dx - shortest * 0.28, center.dy + shortest * 0.16)
      ..cubicTo(
        center.dx - shortest * 0.08,
        center.dy - shortest * 0.12,
        center.dx + shortest * 0.10,
        center.dy + shortest * 0.26,
        center.dx + shortest * 0.28,
        center.dy - shortest * 0.04,
      );
    canvas.drawPath(route, routePaint);

    final pinPaint = Paint()..color = accentColor;
    final pinPath = Path()
      ..addOval(
        Rect.fromCircle(
          center: center.translate(0, -shortest * 0.13),
          radius: shortest * 0.19,
        ),
      )
      ..moveTo(center.dx - shortest * 0.11, center.dy)
      ..quadraticBezierTo(
        center.dx,
        center.dy + shortest * 0.28,
        center.dx + shortest * 0.11,
        center.dy,
      )
      ..close();
    canvas.drawPath(pinPath, pinPaint);
    canvas.drawCircle(
      center.translate(0, -shortest * 0.13),
      shortest * 0.075,
      Paint()..color = surfaceColor,
    );

    final textPainter = TextPainter(
      text: TextSpan(
        text: 'c',
        style: TextStyle(
          color: textColor,
          fontSize: shortest * 0.20,
          fontWeight: FontWeight.w900,
          height: 1,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - shortest * 0.13 - textPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant _CamapusLogoPainter oldDelegate) {
    return oldDelegate.mainColor != mainColor ||
        oldDelegate.accentColor != accentColor ||
        oldDelegate.surfaceColor != surfaceColor ||
        oldDelegate.textColor != textColor;
  }
}
