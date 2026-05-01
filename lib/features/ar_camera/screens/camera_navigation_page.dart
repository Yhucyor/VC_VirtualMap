import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../campus_map/models/campus_place.dart';
import '../../location/services/location_service.dart';
import '../widgets/ar_camera_overlay.dart';
import '../widgets/location_map_widget.dart';

class CameraNavigationPage extends StatefulWidget {
  const CameraNavigationPage({super.key, required this.destination});

  final CampusPlace destination;

  @override
  State<CameraNavigationPage> createState() => _CameraNavigationPageState();
}

class _CameraNavigationPageState extends State<CameraNavigationPage>
    with WidgetsBindingObserver {
  CameraController? _cameraController;
  StreamSubscription<Position>? _positionSubscription;
  Position? _position;
  bool _cameraReady = false;
  bool _gpsReady = false;
  bool _mapOnly = false;
  bool _isStartingCamera = false;
  bool _isStartingGps = false;
  String _cameraMessage = 'Đang mở camera...';
  String _gpsMessage = 'Đang chuẩn bị GPS realtime...';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
    _startGpsTracking();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _positionSubscription?.cancel();
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _cameraController;
    if (controller == null) return;

    if (state == AppLifecycleState.inactive) {
      controller.dispose();
      _cameraController = null;
      _cameraReady = false;
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    if (_isStartingCamera) return;
    setState(() {
      _isStartingCamera = true;
      _cameraReady = false;
      _cameraMessage = 'Đang mở camera...';
    });

    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (!mounted) return;
        setState(() {
          _cameraMessage = 'Không tìm thấy camera trên thiết bị.';
          _isStartingCamera = false;
        });
        return;
      }

      final backCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      final controller = CameraController(
        backCamera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );
      await controller.initialize();
      await controller.setFlashMode(FlashMode.off);

      if (!mounted) {
        await controller.dispose();
        return;
      }

      final previous = _cameraController;
      _cameraController = controller;
      await previous?.dispose();

      setState(() {
        _cameraReady = true;
        _isStartingCamera = false;
        _cameraMessage = 'Camera realtime đang chạy';
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _cameraReady = false;
        _isStartingCamera = false;
        _cameraMessage =
            'Không mở được camera. Hãy cấp quyền camera rồi thử lại.';
      });
    }
  }

  Future<void> _startGpsTracking() async {
    if (_isStartingGps) return;
    setState(() {
      _isStartingGps = true;
      _gpsMessage = 'Đang kiểm tra quyền GPS...';
    });

    final error = await LocationService.ensureLocationReady();
    if (error != null) {
      if (!mounted) return;
      setState(() {
        _gpsReady = false;
        _isStartingGps = false;
        _gpsMessage = error;
      });
      return;
    }

    try {
      final currentPosition = await LocationService.currentPosition();
      if (!mounted) return;
      setState(() {
        _position = currentPosition;
        _gpsReady = true;
        _isStartingGps = false;
        _gpsMessage = 'GPS realtime đang chạy';
      });

      await _positionSubscription?.cancel();
      _positionSubscription = LocationService.positionStream().listen(
        (position) {
          if (!mounted) return;
          setState(() {
            _position = position;
            _gpsReady = true;
            _gpsMessage = 'GPS realtime đang chạy';
          });
        },
        onError: (Object error) {
          if (!mounted) return;
          setState(() {
            _gpsReady = false;
            _gpsMessage = 'Lỗi GPS: $error';
          });
        },
      );
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _gpsReady = false;
        _isStartingGps = false;
        _gpsMessage = 'Không lấy được GPS: $error';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = _cameraController;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (_mapOnly)
            LocationMapWidget(
              position: _position,
              destination: widget.destination,
            )
          else if (_cameraReady && controller != null)
            _FullScreenCameraPreview(controller: controller)
          else
            _CameraFallback(
              message: _cameraMessage,
              onRetry: _initializeCamera,
            ),
          if (!_mapOnly)
            ArCameraOverlay(
              destination: widget.destination,
              position: _position,
              cameraReady: _cameraReady,
              gpsReady: _gpsReady,
              cameraMessage: _cameraMessage,
              gpsMessage: _gpsMessage,
            ),
          _TopControls(
            mapOnly: _mapOnly,
            onBack: () => Navigator.of(context).pop(),
            onToggleMap: () => setState(() => _mapOnly = !_mapOnly),
            onRetryCamera: _initializeCamera,
            onRetryGps: _startGpsTracking,
          ),
          if (!_mapOnly)
            Positioned(
              left: 14,
              right: 14,
              bottom: 14,
              child: SizedBox(
                height: 156,
                child: LocationMapWidget(
                  position: _position,
                  destination: widget.destination,
                  compact: true,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _FullScreenCameraPreview extends StatelessWidget {
  const _FullScreenCameraPreview({required this.controller});

  final CameraController controller;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final previewSize = controller.value.previewSize;
    if (previewSize == null) {
      return CameraPreview(controller);
    }

    final previewRatio = previewSize.height / previewSize.width;
    final screenRatio = size.width / size.height;

    return Transform.scale(
      scale: previewRatio / screenRatio,
      child: Center(child: CameraPreview(controller)),
    );
  }
}

class _TopControls extends StatelessWidget {
  const _TopControls({
    required this.mapOnly,
    required this.onBack,
    required this.onToggleMap,
    required this.onRetryCamera,
    required this.onRetryGps,
  });

  final bool mapOnly;
  final VoidCallback onBack;
  final VoidCallback onToggleMap;
  final VoidCallback onRetryCamera;
  final VoidCallback onRetryGps;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.topLeft,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              IconButton.filledTonal(
                tooltip: 'Quay lại',
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back),
              ),
              IconButton.filledTonal(
                tooltip: mapOnly ? 'Mở AR camera' : 'Mở bản đồ',
                onPressed: onToggleMap,
                icon: Icon(mapOnly ? Icons.view_in_ar : Icons.map),
              ),
              IconButton.filledTonal(
                tooltip: 'Thử lại camera',
                onPressed: onRetryCamera,
                icon: const Icon(Icons.camera_alt),
              ),
              IconButton.filledTonal(
                tooltip: 'Thử lại GPS',
                onPressed: onRetryGps,
                icon: const Icon(Icons.gps_fixed),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CameraFallback extends StatelessWidget {
  const _CameraFallback({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(color: Color(0xFF101010)),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.camera_alt, color: Colors.white70, size: 54),
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Thử lại camera'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
