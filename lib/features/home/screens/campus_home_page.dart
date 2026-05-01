import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../../shared/widgets/app_panel.dart';
import '../../../widgets/app_drawer.dart';
import '../../ar_camera/screens/camera_navigation_page.dart';
import '../../campus_map/data/campus_catalog.dart';
import '../../campus_map/models/campus_place.dart';
import '../../campus_map/widgets/campus_map_preview.dart';
import '../../destination/widgets/destination_detail_card.dart';
import '../../destination/widgets/destination_picker.dart';
import '../../location/services/location_service.dart';
import '../../location/widgets/location_status_card.dart';

class CampusHomePage extends StatefulWidget {
  const CampusHomePage({
    super.key,
    required this.themeNotifier,
    required this.selectedCampusNotifier,
  });

  final ValueNotifier<bool> themeNotifier;
  final ValueNotifier<CampusProfile> selectedCampusNotifier;

  @override
  State<CampusHomePage> createState() => _CampusHomePageState();
}

class _CampusHomePageState extends State<CampusHomePage> {
  final _destinationController = TextEditingController();
  final _campusSearchController = TextEditingController();
  Position? _position;
  StreamSubscription<Position>? _positionSubscription;
  late CampusProfile _selectedCampus;
  late CampusPlace _selectedPlace;
  String _gpsMessage = 'Chưa bật GPS realtime';
  bool _isTracking = false;
  bool _isLoadingGps = false;

  @override
  void initState() {
    super.initState();
    _selectedCampus = widget.selectedCampusNotifier.value;
    _selectedPlace = _selectedCampus.places.first;
    _destinationController.text = _selectedPlace.name;
    _campusSearchController.text = _selectedCampus.fullName;
    widget.selectedCampusNotifier.addListener(_syncSelectedCampus);
  }

  @override
  void dispose() {
    widget.selectedCampusNotifier.removeListener(_syncSelectedCampus);
    _destinationController.dispose();
    _campusSearchController.dispose();
    _positionSubscription?.cancel();
    super.dispose();
  }

  void _syncSelectedCampus() {
    final campus = widget.selectedCampusNotifier.value;
    if (campus.id == _selectedCampus.id) return;
    setState(() {
      _selectedCampus = campus;
      _selectedPlace = campus.places.first;
      _destinationController.text = _selectedPlace.name;
      _campusSearchController.text = campus.fullName;
    });
  }

  List<CampusProfile> get _campusMatches {
    final query = _campusSearchController.text.trim().toLowerCase();
    if (query.isEmpty) return campusCatalog;
    return campusCatalog
        .where((campus) => campus.searchText.contains(query))
        .toList();
  }

  List<CampusPlace> get _suggestions {
    final query = _destinationController.text.trim().toLowerCase();
    if (query.isEmpty) return _selectedCampus.places.take(12).toList();
    return _selectedCampus.places
        .where((place) => place.searchText.contains(query))
        .take(12)
        .toList();
  }

  void _selectCampus(CampusProfile campus) {
    setState(() {
      _selectedCampus = campus;
      _selectedPlace = campus.places.first;
      _destinationController.text = _selectedPlace.name;
      _campusSearchController.text = campus.fullName;
    });
    widget.selectedCampusNotifier.value = campus;
  }

  void _selectFirstCampusMatch() {
    final matches = _campusMatches;
    if (matches.isNotEmpty) _selectCampus(matches.first);
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
      if (!mounted) return;
      setState(() {
        _position = currentPosition;
        _isTracking = true;
        _isLoadingGps = false;
        _gpsMessage = 'GPS realtime đang chạy';
      });
      await _positionSubscription?.cancel();
      _positionSubscription = LocationService.positionStream().listen(
        (position) {
          if (!mounted) return;
          setState(() {
            _position = position;
            _gpsMessage = 'GPS realtime đang chạy';
          });
        },
        onError: (Object error) {
          if (!mounted) return;
          setState(() {
            _isTracking = false;
            _gpsMessage = 'Lỗi GPS: $error';
          });
        },
      );
    } catch (error) {
      if (!mounted) return;
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
        title: const Text('camapus'),
        actions: [
          IconButton(
            tooltip: 'Cài đặt',
            onPressed: () => Navigator.of(context).pushNamed('/settings'),
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      drawer: AppDrawer(themeNotifier: widget.themeNotifier),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _HomeIntroPanel(campus: _selectedCampus),
            const SizedBox(height: 14),
            _CampusSearchPanel(
              controller: _campusSearchController,
              selectedCampus: _selectedCampus,
              matches: _campusMatches,
              onChanged: (_) => setState(() {}),
              onSubmitted: (_) => _selectFirstCampusMatch(),
              onCampusSelected: _selectCampus,
            ),
            const SizedBox(height: 14),
            _CampusVisualPanel(campus: _selectedCampus),
            const SizedBox(height: 14),
            _CampusMapPanel(
              campus: _selectedCampus,
              selectedPlace: _selectedPlace,
              onPlaceSelected: _selectPlace,
            ),
            const SizedBox(height: 14),
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
          ],
        ),
      ),
    );
  }
}

class _CampusSearchPanel extends StatelessWidget {
  const _CampusSearchPanel({
    required this.controller,
    required this.selectedCampus,
    required this.matches,
    required this.onChanged,
    required this.onSubmitted,
    required this.onCampusSelected,
  });

