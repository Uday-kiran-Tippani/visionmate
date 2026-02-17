import 'package:flutter/material.dart';
import 'package:visionmate/services/auth_service.dart';
import '../services/voice_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final VoiceService _voiceService = VoiceService();
  final AuthService _authService = AuthService();
  String _statusText = "Listening for 'Jarvis'...";
  String _userName = "User";

  @override
  void initState() {
    super.initState();
    _loadUser();
    _startListening();
  }

  void _loadUser() {
    setState(() {
      _userName = _authService.currentUser?.name ?? "User";
    });
    _greetUser();
  }

  void _greetUser() async {
    int hour = DateTime.now().hour;
    String greeting = "Good morning";
    if (hour > 12) greeting = "Good afternoon";
    if (hour > 17) greeting = "Good evening";

    await _voiceService.speak("$greeting $_userName. I am online.");
  }

  void _startListening() {
    _voiceService.listenAndProcess();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("VisionMate"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _authService.logout();
              if (mounted) Navigator.pushReplacementNamed(context, '/login');
            },
          )
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.mic, size: 80, color: Colors.blueAccent),
          const SizedBox(height: 20),
          Text(
            _statusText,
            style: const TextStyle(fontSize: 18, color: Colors.white70),
          ),
          const SizedBox(height: 40),
          _buildGridButtons(),
        ],
      ),
    );
  }

  Widget _buildGridButtons() {
    return Expanded(
      child: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        children: [
          _buildFeatureCard(Icons.camera_alt, "Vision",
              () => Navigator.pushNamed(context, '/camera')),
          _buildFeatureCard(Icons.navigation, "Navigation",
              () => Navigator.pushNamed(context, '/navigation')),
          _buildFeatureCard(Icons.phone, "Call",
              () => _voiceService.speak("Say Call followed by name")),
          _buildFeatureCard(Icons.mic, "Voice Command",
              () => _voiceService.listenAndProcess()),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(IconData icon, String label, VoidCallback onTap) {
    return Card(
      color: Colors.grey[900],
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: Colors.tealAccent),
            const SizedBox(height: 10),
            Text(label,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
