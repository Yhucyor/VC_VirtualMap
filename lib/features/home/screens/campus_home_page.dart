import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../../shared/widgets/app_panel.dart';
import '../../ar_camera/screens/camera_navigation_page.dart';
import '../../campus_map/data/campus_places.dart';
import '../../campus_map/models/campus_place.dart';
import '../../campus_map/widgets/campus_map_preview.dart';
import '../../destination/widgets/destination_detail_card.dart';
import '../../destination/widgets/destination_picker.dart';
import '../../location/services/location_service.dart';
import '../../location/widgets/location_status_card.dart';

class CampusHomePage extends StatefulWidget {
  const CampusHomePage({super.key});

  @override
  State<CampusHomePage> createState() => _CampusHomePageState();
}

class _CampusHomePageState extends State<CampusHomePage> {
  final _destinationController = TextEditingController(
    text: 'Khu A - Tư vấn chung',
  );
  CampusPlace _selectedPlace = campusPlaces.first;
  Position? _position;
  StreamSubscription<Position>? _positionSubscription;
  String _gpsMessage = 'Chưa bật GPS realtime';
  bool _isTracking = false;
  bool _isLoadingGps = false;

  @override
  void dispose() {
    _destinationController.dispose();
    _positionSubscription?.cancel();
    super.dispose();
  }

  List<CampusPlace> get _suggestions {
    final query = _destinationController.text.trim().toLowerCase();
    if (query.isEmpty) {
      return campusPlaces.take(12).toList();
    }
    return campusPlaces
        .where((place) => place.searchText.contains(query))
        .take(12)
        .toList();
  }

  void _selectPlace(CampusPlace place) {
    setState(() {
      _selectedPlace = place;
      _destinationController.text = place.name;
    });
  }

  Future<void> _toggleGpsTracking() async {
    if (_isTracking) {
      await _positionSubscription?.cancel();
      setState(() {
        _isTracking = false;
        _gpsMessage = 'Đã tạm dừng GPS realtime';
      });
      return;
    }

    setState(() {
      _isLoadingGps = true;
      _gpsMessage = 'Đang kiểm tra quyền GPS...';
    });

    final error = await LocationService.ensureLocationReady();
    if (error != null) {
      setState(() {
        _isLoadingGps = false;
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
        _gpsMessage = 'GPS realtime đang chạy';
      });

      await _positionSubscription?.cancel();
      _positionSubscription = LocationService.positionStream().listen(
        (position) {
          if (!mounted) {
            return;
          }
          setState(() {
            _position = position;
            _gpsMessage = 'GPS realtime đang chạy';
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
      setState(() {
        _isLoadingGps = false;
        _isTracking = false;
        _gpsMessage = 'Không lấy được GPS: $error';
      });
    }
  }

  void _openCameraNavigation() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CameraNavigationPage(destination: _selectedPlace),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sơ đồ HCM-UTE Open Day'),
        actions: [
          IconButton(
            tooltip: 'Đăng xuất',
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DestinationPicker(
              controller: _destinationController,
              suggestions: _suggestions,
              selectedPlace: _selectedPlace,
              onQueryChanged: (_) => setState(() {}),
              onPlaceSelected: _selectPlace,
            ),
            const SizedBox(height: 14),
            DestinationDetailCard(
              place: _selectedPlace,
              onStartNavigation: _openCameraNavigation,
            ),
            const SizedBox(height: 14),
            LocationStatusCard(
              position: _position,
              message: _gpsMessage,
              isTracking: _isTracking,
              isLoading: _isLoadingGps,
              destination: _selectedPlace,
              onToggleTracking: _toggleGpsTracking,
            ),
            const SizedBox(height: 14),
            AppPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Bản đồ tương tác dựng theo ảnh bạn cung cấp',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Chạm vào các pin số 1-16, A/B hoặc các cổng để đổi điểm đến.',
                  ),
                  const SizedBox(height: 12),
                  CampusMapPreview(
                    selectedPlace: _selectedPlace,
                    onPlaceSelected: _selectPlace,
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
