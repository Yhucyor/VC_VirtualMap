import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../../shared/widgets/app_panel.dart';
import '../../ar_navigation/widgets/ar_navigation_preview.dart';
import '../../campus_map/models/campus_place.dart';
import '../../location/services/location_service.dart';
import '../../location/widgets/location_status_card.dart';

class RoutePreviewPage extends StatefulWidget {
  const RoutePreviewPage({
    super.key,
    required this.destination,
    required this.initialPosition,
  });

  final CampusPlace destination;
  final Position? initialPosition;

  @override
  State<RoutePreviewPage> createState() => _RoutePreviewPageState();
}

class _RoutePreviewPageState extends State<RoutePreviewPage> {
  Position? _position;
  StreamSubscription<Position>? _positionSubscription;
  String _gpsMessage = 'Đang chuẩn bị GPS realtime';
  bool _isTracking = false;
  bool _isLoadingGps = false;

  @override
  void initState() {
    super.initState();
    _position = widget.initialPosition;
    _startTracking();
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    super.dispose();
  }

  Future<void> _startTracking() async {
    setState(() {
      _isLoadingGps = true;
      _gpsMessage = 'Đang kiểm tra quyền GPS...';
    });

    final error = await LocationService.ensureLocationReady();
    if (error != null) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoadingGps = false;
        _isTracking = false;
        _gpsMessage = error;
      });
      return;
    }

    try {
      final currentPosition = await LocationService.currentPosition();
      if (!mounted) {
        return;
      }
      setState(() {
        _position = currentPosition;
        _isTracking = true;
        _isLoadingGps = false;
        _gpsMessage = 'Đang dẫn đường bằng GPS realtime';
      });

      await _positionSubscription?.cancel();
      _positionSubscription = LocationService.positionStream().listen(
        (position) {
          if (!mounted) {
            return;
          }
          setState(() {
            _position = position;
            _gpsMessage = 'Đang dẫn đường bằng GPS realtime';
          });
        },
        onError: (Object error) {
          if (!mounted) {
            return;
          }
          setState(() {
            _isTracking = false;
            _gpsMessage = 'Lỗi GPS: $error';
          });
        },
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoadingGps = false;
        _isTracking = false;
        _gpsMessage = 'Không lấy được GPS: $error';
      });
    }
  }

  Future<void> _toggleTracking() async {
    if (_isTracking) {
      await _positionSubscription?.cancel();
      setState(() {
        _isTracking = false;
        _gpsMessage = 'Đã tạm dừng GPS realtime';
      });
      return;
    }

    await _startTracking();
  }

  @override
  Widget build(BuildContext context) {
    final distance = _position == null
        ? null
        : LocationService.distanceToPlace(_position!, widget.destination);

    return Scaffold(
      appBar: AppBar(title: const Text('Dẫn đường AR')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            AppPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    widget.destination.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${widget.destination.kind} • ${widget.destination.area}',
                  ),
                  const SizedBox(height: 8),
                  Text(widget.destination.description),
                  if (distance != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Khoảng cách GPS ước tính: ${LocationService.formatDistance(distance)}',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 14),
            ArNavigationPreview(
              destination: widget.destination,
              position: _position,
            ),
            const SizedBox(height: 14),
            LocationStatusCard(
              position: _position,
              message: _gpsMessage,
              isTracking: _isTracking,
              isLoading: _isLoadingGps,
              destination: widget.destination,
              onToggleTracking: _toggleTracking,
            ),
            const SizedBox(height: 14),
            AppPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Các bước gợi ý trong khuôn viên',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  for (var i = 0; i < widget.destination.routeSteps.length; i++)
                    _RouteStep(
                      number: i + 1,
                      text: widget.destination.routeSteps[i],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RouteStep extends StatelessWidget {
  const _RouteStep({required this.number, required this.text});

  final int number;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(radius: 14, child: Text('$number')),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
