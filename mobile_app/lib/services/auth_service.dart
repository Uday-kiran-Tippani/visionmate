import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_model.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  User? _currentUser;

  User? get currentUser => _currentUser;

  Future<bool> isLoggedIn() async {
    String? userJson = await _storage.read(key: 'user_data');
    if (userJson != null) {
      _currentUser = User.fromJson(jsonDecode(userJson));
      return true;
    }
    return false;
  }

  Future<void> registerUser(User user, String password) async {
    // In a real app, this would send data to a backend.
    // Here, we store locally for offline-first capability.
    _currentUser = user;
    await _storage.write(key: 'user_data', value: jsonEncode(user.toJson()));
    await _storage.write(
        key: 'auth_token',
        value: 'dummy_token_${DateTime.now().millisecondsSinceEpoch}');
  }

  Future<bool> login(String email, String password) async {
    // Mock login check
    // In real app, verify against stored hash or backend
    String? storedUserJson = await _storage.read(key: 'user_data');
    if (storedUserJson != null) {
      User storedUser = User.fromJson(jsonDecode(storedUserJson));
      if (storedUser.email == email) {
        _currentUser = storedUser;
        return true;
      }
    }
    return false;
  }

  Future<void> logout() async {
    await _storage.delete(key: 'user_data');
    await _storage.delete(key: 'auth_token');
    _currentUser = null;
  }

  Future<String> getVoicePreference() async {
    return _currentUser?.voicePreference ?? 'jarvis';
  }
}
