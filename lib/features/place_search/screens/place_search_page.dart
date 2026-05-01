import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../ar_camera/screens/camera_navigation_page.dart';
import '../../campus_map/data/campus_catalog.dart';
import '../../campus_map/models/campus_place.dart';

class PlaceSearchPage extends StatefulWidget {
  const PlaceSearchPage({super.key, required this.selectedCampusNotifier});

  final ValueNotifier<CampusProfile> selectedCampusNotifier;

  @override
  State<PlaceSearchPage> createState() => _PlaceSearchPageState();
}

class _PlaceSearchPageState extends State<PlaceSearchPage> {
  final _searchController = TextEditingController();
  CampusProfile _campus = campusCatalog.first;
  late CampusPlace _selectedPlace = _campus.places.first;
  bool _isGuiding = false;

  @override
  void initState() {
    super.initState();
    _campus = widget.selectedCampusNotifier.value;
    _selectedPlace = _campus.places.first;
    _searchController.text = _selectedPlace.name;
    widget.selectedCampusNotifier.addListener(_syncCampus);
  }

  @override
  void dispose() {
    widget.selectedCampusNotifier.removeListener(_syncCampus);
    _searchController.dispose();
    super.dispose();
  }

  void _syncCampus() {
    final campus = widget.selectedCampusNotifier.value;
    if (campus.id == _campus.id) return;
    setState(() {
      _campus = campus;
      _selectedPlace = campus.places.first;
      _searchController.text = _selectedPlace.name;
      _isGuiding = false;
    });
  }

  List<CampusPlace> get _matches {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      return _campus.places.take(6).toList();
    }
    return _campus.places
        .where((place) => place.searchText.contains(query))
        .take(6)
        .toList();
  }

  void _selectCampus(CampusProfile campus) {
    setState(() {
      _campus = campus;
      _selectedPlace = campus.places.first;
      _searchController.text = _selectedPlace.name;
      _isGuiding = false;
    });
    widget.selectedCampusNotifier.value = campus;
  }

  void _openArNavigation([CampusPlace? place]) {
    final destination = place ?? _selectedPlace;
    setState(() {
      _selectedPlace = destination;
      _searchController.text = destination.name;
      _isGuiding = false;
    });
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CameraNavigationPage(destination: destination),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 240),
          child: _isGuiding
              ? _GuidanceView(
                  key: const ValueKey('guidance'),
                  campus: _campus,
                  place: _selectedPlace,
                  onBackToSearch: () => setState(() => _isGuiding = false),
                )
              : _SearchMapView(
                  key: const ValueKey('search'),
                  campus: _campus,
                  selectedPlace: _selectedPlace,
                  matches: _matches,
                  searchController: _searchController,
                  onQueryChanged: (_) => setState(() {}),
                  onCampusSelected: _selectCampus,
                  onPlaceSelected: _openArNavigation,
                  onStart: _openArNavigation,
                ),
        ),
      ),
    );
  }
}

class _SearchMapView extends StatelessWidget {
  const _SearchMapView({
    super.key,
    required this.campus,
    required this.selectedPlace,
    required this.matches,
    required this.searchController,
    required this.onQueryChanged,
    required this.onCampusSelected,
    required this.onPlaceSelected,
    required this.onStart,
  });

