import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../campus_map/models/campus_place.dart';
import '../../location/services/location_service.dart';

class ArNavigationPreview extends StatelessWidget {
  const ArNavigationPreview({
    super.key,
    required this.destination,
    required this.position,
  });

  final CampusPlace destination;
  final Position? position;

  @override
  Widget build(BuildContext context) {
    final bearing = position == null
        ? 0.0
        : LocationService.bearingToPlace(position!, destination);
    final distance = position == null
        ? null
        : LocationService.distanceToPlace(position!, destination);

    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: const Color(0xFF102D2A),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _ArGridPainter())),
          Center(
            child: Transform.rotate(
              angle: LocationService.bearingToRadians(bearing),
              child: const Icon(
                Icons.navigation,
                color: Colors.white,
                size: 96,
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            top: 16,
            child: _OverlayChip(icon: Icons.flag, text: destination.name),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: _OverlayChip(
              icon: Icons.route,
              text: distance == null
                  ? 'Đang chờ GPS realtime'
                  : '${LocationService.formatDistance(distance)} • ${LocationService.formatBearing(bearing)}',
            ),
          ),
        ],
      ),
    );
  }
}

class _OverlayChip extends StatelessWidget {
  const _OverlayChip({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xDDFFFFFF),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF087F8C)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = const Color(0x22FFFFFF)
      ..strokeWidth = 1;
    final horizon = Paint()
      ..color = const Color(0x44FFFFFF)
      ..strokeWidth = 2;

    for (var i = 1; i < 6; i++) {
      final y = size.height * i / 6;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    for (var i = 1; i < 5; i++) {
      final x = size.width * i / 5;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }

    canvas.drawLine(
      Offset(0, size.height * 0.55),
      Offset(size.width, size.height * 0.45),
      horizon,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
