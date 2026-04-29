import 'dart:math' as math;

import 'package:geolocator/geolocator.dart';

import '../../campus_map/models/campus_place.dart';

class LocationService {
  const LocationService._();

  static Future<String?> ensureLocationReady() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return 'GPS đang tắt. Hãy bật Vị trí trên điện thoại.';
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      return 'Bạn chưa cấp quyền vị trí.';
    }

    if (permission == LocationPermission.deniedForever) {
      return 'Quyền vị trí bị từ chối vĩnh viễn. Mở Settings để cấp lại.';
    }

    return null;
  }

  static Future<Position> currentPosition() {
    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
  }

  static Stream<Position> positionStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 1,
      ),
    );
  }

  static double distanceToPlace(Position position, CampusPlace place) {
    return Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      place.latitude,
      place.longitude,
    );
  }

  static double bearingToPlace(Position position, CampusPlace place) {
    return Geolocator.bearingBetween(
      position.latitude,
      position.longitude,
      place.latitude,
      place.longitude,
    );
  }

  static String formatDistance(double meters) {
    if (meters >= 1000) {
      return '${(meters / 1000).toStringAsFixed(2)} km';
    }
    return '${meters.toStringAsFixed(0)} m';
  }

  static String formatBearing(double bearing) {
    final normalized = (bearing + 360) % 360;
    final directions = [
      'Bắc',
      'Đông Bắc',
      'Đông',
      'Đông Nam',
      'Nam',
      'Tây Nam',
      'Tây',
      'Tây Bắc',
    ];
    final index = ((normalized + 22.5) / 45).floor() % directions.length;
    return '${directions[index]} (${normalized.toStringAsFixed(0)}°)';
  }

  static double bearingToRadians(double bearing) {
    return ((bearing + 360) % 360) * math.pi / 180;
  }
}
