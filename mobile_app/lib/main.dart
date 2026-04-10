import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/registration_screen.dart';
import 'screens/voice_home_screen.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _requestPermissions();

  final AuthService authService = AuthService();
  // Check shared prefs for session
  final bool isLoggedIn = await authService.checkSession();

  runApp(VisionMateApp(isLoggedIn: isLoggedIn));
}

Future<void> _requestPermissions() async {
  await [
    Permission.microphone,
    Permission.location,
    Permission.contacts,
    Permission.phone,
    Permission.sms,
    // Add ignore battery optimizations if possible manually
  ].request();
}

class VisionMateApp extends StatelessWidget {
  final bool isLoggedIn;

  const VisionMateApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VisionMate',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        colorScheme: const ColorScheme.dark(
          primary: Colors.blueAccent,
          secondary: Colors.tealAccent,
        ),
      ),
      // If logged in, go to VoiceHomeScreen, else Login
      // Registration is reachable from Login
      home: isLoggedIn ? const VoiceHomeScreen() : const LoginScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegistrationScreen(),
        '/home': (context) => const VoiceHomeScreen(),
      },
    );
  }
}
