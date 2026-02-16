import 'package:flutter/material.dart';
import '../services/voice_service.dart';
import 'package:flutter/services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final VoiceService _voiceService = VoiceService();
  String _statusText = "Listening for 'Hey Jarvis'...";

  @override
  void initState() {
    super.initState();
    _voiceService.speak(
      "You are now on the home screen. Double tap to activate voice commands.",
    );
  }

  void _activateVoiceCommand() async {
    HapticFeedback.mediumImpact();
    setState(() {
      _statusText = "Listening...";
    });

    // Simulate listening logic
    // In a real app, this would use the continuous listening from voice_service
    await _voiceService.listen((result) {
      if (result.isNotEmpty) {
        setState(() {
          _statusText = "Heard: $result";
        });
        _processCommand(result);
      }
    });
  }

  void _processCommand(String command) {
    command = command.toLowerCase();
    if (command.contains("time")) {
      final time = TimeOfDay.now().format(context);
      _voiceService.speak("The time is $time");
    } else if (command.contains("obstacle") || command.contains("camera")) {
      _voiceService.speak("Opening obstacle detection.");
      // Navigate to generic camera screen (to be implemented)
      // Navigator.pushNamed(context, '/camera');
    } else {
      _voiceService.speak(
        "I heard $command, but I don't know how to do that yet.",
      );
    }

    setState(() {
      _statusText = "Tap to speak";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("VisionMate Home")),
      body: GestureDetector(
        onDoubleTap: _activateVoiceCommand,
        child: Container(
          color: Colors.transparent, // Capture taps everywhere
          width: double.infinity,
          height: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.mic, size: 80, color: Colors.redAccent),
              const SizedBox(height: 20),
              Text(
                _statusText,
                style: const TextStyle(fontSize: 24),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              Wrap(
                spacing: 20,
                runSpacing: 20,
                alignment: WrapAlignment.center,
                children: [
                  _buildFeatureButton(
                    Icons.visibility,
                    "RefDetect",
                    () => Navigator.pushNamed(context, '/camera'),
                  ),
                  _buildFeatureButton(
                    Icons.navigation,
                    "Nav",
                    () => Navigator.pushNamed(context, '/navigation'),
                  ),
                  _buildFeatureButton(Icons.music_note, "Media", () {}),
                  _buildFeatureButton(Icons.face, "Faces", () {}),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureButton(
    IconData icon,
    String label,
    VoidCallback onPressed,
  ) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(24),
      ),
      onPressed: onPressed,
      child: Column(
        children: [
          Icon(icon, size: 30),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
