import 'dart:async';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'command_service.dart';
import 'auth_service.dart';

class VoiceService {
  final FlutterTts _flutterTts = FlutterTts();
  final stt.SpeechToText _speech = stt.SpeechToText();
  final CommandService _commandService = CommandService();
  final AuthService _authService = AuthService();

  bool _isListening = false;
  bool _isSpeaking = false;
  bool _initialized = false;
  Function(String)? _onStatusChange;
  Function(String)? _onResult;

  static final VoiceService _instance = VoiceService._internal();
  factory VoiceService() => _instance;
  VoiceService._internal();

  Future<void> init(
      {Function(String)? onStatusChange, Function(String)? onResult}) async {
    _onStatusChange = onStatusChange;
    _onResult = onResult;

    if (!_initialized) {
      await _initTts();
      await _initStt();
      _initialized = true;
    }
  }

  // Future<void> _initTts() async {
  //   await _flutterTts.setLanguage("en-US");
  //   await _flutterTts.setPitch(1.0);
  //   await _flutterTts.setSpeechRate(0.5);

  //   _flutterTts.setStartHandler(() => _isSpeaking = true);
  //   _flutterTts.setCompletionHandler(() {
  //     _isSpeaking = false;
  //     // Restart listening after speaking finishes
  //     startListening();
  //   });
  //   _flutterTts.setCancelHandler(() => _isSpeaking = false);

  //   // Set voice based on preference
  //   String? pref = await _authService.currentUser?.voicePreference;
  //   if (pref == 'friday') {
  //     // Try to find a female voice
  //     // This is platform specific, simplified for now
  //     // On Android, engines usually have "en-us-x-sfg" vs "en-us-x-iom" etc.
  //     // We'll stick to default engine's default for now or iterate voices if needed.
  //     // Expanding this cleanly requires listing voices.
  //   }
  // }
  Future<void> _initTts() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(0.5);

    _flutterTts.setStartHandler(() => _isSpeaking = true);
    _flutterTts.setCompletionHandler(() {
      _isSpeaking = false;
      // Restart listening after speaking finishes
      startListening();
    });
    _flutterTts.setCancelHandler(() => _isSpeaking = false);

    // Set voice based on preference
    String? pref = _authService.currentUser?.voicePreference ?? 'jarvis';

    List<dynamic>? voices = await _flutterTts.getVoices;

    if (voices != null && voices.isNotEmpty) {
      // Android & iOS voice selection
      // We'll pick first male/female available
      String? selectedVoice;

      if (pref == 'jarvis') {
        selectedVoice = voices.firstWhere(
          (v) =>
              v.toString().toLowerCase().contains('male') ||
              v.toString().toLowerCase().contains('en-us-x-sfg'),
          orElse: () => voices.first,
        );
      } else if (pref == 'friday') {
        selectedVoice = voices.firstWhere(
          (v) =>
              v.toString().toLowerCase().contains('female') ||
              v.toString().toLowerCase().contains('en-us-x-iom'),
          orElse: () => voices.first,
        );
      }

      if (selectedVoice != null) {
        await _flutterTts.setVoice({"name": selectedVoice, "locale": "en-US"});
      }
    }
  }

  Future<void> _initStt() async {
    await _speech.initialize(
      onStatus: (status) {
        if (_onStatusChange != null) _onStatusChange!(status);
        if (status == 'done' || status == 'notListening') {
          _isListening = false;
          // Auto-restart if not speaking
          if (!_isSpeaking) {
            // startListening(); // Be careful with loops
          }
        }
      },
      onError: (error) {
        print('STT Error: $error');
        _isListening = false;
        // If error is permanent, maybe stop. If transient, restart.
        // For no match, we might want to prompt user.
        if (!_isSpeaking) startListening();
      },
    );
  }

  Future<void> speak(String text) async {
    if (_isListening) {
      await _speech.stop();
      _isListening = false;
    }
    if (_isSpeaking) {
      await _flutterTts.stop();
    }
    await _flutterTts.speak(text);
  }

  void startListening() async {
    if (_isSpeaking) return;
    if (_isListening) return;

    bool available = await _speech.initialize();
    if (available) {
      _isListening = true;
      _speech.listen(
        onResult: (result) {
          if (_onResult != null) _onResult!(result.recognizedWords);

          if (result.finalResult) {
            _isListening = false;
            _processCommand(result.recognizedWords);
          }
        },
        listenFor: const Duration(seconds: 10),
        pauseFor: const Duration(seconds: 3),
        partialResults: true,
        cancelOnError: false,
        listenMode: stt.ListenMode.dictation,
      );
    }
  }

  void stopListening() {
    _speech.stop();
    _isListening = false;
  }

  Future<void> _processCommand(String text) async {
    if (text.trim().isEmpty) {
      startListening();
      return;
    }

    String response = await _commandService.processCommand(text);
    if (response.isNotEmpty) {
      await speak(response);
    } else {
      await speak("I didn't understand that. Please say it again.");
    }
  }
}