  final TextEditingController controller;
  final CampusProfile selectedCampus;
  final List<CampusProfile> matches;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final ValueChanged<CampusProfile> onCampusSelected;

  @override
  Widget build(BuildContext context) {
    return AppPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Chọn trường đại học',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          const Text(
            'Chọn trường bạn đang học hoặc trường bạn muốn đến. App sẽ hiển thị ảnh, tên trường và bản đồ các khu/phòng/tòa tương ứng.',
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            key: ValueKey(selectedCampus.id),
            initialValue: selectedCampus.id,
            decoration: const InputDecoration(
              labelText: 'Trường đang chọn',
              prefixIcon: Icon(Icons.school_outlined),
              border: OutlineInputBorder(),
            ),
            items: [
              for (final campus in campusCatalog)
                DropdownMenuItem<String>(
                  value: campus.id,
                  child: Text('${campus.shortName} - ${campus.fullName}'),
                ),
            ],
            onChanged: (id) {
              if (id == null) return;
              onCampusSelected(
                campusCatalog.firstWhere((campus) => campus.id == id),
              );
            },
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Tìm nhanh tên trường',
              hintText: 'Ví dụ: Thủ Dầu Một, Bách Khoa, HUTECH',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            textInputAction: TextInputAction.search,
            onChanged: onChanged,
            onSubmitted: onSubmitted,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final campus in matches)
                ChoiceChip(
                  selected: campus.id == selectedCampus.id,
                  avatar: const Icon(Icons.location_city, size: 18),
                  label: Text(campus.shortName),
                  onSelected: (_) => onCampusSelected(campus),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CampusVisualPanel extends StatelessWidget {
  const _CampusVisualPanel({required this.campus});

  final CampusProfile campus;

  @override
  Widget build(BuildContext context) {
    return AppPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            campus.fullName,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text(campus.description),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: CustomPaint(
                painter: _CampusPhotoPainter(campus: campus),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    color: Colors.black.withValues(alpha: 0.40),
                    child: Text(
                      campus.photoCaption,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CampusMapPanel extends StatelessWidget {
  const _CampusMapPanel({
    required this.campus,
    required this.selectedPlace,
    required this.onPlaceSelected,
  });

  final CampusProfile campus;
  final CampusPlace selectedPlace;
  final ValueChanged<CampusPlace> onPlaceSelected;

  @override
  Widget build(BuildContext context) {
    return AppPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            campus.mapCaption,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(
            'Các pin trên bản đồ là khu, phòng hoặc tòa của ${campus.shortName}. Chạm vào pin hoặc chọn bên dưới để đổi điểm đến.',
          ),
          const SizedBox(height: 12),
          CampusMapPreview(
            places: campus.places,
            campusName: campus.shortName,
            selectedPlace: selectedPlace,
            onPlaceSelected: onPlaceSelected,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final place in campus.places)
                ChoiceChip(
                  selected: place.id == selectedPlace.id,
                  avatar: Icon(place.icon, size: 18),
                  label: Text(place.name),
                  onSelected: (_) => onPlaceSelected(place),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CampusPhotoPainter extends CustomPainter {
  const _CampusPhotoPainter({required this.campus});

  final CampusProfile campus;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height * 0.58),
      Paint()..color = Color.lerp(campus.color, Colors.white, 0.62)!,
    );
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.58, size.width, size.height * 0.42),
      Paint()..color = const Color(0xFFD8E7D0),
    );

    final buildingPaint = Paint()
      ..color = Color.lerp(campus.color, const Color(0xFF0F172A), 0.18)!;
    final accentPaint = Paint()
      ..color = Color.lerp(campus.color, Colors.white, 0.34)!;
    final windowPaint = Paint()..color = Colors.white.withValues(alpha: 0.72);

    final building = Rect.fromLTWH(
      size.width * 0.18,
      size.height * 0.18,
      size.width * 0.64,
      size.height * 0.50,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(building, const Radius.circular(10)),
      buildingPaint,
    );
    final tower = Rect.fromLTWH(
      size.width * 0.42,
      size.height * 0.08,
      size.width * 0.16,
      size.height * 0.60,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(tower, const Radius.circular(10)),
      accentPaint,
    );

    for (var row = 0; row < 5; row++) {
      for (var col = 0; col < 7; col++) {
        final x = building.left + 18 + col * (building.width - 36) / 6;
        final y = building.top + 22 + row * (building.height - 48) / 4;
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(x, y, 16, 12),
            const Radius.circular(2),
          ),
          windowPaint,
        );
      }
    }

    final path = Path()
      ..moveTo(size.width * 0.43, size.height)
      ..lineTo(size.width * 0.50, size.height * 0.68)
      ..lineTo(size.width * 0.57, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = const Color(0xFFE7D1B0));

    final textPainter = TextPainter(
      text: TextSpan(
        text: campus.shortName,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: math.min(34, size.width * 0.12),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: size.width * 0.70);
    textPainter.paint(
      canvas,
      Offset((size.width - textPainter.width) / 2, size.height * 0.22),
    );
  }

  @override
  bool shouldRepaint(covariant _CampusPhotoPainter oldDelegate) {
    return oldDelegate.campus.id != campus.id;
  }
}

class _HomeIntroPanel extends StatelessWidget {
  const _HomeIntroPanel({required this.campus});

  final CampusProfile campus;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.explore,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bản đồ trường học',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Đang chọn ${campus.shortName}. Màn tìm phòng học sẽ tự dùng đúng trường này.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
