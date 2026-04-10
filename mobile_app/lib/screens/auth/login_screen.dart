import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/voice_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  final VoiceService _voiceService = VoiceService();

  @override
  void initState() {
    super.initState();
    _voiceService.speak("Please login to continue.");
  }

  void _login() async {
    bool success = await _authService.login(
        _emailController.text, _passwordController.text);

    if (success) {
      await _voiceService.speak("Login successful.");
      if (mounted) Navigator.pushReplacementNamed(context, '/home');
    } else {
      await _voiceService
          .speak("Login failed. User not found or incorrect password.");
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Login Failed")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              child: const Text("Login"),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.pushReplacementNamed(context, '/register'),
              child: const Text("Create Account"),
            )
          ],
        ),
      ),
    );
  }
}
