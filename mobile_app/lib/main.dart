import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/registration_screen.dart';
import 'screens/home_screen.dart';
import 'screens/camera_screen.dart';
import 'screens/navigation_screen.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _requestPermissions();

  final AuthService authService = AuthService();
  final bool isLoggedIn = await authService.isLoggedIn();

  runApp(VisionMateApp(isLoggedIn: isLoggedIn));
}

Future<void> _requestPermissions() async {
  await [
    Permission.camera,
    Permission.microphone,
    Permission.location,
    Permission.speech,
    Permission.contacts,
    Permission.phone,
    Permission.sms,
  ].request();
}

class VisionMateApp extends StatelessWidget {
  final bool isLoggedIn;

  const VisionMateApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VisionMate',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        primaryColor: Colors.blueAccent,
        colorScheme: const ColorScheme.dark(
          primary: Colors.blueAccent,
          secondary: Colors.tealAccent,
        ),
      ),
      home: isLoggedIn ? const HomeScreen() : const RegistrationScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegistrationScreen(),
        '/home': (context) => const HomeScreen(),
        '/camera': (context) => const CameraScreen(),
        '/navigation': (context) => const NavigationScreen(),
      },
    );
  }
}
