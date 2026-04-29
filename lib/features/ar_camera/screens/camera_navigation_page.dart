import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../campus_map/models/campus_place.dart';
import '../../location/services/location_service.dart';
import '../widgets/ar_camera_overlay.dart';

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
  String _cameraMessage = 'Đang mở camera...';
  String _gpsMessage = 'Đang chuẩn bị GPS realtime...';
  bool _cameraReady = false;
  bool _gpsReady = false;

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
    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      controller.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    setState(() {
      _cameraReady = false;
      _cameraMessage = 'Đang mở camera...';
    });

    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() {
          _cameraMessage = 'Không tìm thấy camera trên thiết bị.';
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
      );
      await controller.initialize();

      if (!mounted) {
        await controller.dispose();
        return;
      }

      await _cameraController?.dispose();
      setState(() {
        _cameraController = controller;
        _cameraReady = true;
        _cameraMessage = 'Camera realtime đang chạy';
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _cameraReady = false;
        _cameraMessage = 'Không mở được camera: $error';
      });
    }
  }

  Future<void> _startGpsTracking() async {
    final error = await LocationService.ensureLocationReady();
    if (error != null) {
      if (!mounted) {
        return;
      }
      setState(() {
        _gpsReady = false;
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
        _gpsReady = true;
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
            _gpsReady = true;
            _gpsMessage = 'GPS realtime đang chạy';
          });
        },
        onError: (Object error) {
          if (!mounted) {
            return;
          }
          setState(() {
            _gpsReady = false;
            _gpsMessage = 'Lỗi GPS: $error';
          });
        },
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _gpsReady = false;
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
          if (_cameraReady && controller != null)
            Center(child: CameraPreview(controller))
          else
            _CameraFallback(message: _cameraMessage),
          ArCameraOverlay(
            destination: widget.destination,
            position: _position,
            cameraReady: _cameraReady,
            gpsReady: _gpsReady,
            cameraMessage: _cameraMessage,
            gpsMessage: _gpsMessage,
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: IconButton.filledTonal(
                  tooltip: 'Quay lại',
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CameraFallback extends StatelessWidget {
  const _CameraFallback({required this.message});

  final String message;

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
              const CircularProgressIndicator(color: Colors.white),
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
