import 'package:flutter/material.dart';
import '../models/campus_place.dart';

// Sample data for Đại Học Tôn Đức Thắng (TDTU) campus
const tdtuCampusPlaces = <CampusPlace>[
  CampusPlace(
    id: 'tdtu_gate_main',
    name: 'Cổng chính TDTU',
    kind: 'Cổng vào/ra',
    area: 'Đường Trường Đại học',
    description: 'Cổng chính của Đại học Tôn Đức Thắng.',
    landmark: 'Gần khu hành chính chính.',
    mapPosition: Offset(0.5, 0.95),
    latitude: 10.80000,
    longitude: 106.70000,
    icon: Icons.flag,
    mapLabel: 'C',
    routeSteps: [
      'Đến cổng chính qua đường Trường Đại học.',
      'Vào khu chính và di chuyển tới khu học tập.',
    ],
  ),
  CampusPlace(
    id: 'tdtu_library',
    name: 'Thư viện TDTU',
    kind: 'Thư viện',
    area: 'Khu A',
    description: 'Thư viện lớn của TDTU.',
    landmark: 'Gần khu A và khu C.',
    mapPosition: Offset(0.55, 0.6),
    latitude: 10.80120,
    longitude: 106.70230,
    icon: Icons.local_library,
    mapLabel: 'L',
    routeSteps: [
      'Từ cổng chính di chuyển vào khu A.',
      'Thư viện nằm ở trung tâm khu A.',
    ],
  ),
];
