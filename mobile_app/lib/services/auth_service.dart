import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'database_helper.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final DatabaseHelper _dbHelper = DatabaseHelper();
  User? _currentUser;

  User? get currentUser => _currentUser;

  // Initialize session from SharedPreferences
  Future<bool> checkSession() async {
    final prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('user_email');
    if (email != null) {
      final userMap = await _dbHelper.getUser(email);
      if (userMap != null) {
        _currentUser = User.fromJson(userMap);
        return true;
      }
    }
    return false;
  }

  Future<void> registerUser(User user, String password) async {
    String passwordHash = _hashPassword(password);
    await _dbHelper.insertUser(user, passwordHash);
    _currentUser = user;
    await _saveSession(user.email);
  }

  Future<bool> login(String email, String password) async {
    final userMap = await _dbHelper.getUser(email);
    if (userMap != null) {
      String storedHash = userMap['passwordHash'];
      String inputHash = _hashPassword(password);
      if (storedHash == inputHash) {
        _currentUser = User.fromJson(userMap);
        await _saveSession(email);
        return true;
      }
    }
    return false;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_email');
    _currentUser = null;
  }

  Future<void> _saveSession(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_email', email);
  }

  String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }
}