  final CampusProfile campus;
  final CampusPlace selectedPlace;
  final List<CampusPlace> matches;
  final TextEditingController searchController;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<CampusProfile> onCampusSelected;
  final ValueChanged<CampusPlace> onPlaceSelected;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Stack(
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: _CampusStreetMapPainter(
              selectedPlace: selectedPlace,
              places: campus.places,
            ),
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: _TopOverlay(
            title: 'Bạn muốn đi đâu?',
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
            trailing: PopupMenuButton<CampusProfile>(
              tooltip: 'Chọn trường',
              onSelected: onCampusSelected,
              icon: const Icon(Icons.school),
              itemBuilder: (context) => campusCatalog
                  .map(
                    (item) => PopupMenuItem<CampusProfile>(
                      value: item,
                      child: Text('${item.shortName} - ${item.fullName}'),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
        Positioned(
          top: 64,
          left: 18,
          right: 18,
          child: Material(
            color: Colors.white.withValues(alpha: 0.92),
            elevation: 0,
            borderRadius: BorderRadius.circular(10),
            child: TextField(
              controller: searchController,
              onChanged: onQueryChanged,
              decoration: InputDecoration(
                hintText: 'Nhập địa điểm hoặc phòng học',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchController.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          searchController.clear();
                          onQueryChanged('');
                        },
                      ),
                border: const UnderlineInputBorder(),
              ),
            ),
          ),
        ),
        if (matches.isNotEmpty)
          Positioned(
            top: 124,
            left: 18,
            right: 18,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final place in matches)
                  ChoiceChip(
                    selected: place.id == selectedPlace.id,
                    avatar: Icon(place.icon, size: 18),
                    label: Text(place.name),
                    onSelected: (_) => onPlaceSelected(place),
                  ),
              ],
            ),
          ),
        Positioned(
          left: 20,
          right: 20,
          bottom: 26,
          child: _PlacePreviewCard(
            campus: campus,
            place: selectedPlace,
            onStart: onStart,
          ),
        ),
        Positioned(
          top: MediaQuery.of(context).size.height * 0.43,
          left:
              MediaQuery.of(context).size.width * selectedPlace.mapPosition.dx -
              24,
          child: Icon(Icons.location_pin, color: colorScheme.error, size: 48),
        ),
      ],
    );
  }
}

class _PlacePreviewCard extends StatelessWidget {
  const _PlacePreviewCard({
    required this.campus,
    required this.place,
    required this.onStart,
  });

  final CampusProfile campus;
  final CampusPlace place;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 7,
      shadowColor: Colors.black.withValues(alpha: 0.18),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        place.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            size: 16,
                            color: Colors.amber.shade700,
                          ),
                          const SizedBox(width: 4),
                          Text('${campus.shortName} • ${place.kind}'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(place.area),
                      const SizedBox(height: 4),
                      Text(
                        place.landmark,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    place.icon,
                    color: colorScheme.onPrimaryContainer,
                    size: 42,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.center,
              child: FilledButton.icon(
                onPressed: onStart,
                icon: const Icon(Icons.my_location),
                label: const Text('Start'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GuidanceView extends StatelessWidget {
  const _GuidanceView({
    super.key,
    required this.campus,
    required this.place,
    required this.onBackToSearch,
  });

  final CampusProfile campus;
  final CampusPlace place;
  final VoidCallback onBackToSearch;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: CustomPaint(painter: _ArStreetPainter())),
        Positioned.fill(child: CustomPaint(painter: _ArRoutePainter())),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: _TopOverlay(
            title: place.name,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: onBackToSearch,
            ),
            trailing: IconButton(
              icon: const Icon(Icons.more_horiz),
              onPressed: () {},
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: _GuidanceBottomSheet(campus: campus, place: place),
        ),
      ],
    );
  }
}

class _GuidanceBottomSheet extends StatelessWidget {
  const _GuidanceBottomSheet({required this.campus, required this.place});

  final CampusProfile campus;
  final CampusPlace place;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 160,
            child: CustomPaint(
              painter: _MiniRouteMapPainter(place: place),
              child: const SizedBox.expand(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
            child: Row(
              children: [
                const Icon(Icons.location_on, color: Colors.black87),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '0min • 40 yd • ${campus.shortName}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Chip(
                  avatar: Icon(place.icon, size: 18),
                  label: Text(
                    place.mapLabel.isEmpty ? place.kind : place.mapLabel,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TopOverlay extends StatelessWidget {
  const _TopOverlay({
    required this.title,
    required this.leading,
    required this.trailing,
  });

  final String title;
  final Widget leading;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      color: Colors.black.withValues(alpha: 0.34),
      child: Row(
        children: [
          leading,
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}

class _CampusStreetMapPainter extends CustomPainter {
  const _CampusStreetMapPainter({
    required this.selectedPlace,
    required this.places,
  });

  final CampusPlace selectedPlace;
  final List<CampusPlace> places;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFF7F2EF),
    );

    final blockPaint = Paint()..color = const Color(0xFFE2E1DF);
    final greenPaint = Paint()..color = const Color(0xFFDCEFD7);
    final roadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 24
      ..strokeCap = StrokeCap.round;
    final minorRoadPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.82)
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;

    for (final rect in [
      Rect.fromLTWH(size.width * 0.08, size.height * 0.20, 105, 92),
      Rect.fromLTWH(size.width * 0.46, size.height * 0.18, 130, 110),
      Rect.fromLTWH(size.width * 0.16, size.height * 0.48, 145, 95),
      Rect.fromLTWH(size.width * 0.58, size.height * 0.45, 150, 116),
    ]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(8)),
        blockPaint,
      );
    }

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.08, size.height * 0.66, 180, 82),
        const Radius.circular(12),
      ),
      greenPaint,
    );

