import 'dart:async';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart'; // Add this package to pubspec.yaml
import 'command_service.dart';
import 'auth_service.dart';

class VoiceService {
  final FlutterTts _flutterTts = FlutterTts();
  final stt.SpeechToText _speech = stt.SpeechToText();
  final CommandService _commandService = CommandService();
  final AuthService _authService = AuthService();

  bool _isListening = false;
  bool _isSpeaking = false;
  bool _speechEnabled = false;
  bool _initialized = false;

  Function(String)? _onStatusChange;
  Function(String)? _onResult;

  static final VoiceService _instance = VoiceService._internal();
  factory VoiceService() => _instance;
  VoiceService._internal();

  Future<void> init({
    Function(String)? onStatusChange,
    Function(String)? onResult,
  }) async {
    _onStatusChange = onStatusChange;
    _onResult = onResult;

    if (_initialized) return;

    // 1. Request Permissions explicitly
    await _requestPermissions();

    // 2. Init TTS first
    await _initTts();

    // 3. Init STT
    await _initStt();

    _initialized = true;
  }

  Future<void> _requestPermissions() async {
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      await Permission.microphone.request();
    }
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(0.5);

    _flutterTts.setStartHandler(() {
      _isSpeaking = true;
      _speech.stop(); // Stop listening immediately when talking starts
    });

    _flutterTts.setCompletionHandler(() {
      _isSpeaking = false;
      // Small delay to prevent the mic from picking up the end of the TTS audio
      Future.delayed(Duration(milliseconds: 500), () => startListening());
    });

    _flutterTts.setCancelHandler(() => _isSpeaking = false);
  }

  Future<void> _initStt() async {
    _speechEnabled = await _speech.initialize(
      onStatus: (status) {
        if (_onStatusChange != null) _onStatusChange!(status);
        print("STT Status: $status");

        if (status == "done" || status == "notListening") {
          _isListening = false;
          // Only restart if we aren't currently speaking
          if (!_isSpeaking) {
            Future.delayed(
                Duration(milliseconds: 1000), () => startListening());
          }
        }
      },
      onError: (error) {
        print("STT Error: $error");
        _isListening = false;
        // Restart on error to keep the app "always on" for blind users
        Future.delayed(Duration(seconds: 2), () => startListening());
      },
    );
  }

  Future<void> speak(String text) async {
    _isSpeaking = true;
    if (_isListening) {
      await _speech.stop();
      _isListening = false;
    }
    await _flutterTts.speak(text);
  }

  void startListening() async {
    if (!_speechEnabled || _isSpeaking || _isListening) return;

    _isListening = true;

    // Use a try-catch for the listen method
    try {
      await _speech.listen(
        onResult: (result) {
          if (_onResult != null) _onResult!(result.recognizedWords);

          if (result.finalResult) {
            _isListening = false;
            _processCommand(result.recognizedWords);
          }
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 5),
        partialResults: true,
        listenMode: stt.ListenMode.dictation,
        cancelOnError: false,
      );
    } catch (e) {
      _isListening = false;
      print("Listen error: $e");
    }
  }

  void stopListening() {
    _speech.stop();
    _isListening = false;
  }

  Future<void> _processCommand(String text) async {
    if (text.trim().isEmpty) return;

    print("Processing: $text");
    String response = await _commandService.processCommand(text);

    if (response.isNotEmpty) {
      await speak(response);
    } else {
      await speak("I didn't understand that.");
    }
  }
}
