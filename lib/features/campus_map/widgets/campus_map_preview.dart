import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/campus_places.dart';
import '../models/campus_place.dart';

class CampusMapPreview extends StatelessWidget {
  const CampusMapPreview({
    super.key,
    required this.selectedPlace,
    required this.onPlaceSelected,
  });

  final CampusPlace selectedPlace;
  final ValueChanged<CampusPlace> onPlaceSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _MapHeader(),
        const SizedBox(height: 10),
        AspectRatio(
          aspectRatio: 0.72,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  CustomPaint(
                    size: Size.infinite,
                    painter: _OpenDayMapPainter(),
                  ),
                  for (final place in campusPlaces)
                    Positioned(
                      left: place.mapPosition.dx * constraints.maxWidth - 15,
                      top: place.mapPosition.dy * constraints.maxHeight - 15,
                      child: _MapPin(
                        place: place,
                        selected: place.id == selectedPlace.id,
                        onTap: () => onPlaceSelected(place),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        const _MapLegend(),
      ],
    );
  }
}

class _MapHeader extends StatelessWidget {
  const _MapHeader();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF0B5DA8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Icon(Icons.map, color: Colors.white),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'SƠ ĐỒ VỊ TRÍ HCM-UTE OPEN DAY 2026',
                style: TextStyle(
                  color: Color(0xFFFFD72E),
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapLegend extends StatelessWidget {
  const _MapLegend();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: const [
        _LegendItem(color: Color(0xFF1E5AA8), label: 'Khối nhà 3D'),
        _LegendItem(color: Color(0xFF78C66A), label: 'Mảng xanh'),
        _LegendItem(color: Color(0xFFFFF5A8), label: 'Lối đi'),
        _LegendItem(color: Color(0xFFCC2B7A), label: 'Điểm A/B'),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(label),
      ],
    );
  }
}

class _MapPin extends StatelessWidget {
  const _MapPin({
    required this.place,
    required this.selected,
    required this.onTap,
  });

  final CampusPlace place;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isNamedStop = place.mapLabel.isNotEmpty;
    final color = selected
        ? Theme.of(context).colorScheme.error
        : isNamedStop
        ? const Color(0xFF4056A1)
        : Theme.of(context).colorScheme.primary;
    final size = selected ? 38.0 : 30.0;

    return Tooltip(
      message: place.name,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: const [
              BoxShadow(
                color: Color(0x44000000),
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: isNamedStop
                ? Text(
                    place.mapLabel,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: place.mapLabel.length > 1 ? 11 : 14,
                    ),
                  )
                : Icon(place.icon, color: Colors.white, size: 16),
          ),
        ),
      ),
    );
  }
}

