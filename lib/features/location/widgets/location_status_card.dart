import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../../shared/widgets/app_panel.dart';
import '../../campus_map/models/campus_place.dart';
import '../services/location_service.dart';

class LocationStatusCard extends StatelessWidget {
  const LocationStatusCard({
    super.key,
    required this.position,
    required this.message,
    required this.isTracking,
    required this.isLoading,
    required this.destination,
    required this.onToggleTracking,
  });

  final Position? position;
  final String message;
  final bool isTracking;
  final bool isLoading;
  final CampusPlace destination;
  final VoidCallback onToggleTracking;

  @override
  Widget build(BuildContext context) {
    final distance = position == null
        ? null
        : LocationService.distanceToPlace(position!, destination);
    final bearing = position == null
        ? null
        : LocationService.bearingToPlace(position!, destination);

    return AppPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                isTracking ? Icons.gps_fixed : Icons.gps_not_fixed,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Vị trí hiện tại',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
              ),
              _LiveBadge(active: isTracking),
            ],
          ),
          const SizedBox(height: 10),
          Text(message),
          const SizedBox(height: 10),
          if (position == null)
            const Text('Chưa có tọa độ. Bấm bật GPS realtime để cập nhật.')
          else ...[
            Text('Latitude: ${position!.latitude.toStringAsFixed(6)}'),
            Text('Longitude: ${position!.longitude.toStringAsFixed(6)}'),
            Text('Độ chính xác: ${position!.accuracy.toStringAsFixed(1)} m'),
            Text('Thời gian: ${position!.timestamp.toLocal()}'),
            const Divider(height: 22),
            Text('Cách điểm đến: ${LocationService.formatDistance(distance!)}'),
            Text('Hướng ước tính: ${LocationService.formatBearing(bearing!)}'),
          ],
          const SizedBox(height: 14),
          OutlinedButton.icon(
            key: const ValueKey('gps-toggle-button'),
            onPressed: isLoading ? null : onToggleTracking,
            icon: isLoading
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(isTracking ? Icons.pause_circle : Icons.my_location),
            label: Text(
              isTracking ? 'Tạm dừng GPS realtime' : 'Bật GPS realtime',
            ),
          ),
        ],
      ),
    );
  }
}

class _LiveBadge extends StatelessWidget {
  const _LiveBadge({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: active ? const Color(0xFFE7F8EE) : const Color(0xFFF1F1F1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        active ? 'LIVE' : 'OFF',
        style: TextStyle(
          color: active ? const Color(0xFF137333) : const Color(0xFF5F6368),
          fontWeight: FontWeight.w900,
          fontSize: 12,
        ),
      ),
    );
  }
}