    _drawRoad(canvas, size, roadPaint, [
      const Offset(0.05, 0.78),
      const Offset(0.26, 0.63),
      const Offset(0.42, 0.52),
      const Offset(0.66, 0.38),
      const Offset(0.92, 0.22),
    ]);
    _drawRoad(canvas, size, minorRoadPaint, [
      const Offset(0.10, 0.34),
      const Offset(0.34, 0.42),
      const Offset(0.58, 0.50),
      const Offset(0.92, 0.58),
    ]);
    _drawRoad(canvas, size, minorRoadPaint, [
      const Offset(0.28, 0.18),
      const Offset(0.36, 0.40),
      const Offset(0.46, 0.74),
    ]);

    final routePaint = Paint()
      ..color = const Color(0xFFC89042)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final destination = Offset(
      size.width * selectedPlace.mapPosition.dx,
      size.height * (0.24 + selectedPlace.mapPosition.dy * 0.44),
    );
    final destinationArea = Path()
      ..moveTo(destination.dx - 54, destination.dy + 26)
      ..lineTo(destination.dx + 70, destination.dy + 12)
      ..lineTo(destination.dx + 58, destination.dy + 86)
      ..lineTo(destination.dx - 50, destination.dy + 78)
      ..close();
    canvas.drawPath(
      destinationArea,
      Paint()..color = const Color(0xFFFFF2DF).withValues(alpha: 0.70),
    );
    canvas.drawPath(destinationArea, routePaint);

    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    for (final label in [
      ('Library', 0.16, 0.28),
      ('Central Hall', 0.46, 0.38),
      ('Student Service', 0.26, 0.56),
      ('Main Gate', 0.70, 0.66),
    ]) {
      textPainter.text = TextSpan(
        text: label.$1,
        style: const TextStyle(
          color: Color(0xFF817C7A),
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
      );
      textPainter.layout(maxWidth: 150);
      textPainter.paint(
        canvas,
        Offset(size.width * label.$2, size.height * label.$3),
      );
    }

    for (final place in places.take(8)) {
      final point = Offset(
        size.width * place.mapPosition.dx,
        size.height * (0.20 + place.mapPosition.dy * 0.55),
      );
      canvas.drawCircle(point, 9, Paint()..color = const Color(0xFF6F96A8));
      canvas.drawCircle(point, 4, Paint()..color = Colors.white);
    }
  }

