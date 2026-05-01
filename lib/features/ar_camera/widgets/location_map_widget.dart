import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../campus_map/models/campus_place.dart';
import '../../location/services/location_service.dart';

class LocationMapWidget extends StatelessWidget {
  const LocationMapWidget({
    super.key,
    required this.position,
    required this.destination,
    this.compact = false,
  });

  final Position? position;
  final CampusPlace destination;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final distance = position == null
        ? null
        : LocationService.distanceToPlace(position!, destination);
    final bearing = position == null
        ? null
        : LocationService.bearingToPlace(position!, destination);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFF6F1EA),
        borderRadius: compact ? BorderRadius.circular(18) : BorderRadius.zero,
      ),
      child: ClipRRect(
        borderRadius: compact ? BorderRadius.circular(18) : BorderRadius.zero,
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _NavigationMapPainter(destination: destination),
              ),
            ),
            Positioned(
              left: 14,
              right: 14,
              bottom: 12,
              child: _MapInfoBar(
                destination: destination,
                distance: distance,
                bearing: bearing,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapInfoBar extends StatelessWidget {
  const _MapInfoBar({
    required this.destination,
    required this.distance,
    required this.bearing,
  });

  final CampusPlace destination;
  final double? distance;
  final double? bearing;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(999),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            const Icon(Icons.location_on, color: Colors.black87),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                distance == null || bearing == null
                    ? 'Đang xác định vị trí đến ${destination.name}'
                    : '${LocationService.formatDistance(distance!)} • ${LocationService.formatBearing(bearing!)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavigationMapPainter extends CustomPainter {
  const _NavigationMapPainter({required this.destination});

  final CampusPlace destination;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFF4EEE8),
    );

    final greenPaint = Paint()..color = const Color(0xFFDCEFD7);
    final buildingPaint = Paint()..color = const Color(0xFFE0DED8);
    final roadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = size.shortestSide * 0.10
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (final rect in [
      Rect.fromLTWH(
        size.width * 0.08,
        size.height * 0.18,
        size.width * 0.24,
        size.height * 0.18,
      ),
      Rect.fromLTWH(
        size.width * 0.60,
        size.height * 0.16,
        size.width * 0.28,
        size.height * 0.20,
      ),
      Rect.fromLTWH(
        size.width * 0.10,
        size.height * 0.58,
        size.width * 0.30,
        size.height * 0.18,
      ),
      Rect.fromLTWH(
        size.width * 0.58,
        size.height * 0.58,
        size.width * 0.30,
        size.height * 0.16,
      ),
    ]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(10)),
        buildingPaint,
      );
    }

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.36,
          size.height * 0.28,
          size.width * 0.22,
          size.height * 0.20,
        ),
        const Radius.circular(12),
      ),
      greenPaint,
    );

    final road = Path()
      ..moveTo(size.width * 0.10, size.height * 0.82)
      ..lineTo(size.width * 0.32, size.height * 0.62)
      ..lineTo(size.width * 0.52, size.height * 0.55)
      ..lineTo(size.width * 0.74, size.height * 0.38)
      ..lineTo(size.width * 0.92, size.height * 0.22);
    canvas.drawPath(road, roadPaint);

    final start = Offset(size.width * 0.30, size.height * 0.72);
    final end = Offset(
      size.width * (0.20 + destination.mapPosition.dx * 0.62),
      size.height * (0.18 + destination.mapPosition.dy * 0.58),
    );
    final routePaint = Paint()
      ..color = const Color(0xFF1D5CFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final route = Path()
      ..moveTo(start.dx, start.dy)
      ..quadraticBezierTo(
        size.width * 0.48,
        size.height * 0.62,
        end.dx,
        end.dy,
      );
    canvas.drawPath(route, routePaint);

    canvas.drawCircle(start, 8, Paint()..color = const Color(0xFF22C55E));
    canvas.drawCircle(start, 4, Paint()..color = Colors.white);
    canvas.drawCircle(end, 13, Paint()..color = const Color(0xFFE53935));
    canvas.drawCircle(end, 5, Paint()..color = Colors.white);

    final label = TextPainter(
      text: TextSpan(
        text: destination.name,
        style: const TextStyle(
          color: Color(0xFF6B5F58),
          fontWeight: FontWeight.w800,
          fontSize: 13,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
      ellipsis: '...',
    )..layout(maxWidth: size.width * 0.46);
    label.paint(canvas, Offset(end.dx + 8, end.dy - 24));
  }

  @override
  bool shouldRepaint(covariant _NavigationMapPainter oldDelegate) {
    return oldDelegate.destination.id != destination.id;
  }
}
