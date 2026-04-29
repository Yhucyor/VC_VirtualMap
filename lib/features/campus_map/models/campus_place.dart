import 'package:flutter/material.dart';

class CampusPlace {
  const CampusPlace({
    required this.id,
    required this.name,
    required this.kind,
    required this.area,
    required this.description,
    required this.landmark,
    required this.mapPosition,
    required this.latitude,
    required this.longitude,
    required this.icon,
    required this.routeSteps,
    this.mapLabel = '',
  });

  final String id;
  final String name;
  final String kind;
  final String area;
  final String description;
  final String landmark;
  final Offset mapPosition;
  final double latitude;
  final double longitude;
  final IconData icon;
  final List<String> routeSteps;
  final String mapLabel;

  String get searchText {
    return '$name $kind $area $description $landmark'.toLowerCase();
  }
}
