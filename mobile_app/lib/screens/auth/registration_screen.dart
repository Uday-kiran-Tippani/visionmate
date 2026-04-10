import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/voice_service.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController =
      TextEditingController(); // Added password controller
  String _voicePreference = 'jarvis';

  final VoiceService _voiceService = VoiceService();
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _speakInstructions();
  }

  void _speakInstructions() async {
    await _voiceService.speak(
        "Welcome to VisionMate. Please enter your name, phone number, email, and password. You can also choose my voice.");
  }

  void _register() async {
    if (_formKey.currentState!.validate()) {
      final user = User(
        name: _nameController.text,
        phone: _phoneController.text,
        email: _emailController.text,
        voicePreference: _voicePreference,
      );

      // Use actual password
      await _authService.registerUser(user, _passwordController.text);
      await _voiceService.speak("Registration successful. Logging you in.");

      if (mounted) {
        // Navigate to VoiceHomeScreen
        Navigator.pushReplacementNamed(context, '/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Registration")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Name"),
                validator: (val) => val!.isEmpty ? "Enter name" : null,
              ),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: "Phone"),
                keyboardType: TextInputType.phone,
                validator: (val) => val!.isEmpty ? "Enter phone" : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: "Email"),
                keyboardType: TextInputType.emailAddress,
                validator: (val) => val!.isEmpty ? "Enter email" : null,
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: "Password"),
                obscureText: true,
                validator: (val) => val!.isEmpty ? "Enter password" : null,
              ),
              const SizedBox(height: 20),
              const Text("Select Voice Assistant:",
                  style: TextStyle(fontSize: 18)),
              RadioListTile(
                title: const Text("Jarvis (Male)"),
                value: 'jarvis',
                groupValue: _voicePreference,
                onChanged: (val) =>
                    setState(() => _voicePreference = val.toString()),
              ),
              RadioListTile(
                title: const Text("Friday (Female)"),
                value: 'friday',
                groupValue: _voicePreference,
                onChanged: (val) =>
                    setState(() => _voicePreference = val.toString()),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _register,
                child: const Text("Register"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