class _OpenDayMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final mapRect = Offset.zero & size;
    final p = _Projector(size);

    final panelPaint = Paint()..color = Colors.white;
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = const Color(0xFF1F4E9E);

    canvas.drawRRect(
      RRect.fromRectAndRadius(mapRect, const Radius.circular(14)),
      panelPaint,
    );

    final campus = Path()
      ..moveTo(p.x(0.06), p.y(0.10))
      ..lineTo(p.x(0.46), p.y(0.08))
      ..lineTo(p.x(0.48), p.y(0.18))
      ..lineTo(p.x(0.72), p.y(0.12))
      ..lineTo(p.x(0.91), p.y(0.50))
      ..lineTo(p.x(0.97), p.y(0.75))
      ..quadraticBezierTo(p.x(0.93), p.y(0.93), p.x(0.78), p.y(0.96))
      ..lineTo(p.x(0.49), p.y(0.96))
      ..lineTo(p.x(0.47), p.y(0.86))
      ..lineTo(p.x(0.06), p.y(0.92))
      ..lineTo(p.x(0.05), p.y(0.70))
      ..lineTo(p.x(0.09), p.y(0.62))
      ..lineTo(p.x(0.09), p.y(0.34))
      ..lineTo(p.x(0.06), p.y(0.10))
      ..close();

    canvas.drawPath(campus, Paint()..color = const Color(0xFFF8FFF4));
    canvas.drawPath(campus, borderPaint);

    _drawRoads(canvas, p);
    _drawGreens(canvas, p);
    _drawBuildings(canvas, p);
    _drawGates(canvas, p);
    _drawHealthAndBooths(canvas, p);
    _drawOuterLabels(canvas, p);
  }

  void _drawRoads(Canvas canvas, _Projector p) {
    final mainRoad = Paint()
      ..color = const Color(0xFFFFF4A6)
      ..strokeWidth = p.w(0.040)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final roadBorder = Paint()
      ..color = const Color(0xFFE7D975)
      ..strokeWidth = p.w(0.045)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final whitePath = Paint()
      ..color = Colors.white
      ..strokeWidth = p.w(0.030)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    void road(List<Offset> points, Paint paint) {
      final path = Path()..moveTo(p.x(points.first.dx), p.y(points.first.dy));
      for (final point in points.skip(1)) {
        path.lineTo(p.x(point.dx), p.y(point.dy));
      }
      canvas.drawPath(path, paint);
    }

    final central = [
      const Offset(0.22, 0.68),
      const Offset(0.42, 0.68),
      const Offset(0.50, 0.64),
      const Offset(0.56, 0.60),
      const Offset(0.61, 0.47),
      const Offset(0.62, 0.32),
      const Offset(0.79, 0.35),
      const Offset(0.79, 0.63),
      const Offset(0.73, 0.74),
      const Offset(0.56, 0.76),
      const Offset(0.49, 0.94),
    ];
    road(central, roadBorder);
    road(central, mainRoad);

    road([
      const Offset(0.18, 0.90),
      const Offset(0.23, 0.76),
      const Offset(0.29, 0.66),
      const Offset(0.42, 0.66),
    ], roadBorder);
    road([
      const Offset(0.18, 0.90),
      const Offset(0.23, 0.76),
      const Offset(0.29, 0.66),
      const Offset(0.42, 0.66),
    ], mainRoad);

    road([
      const Offset(0.57, 0.43),
      const Offset(0.73, 0.43),
      const Offset(0.75, 0.62),
    ], whitePath);
    road([
      const Offset(0.58, 0.73),
      const Offset(0.76, 0.74),
      const Offset(0.92, 0.78),
    ], whitePath);
  }

  void _drawGreens(Canvas canvas, _Projector p) {
    final green = Paint()..color = const Color(0xFF71C46C);
    final lightGreen = Paint()..color = const Color(0xFF9BD27C);

    _roundRect(canvas, p, 0.44, 0.22, 0.24, 0.18, green);
    _roundRect(canvas, p, 0.44, 0.42, 0.24, 0.15, green);
    _roundRect(canvas, p, 0.70, 0.28, 0.12, 0.13, green);
    _roundRect(canvas, p, 0.12, 0.80, 0.28, 0.15, green);
    _roundRect(canvas, p, 0.45, 0.80, 0.22, 0.12, green);
    _roundRect(canvas, p, 0.70, 0.76, 0.18, 0.13, green);
    _roundRect(canvas, p, 0.12, 0.65, 0.11, 0.11, lightGreen);
    _roundRect(canvas, p, 0.12, 0.50, 0.07, 0.10, green);

    final field = Rect.fromLTWH(p.x(0.69), p.y(0.73), p.w(0.18), p.h(0.14));
    canvas.drawRRect(
      RRect.fromRectAndRadius(field, Radius.circular(p.w(0.006))),
      Paint()..color = const Color(0xFF68BE61),
    );
    final fieldLine = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3;
    canvas.drawLine(field.centerLeft, field.centerRight, fieldLine);
    canvas.drawCircle(field.center, p.w(0.030), fieldLine);
    _drawText(
      canvas,
      p,
      'SÂN VẬN ĐỘNG',
      0.71,
      0.77,
      size: 8,
      color: const Color(0xFF1E7F3E),
    );
  }

  void _drawBuildings(Canvas canvas, _Projector p) {
    const blue = Color(0xFF2F65B0);
    const lightBlue = Color(0xFFAED1E8);
    const darkBlue = Color(0xFF204A90);

    _building3d(canvas, p, 0.49, 0.74, 0.08, 0.06, blue, 'A2');
    _building3d(canvas, p, 0.49, 0.70, 0.08, 0.04, blue, 'A3');
    _building3d(canvas, p, 0.62, 0.74, 0.08, 0.06, blue, 'A4');
    _building3d(canvas, p, 0.62, 0.70, 0.08, 0.04, blue, 'A5');
    _building3d(
      canvas,
      p,
      0.57,
      0.70,
      0.06,
      0.09,
      darkBlue,
      'TÒA NHÀ\nTRUNG TÂM',
    );

    _building3d(canvas, p, 0.50, 0.58, 0.12, 0.07, darkBlue, 'HỘI TRƯỜNG\nLỚN');
    _building3d(canvas, p, 0.51, 0.42, 0.11, 0.07, darkBlue, 'THƯ VIỆN');
    _building3d(canvas, p, 0.45, 0.28, 0.05, 0.12, blue, 'KHU NHÀ C');
    _building3d(canvas, p, 0.53, 0.28, 0.05, 0.12, blue, 'KHU NHÀ B');
    _building3d(canvas, p, 0.44, 0.47, 0.05, 0.12, blue, 'KHU NHÀ D');

    _building3d(canvas, p, 0.72, 0.56, 0.10, 0.08, blue, 'F1');
    _building3d(canvas, p, 0.72, 0.65, 0.09, 0.07, blue, 'G');
    _building3d(
      canvas,
      p,
      0.84,
      0.55,
      0.12,
      0.12,
      blue,
      'MAKER SPACE\nHCM-UTE',
    );
    _building3d(canvas, p, 0.31, 0.82, 0.12, 0.09, lightBlue, 'NHÀ THI ĐẤU');

    _buildingFlat(canvas, p, 0.17, 0.63, 0.11, 0.05, lightBlue, '2');
    _buildingFlat(canvas, p, 0.29, 0.63, 0.11, 0.05, lightBlue, '3');
    _buildingFlat(canvas, p, 0.36, 0.63, 0.09, 0.12, lightBlue, '13');
    _buildingFlat(canvas, p, 0.26, 0.79, 0.06, 0.13, lightBlue, '');
    _buildingFlat(canvas, p, 0.12, 0.68, 0.04, 0.10, blue, '3');
    _buildingFlat(canvas, p, 0.72, 0.47, 0.12, 0.04, blue, '9');
    _buildingFlat(canvas, p, 0.70, 0.52, 0.13, 0.04, lightBlue, '10');
    _buildingFlat(canvas, p, 0.72, 0.41, 0.09, 0.05, lightBlue, '');
    _buildingFlat(
      canvas,
      p,
      0.82,
      0.46,
      0.04,
      0.12,
      lightBlue,
      'THANG\nDUY TÂN',
    );
  }

  void _drawGates(Canvas canvas, _Projector p) {
    _gate(canvas, p, 0.22, 0.98, 'CỔNG PHỤ');
    _gate(canvas, p, 0.53, 0.98, 'CỔNG CHÍNH');
    _gate(canvas, p, 0.83, 0.30, 'CỔNG B');
    _gate(canvas, p, 0.95, 0.75, 'CỔNG F');
    _drawText(
      canvas,
      p,
      'ĐƯỜNG VÕ VĂN NGÂN',
      0.60,
      0.95,
      size: 8,
      color: const Color(0xFF34518F),
    );
    _drawText(
      canvas,
      p,
      'ĐƯỜNG LÊ VĂN CHÍ',
      0.88,
      0.42,
      size: 8,
      color: const Color(0xFF34518F),
    );
  }

  void _drawHealthAndBooths(Canvas canvas, _Projector p) {
    _drawTextBox(canvas, p, 'VP TƯ VẤN TUYỂN SINH', 0.55, 0.90, 0.20, 0.03);
    _drawVerticalBooths(canvas, p, 0.57, 0.48, 0.035, 0.12);
    _drawVerticalBooths(canvas, p, 0.58, 0.37, 0.035, 0.10);

    final healthRect = Rect.fromLTWH(
      p.x(0.66),
      p.y(0.25),
      p.w(0.04),
      p.h(0.04),
    );
    canvas.drawRect(healthRect, Paint()..color = const Color(0xFFE62F45));
    _drawText(canvas, p, '+', 0.672, 0.252, size: 16, color: Colors.white);

    _drawText(
      canvas,
      p,
      'B',
      0.58,
      0.50,
      size: 12,
      color: const Color(0xFFCC2B7A),
    );
    _drawText(
      canvas,
      p,
      'B',
      0.57,
      0.57,
      size: 12,
      color: const Color(0xFFCC2B7A),
    );
  }

  void _drawOuterLabels(Canvas canvas, _Projector p) {
    _drawText(canvas, p, 'KHU NHÀ A', 0.49, 0.73, size: 7, color: Colors.white);
    _drawText(canvas, p, 'KHU NHÀ B', 0.53, 0.36, size: 7, color: Colors.white);
    _drawText(canvas, p, 'KHU NHÀ C', 0.45, 0.35, size: 7, color: Colors.white);
    _drawText(canvas, p, 'KHU NHÀ D', 0.44, 0.54, size: 7, color: Colors.white);
  }

  void _building3d(
    Canvas canvas,
    _Projector p,
    double x,
    double y,
    double w,
    double h,
    Color color,
    String label,
  ) {
    final rect = Rect.fromLTWH(p.x(x), p.y(y), p.w(w), p.h(h));
    final depth = Offset(p.w(0.012), -p.h(0.012));
    final sidePaint = Paint()..color = _darken(color, 0.18);
    final topPaint = Paint()..color = _lighten(color, 0.10);
    final frontPaint = Paint()..color = color;

    final top = Path()
      ..moveTo(rect.left, rect.top)
      ..lineTo(rect.right, rect.top)
      ..lineTo(rect.right + depth.dx, rect.top + depth.dy)
      ..lineTo(rect.left + depth.dx, rect.top + depth.dy)
      ..close();
    final side = Path()
      ..moveTo(rect.right, rect.top)
      ..lineTo(rect.right, rect.bottom)
      ..lineTo(rect.right + depth.dx, rect.bottom + depth.dy)
      ..lineTo(rect.right + depth.dx, rect.top + depth.dy)
      ..close();

    canvas.drawPath(top, topPaint);
    canvas.drawPath(side, sidePaint);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(p.w(0.004))),
      frontPaint,
    );

    if (label.isNotEmpty) {
      _drawTextInRect(canvas, label, rect, fontSize: w > 0.10 ? 8 : 7);
    }
  }

  void _buildingFlat(
    Canvas canvas,
    _Projector p,
    double x,
    double y,
    double w,
    double h,
    Color color,
    String label,
  ) {
    final rect = Rect.fromLTWH(p.x(x), p.y(y), p.w(w), p.h(h));
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(p.w(0.004))),
      Paint()..color = color,
    );
    if (label.isNotEmpty) {
      _drawTextInRect(canvas, label, rect, fontSize: label.length > 2 ? 7 : 9);
    }
  }

  void _roundRect(
    Canvas canvas,
    _Projector p,
    double x,
    double y,
    double w,
    double h,
    Paint paint,
  ) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(p.x(x), p.y(y), p.w(w), p.h(h)),
        Radius.circular(p.w(0.008)),
      ),
      paint,
    );
  }

  void _gate(Canvas canvas, _Projector p, double x, double y, String label) {
    final blue = Paint()..color = const Color(0xFF2F65B0);
    final red = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = const Color(0xFFE62F45);
    final inArrow = Path()
      ..moveTo(p.x(x), p.y(y - 0.03))
      ..lineTo(p.x(x - 0.015), p.y(y))
      ..lineTo(p.x(x + 0.015), p.y(y))
      ..close();
    final outArrow = Path()
      ..moveTo(p.x(x + 0.04), p.y(y))
      ..lineTo(p.x(x + 0.025), p.y(y - 0.03))
      ..lineTo(p.x(x + 0.055), p.y(y - 0.03))
      ..close();
    canvas.drawPath(inArrow, blue);
    canvas.drawPath(outArrow, red);
    _drawText(
      canvas,
      p,
      label,
      x - 0.04,
      y + 0.015,
      size: 8,
      color: const Color(0xFF2F65B0),
    );
  }

  void _drawVerticalBooths(
    Canvas canvas,
    _Projector p,
    double x,
    double y,
    double w,
    double h,
  ) {
    final boothPaint = Paint()..color = const Color(0xFFE64B7A);
    for (var i = 0; i < 4; i++) {
      canvas.drawRect(
        Rect.fromLTWH(p.x(x), p.y(y + i * h / 4), p.w(w), p.h(h / 5)),
        boothPaint,
      );
    }
  }

  void _drawTextBox(
    Canvas canvas,
    _Projector p,
    String text,
    double x,
    double y,
    double w,
    double h,
  ) {
    final rect = Rect.fromLTWH(p.x(x), p.y(y), p.w(w), p.h(h));
    canvas.drawRect(rect, Paint()..color = const Color(0xFFEDEDED));
    canvas.drawRect(
      Rect.fromLTWH(
        rect.left,
        rect.bottom - p.h(0.008),
        rect.width,
        p.h(0.008),
      ),
      Paint()..color = const Color(0xFFE62F45),
    );
    _drawTextInRect(
      canvas,
      text,
      rect,
      color: const Color(0xFF274B7A),
      fontSize: 7,
    );
  }

  void _drawText(
    Canvas canvas,
    _Projector p,
    String text,
    double x,
    double y, {
    double size = 9,
    Color color = const Color(0xFF0F416B),
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: size,
          fontWeight: FontWeight.w900,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 2,
    )..layout(maxWidth: p.w(0.20));
    painter.paint(canvas, Offset(p.x(x), p.y(y)));
  }

  void _drawTextInRect(
    Canvas canvas,
    String text,
    Rect rect, {
    Color color = Colors.white,
    double fontSize = 8,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: FontWeight.w900,
          height: 1.05,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
      maxLines: 3,
    )..layout(maxWidth: math.max(20, rect.width - 4));

    painter.paint(
      canvas,
      Offset(
        rect.left + (rect.width - painter.width) / 2,
        rect.top + (rect.height - painter.height) / 2,
      ),
    );
  }

  Color _darken(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withLightness((hsl.lightness - amount).clamp(0.0, 1.0))
        .toColor();
  }

  Color _lighten(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withLightness((hsl.lightness + amount).clamp(0.0, 1.0))
        .toColor();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _Projector {
  const _Projector(this.size);

  final Size size;

  double x(double value) => size.width * value;
  double y(double value) => size.height * value;
  double w(double value) => size.width * value;
  double h(double value) => size.height * value;
}
