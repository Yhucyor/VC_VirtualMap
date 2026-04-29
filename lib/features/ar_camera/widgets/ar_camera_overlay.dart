import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../campus_map/models/campus_place.dart';
import '../../location/services/location_service.dart';

class ArCameraOverlay extends StatelessWidget {
  const ArCameraOverlay({
    super.key,
    required this.destination,
    required this.position,
    required this.cameraReady,
    required this.gpsReady,
    required this.cameraMessage,
    required this.gpsMessage,
  });

  final CampusPlace destination;
  final Position? position;
  final bool cameraReady;
  final bool gpsReady;
  final String cameraMessage;
  final String gpsMessage;

  @override
  Widget build(BuildContext context) {
    final distance = position == null
        ? null
        : LocationService.distanceToPlace(position!, destination);
    final bearing = position == null
        ? 0.0
        : LocationService.bearingToPlace(position!, destination);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 74, 16, 20),
        child: Column(
          children: [
            _TopHud(
              destination: destination,
              cameraReady: cameraReady,
              gpsReady: gpsReady,
              gpsMessage: gpsMessage,
            ),
            const Spacer(),
            _DirectionArrow(bearing: bearing),
            const SizedBox(height: 18),
            _BottomHud(
              destination: destination,
              distance: distance,
              bearing: bearing,
              cameraMessage: cameraMessage,
              gpsMessage: gpsMessage,
            ),
          ],
        ),
      ),
    );
  }
}

class _TopHud extends StatelessWidget {
  const _TopHud({
    required this.destination,
    required this.cameraReady,
    required this.gpsReady,
    required this.gpsMessage,
  });

  final CampusPlace destination;
  final bool cameraReady;
  final bool gpsReady;
  final String gpsMessage;

  @override
  Widget build(BuildContext context) {
    return _GlassPanel(
      child: Row(
        children: [
          Icon(destination.icon, color: Colors.white),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  destination.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  gpsMessage,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _StatusDot(active: cameraReady, label: 'CAM'),
          const SizedBox(width: 6),
          _StatusDot(active: gpsReady, label: 'GPS'),
        ],
      ),
    );
  }
}

class _DirectionArrow extends StatelessWidget {
  const _DirectionArrow({required this.bearing});

  final double bearing;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: LocationService.bearingToRadians(bearing),
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xDD087F8C),
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: const [
            BoxShadow(
              color: Color(0x66000000),
              blurRadius: 18,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: const SizedBox(
          width: 118,
          height: 118,
          child: Icon(Icons.navigation, size: 76, color: Colors.white),
        ),
      ),
    );
  }
}

class _BottomHud extends StatelessWidget {
  const _BottomHud({
    required this.destination,
    required this.distance,
    required this.bearing,
    required this.cameraMessage,
    required this.gpsMessage,
  });

  final CampusPlace destination;
  final double? distance;
  final double bearing;
  final String cameraMessage;
  final String gpsMessage;

  @override
  Widget build(BuildContext context) {
    return _GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.route, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  distance == null
                      ? 'Đang chờ GPS để tính khoảng cách'
                      : '${LocationService.formatDistance(distance!)} • ${LocationService.formatBearing(bearing)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 17,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _RouteHint(text: destination.routeSteps.first),
          const SizedBox(height: 8),
          Text(
            cameraMessage,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          Text(
            gpsMessage,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _RouteHint extends StatelessWidget {
  const _RouteHint({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.assistant_direction, color: Colors.white70, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text, style: const TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}

class _StatusDot extends StatelessWidget {
  const _StatusDot({required this.active, required this.label});

  final bool active;
  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: active ? const Color(0xFF1DB954) : const Color(0xFFB3261E),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 11,
          ),
        ),
      ),
    );
  }
}

class _GlassPanel extends StatelessWidget {
  const _GlassPanel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xBB000000),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0x55FFFFFF)),
      ),
      child: Padding(padding: const EdgeInsets.all(14), child: child),
    );
  }
}
