import 'package:flutter/material.dart';
import '../../services/voice_service.dart';
import '../../services/auth_service.dart';

class VoiceHomeScreen extends StatefulWidget {
  const VoiceHomeScreen({super.key});

  @override
  State<VoiceHomeScreen> createState() => _VoiceHomeScreenState();
}

class _VoiceHomeScreenState extends State<VoiceHomeScreen> {
  final VoiceService _voiceService = VoiceService();
  final AuthService _authService = AuthService();
  String _status = "Initializing...";
  String _lastRecognized = "";

  @override
  void initState() {
    super.initState();
    _initVoice();
  }

  void _initVoice() async {
    await _voiceService.init(
      onStatusChange: (status) {
        if (mounted) {
          setState(() => _status =
              status == 'listening' ? "Listening..." : "Processing...");
        }
      },
      onResult: (text) {
        if (mounted) {
          setState(() => _lastRecognized = text);
        }
      },
    );

    // Greet user
    String name = _authService.currentUser?.name ?? "User";
    await _voiceService.speak("Good day $name. I am online.");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("VisionMate Core"),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _authService.logout();
              if (mounted) Navigator.popAndPushNamed(context, '/login');
            },
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                _voiceService.startListening();
              },
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: _status == "Listening..."
                      ? Colors.blueAccent
                      : Colors.grey[800],
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (_status == "Listening..."
                              ? Colors.blueAccent
                              : Colors.grey)
                          .withOpacity(0.5),
                      blurRadius: 20,
                      spreadRadius: 5,
                    )
                  ],
                ),
                child: const Icon(Icons.mic, size: 80, color: Colors.white),
              ),
            ),
            const SizedBox(height: 40),
            Text(
              _status,
              style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0.0),
              child: Text(
                _lastRecognized,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white54, fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
