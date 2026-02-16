import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../services/vision_service.dart';
import '../services/voice_service.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  final VisionService _visionService = VisionService();
  final VoiceService _voiceService = VoiceService();
  bool _isDetecting = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _visionService.initialize();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    _controller = CameraController(cameras[0], ResolutionPreset.medium);
    await _controller!.initialize();

    if (mounted) {
      setState(() {});
      _startDetection();
    }
  }

  void _startDetection() {
    if (_controller == null || !_controller!.value.isInitialized) return;

    _controller!.startImageStream((image) async {
      if (_isDetecting) return;
      _isDetecting = true;

      try {
        // Run detection (mock implementation in service for now)
        // final results = await _visionService.runDetection(image);
        // if (results.isNotEmpty) {
        //   _voiceService.speak("Obstacle ahead");
        // }
      } catch (e) {
        print(e);
      } finally {
        _isDetecting = false;
      }
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    _visionService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Obstacle Detection")),
      body: Stack(
        children: [
          CameraPreview(_controller!),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Text(
              "Scanning environment...",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                backgroundColor: Colors.black.withOpacity(0.5),
                fontSize: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
