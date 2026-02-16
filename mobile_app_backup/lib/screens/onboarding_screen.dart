import 'package:flutter/material.dart';
import '../services/voice_service.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final VoiceService _voiceService = VoiceService();

  @override
  void initState() {
    super.initState();
    _speakWelcome();
  }

  void _speakWelcome() async {
    await Future.delayed(const Duration(seconds: 1));
    await _voiceService.speak(
      "Welcome to VisionMate. I am your assistant. Please tap the screen to maximize setup.",
    );
  }

  void _completeOnboarding() {
    _voiceService.speak("Setup complete. Taking you to the home screen.");
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Welcome")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.accessibility_new,
              size: 100,
              color: Colors.blueAccent,
            ),
            const SizedBox(height: 20),
            const Text(
              "Welcome to VisionMate",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ElevatedButton(
                onPressed: _completeOnboarding,
                child: const Text("Start Setup"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
