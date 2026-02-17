import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
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
  String _debugLabel = "Initializing...";

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _visionService.initialize();
  }

  void _initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    _controller = CameraController(
      firstCamera,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    await _controller!.initialize();
    if (!mounted) return;

    setState(() {});

    // Start streaming
    _controller!.startImageStream((CameraImage image) {
      if (!_isDetecting) {
        _isDetecting = true;
        _runDetection(image);
      }
    });
  }

  void _runDetection(CameraImage image) async {
    // 1. Run Object Detection
    List<String> detections = await _visionService.runObjectDetection(image);

    // 2. Run Face Recognition (if person detected)
    String? faceName;
    if (detections.contains('person')) {
      faceName = await _visionService.recognizeFace(image);
    }

    // 3. Update UI & Speak
    if (mounted) {
      setState(() {
        _debugLabel = detections.join(", ");
        if (faceName != null) _debugLabel += " ($faceName)";
      });
    }

    // Smart speaking logic (debounce to avoid spam)
    if (detections.isNotEmpty) {
      // logic to avoid repeating same object every frame would go here
      if (faceName != null) {
        await _voiceService.speak("$faceName is in front of you.");
      } else {
        // Simple announcement for now
        await _voiceService.speak("Detected ${detections.first}");
      }
    }

    _isDetecting = false;
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
            left: 20,
            child: Container(
              color: Colors.black54,
              padding: const EdgeInsets.all(8),
              child: Text(
                _debugLabel,
                style: const TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
          )
        ],
      ),
    );
  }
}