  void _drawRoad(Canvas canvas, Size size, Paint paint, List<Offset> points) {
    final path = Path()
      ..moveTo(size.width * points.first.dx, size.height * points.first.dy);
    for (final point in points.skip(1)) {
      path.lineTo(size.width * point.dx, size.height * point.dy);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _CampusStreetMapPainter oldDelegate) {
    return oldDelegate.selectedPlace.id != selectedPlace.id ||
        oldDelegate.places != places;
  }
}

class _ArStreetPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final sky = Rect.fromLTWH(0, 0, size.width, size.height * 0.58);
    canvas.drawRect(sky, Paint()..color = const Color(0xFFE7EEF5));
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.58, size.width, size.height * 0.42),
      Paint()..color = const Color(0xFFB8B4AF),
    );

    _building(canvas, size, 0.04, 0.12, 0.28, 0.50, const Color(0xFFD08B56));
    _building(canvas, size, 0.34, 0.05, 0.30, 0.62, const Color(0xFFB78578));
    _building(canvas, size, 0.68, 0.10, 0.28, 0.54, const Color(0xFF8AA0A8));

    final road = Path()
      ..moveTo(size.width * 0.35, size.height)
      ..lineTo(size.width * 0.58, size.height * 0.58)
      ..lineTo(size.width * 0.80, size.height * 0.58)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(road, Paint()..color = const Color(0xFF4E5357));
    canvas.drawLine(
      Offset(size.width * 0.68, size.height * 0.60),
      Offset(size.width * 0.82, size.height),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.65)
        ..strokeWidth = 3,
    );
  }

  void _building(
    Canvas canvas,
    Size size,
    double x,
    double y,
    double w,
    double h,
    Color color,
  ) {
    final rect = Rect.fromLTWH(
      size.width * x,
      size.height * y,
      size.width * w,
      size.height * h,
    );
    canvas.drawRect(rect, Paint()..color = color);
    final windowPaint = Paint()..color = Colors.white.withValues(alpha: 0.38);
    for (var row = 0; row < 6; row++) {
      for (var col = 0; col < 3; col++) {
        canvas.drawRect(
          Rect.fromLTWH(
            rect.left + 14 + col * rect.width / 3,
            rect.top + 20 + row * rect.height / 7,
            rect.width * 0.16,
            rect.height * 0.07,
          ),
          windowPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ArRoutePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final routePaint = Paint()
      ..color = const Color(0xFF65DCEB).withValues(alpha: 0.86)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 30
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final route = Path()
      ..moveTo(size.width * 0.18, size.height * 0.76)
      ..quadraticBezierTo(
        size.width * 0.38,
        size.height * 0.56,
        size.width * 0.56,
        size.height * 0.54,
      )
      ..lineTo(size.width * 0.86, size.height * 0.47);
    canvas.drawPath(route, routePaint);

    final arrowPaint = Paint()..color = const Color(0xFF8BF3FF);
    for (var i = 0; i < 8; i++) {
      final x = size.width * (0.30 + i * 0.07);
      final y = size.height * (0.58 - i * 0.012);
      final arrow = Path()
        ..moveTo(x - 8, y - 8)
        ..lineTo(x + 12, y)
        ..lineTo(x - 8, y + 8)
        ..lineTo(x - 2, y)
        ..close();
      canvas.drawPath(arrow, arrowPaint);
    }

    final turn = Path()
      ..moveTo(size.width * 0.12, size.height * 0.62)
      ..lineTo(size.width * 0.28, size.height * 0.56)
      ..lineTo(size.width * 0.16, size.height * 0.51)
      ..close();
    canvas.drawPath(
      turn,
      Paint()..color = const Color(0xFF65DCEB).withValues(alpha: 0.92),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MiniRouteMapPainter extends CustomPainter {
  const _MiniRouteMapPainter({required this.place});

  final CampusPlace place;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFF4EEE8),
    );
    final roadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 18
      ..strokeCap = StrokeCap.round;
    final road = Path()
      ..moveTo(size.width * 0.12, size.height * 0.76)
      ..lineTo(size.width * 0.36, size.height * 0.58)
      ..lineTo(size.width * 0.60, size.height * 0.64)
      ..lineTo(size.width * 0.86, size.height * 0.42);
    canvas.drawPath(road, roadPaint);

    final routePaint = Paint()
      ..color = const Color(0xFF1D5CFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    final route = Path()
      ..moveTo(size.width * 0.48, size.height * 0.72)
      ..lineTo(size.width * 0.54, size.height * 0.60)
      ..lineTo(size.width * 0.65, size.height * 0.55);
    canvas.drawPath(route, routePaint);
    canvas.drawCircle(
      Offset(size.width * 0.48, size.height * 0.72),
      7,
      Paint()..color = Colors.blue,
    );

    final destination = Offset(size.width * 0.66, size.height * 0.52);
    canvas.drawCircle(destination, 12, Paint()..color = Colors.red);
    canvas.drawCircle(destination, 5, Paint()..color = Colors.white);

    final label = TextPainter(
      text: TextSpan(
        text: place.name,
        style: const TextStyle(
          color: Color(0xFF7A6F68),
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
      ellipsis: '...',
    )..layout(maxWidth: size.width * 0.38);
    label.paint(canvas, Offset(size.width * 0.56, size.height * 0.28));

    final compass = Offset(size.width * 0.08, size.height * 0.18);
    for (var i = 0; i < 10; i++) {
      final angle = i * math.pi / 5;
      canvas.drawLine(
        compass,
        compass + Offset(math.cos(angle), math.sin(angle)) * (14 + i % 2 * 7),
        Paint()
          ..color = const Color(0xFF67D7E8).withValues(alpha: 0.65)
          ..strokeWidth = 3,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MiniRouteMapPainter oldDelegate) {
    return oldDelegate.place.id != place.id;
  }
}
