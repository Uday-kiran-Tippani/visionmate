import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:wakelock_plus/wakelock_plus.dart';
import 'automation_service.dart';
import 'knowledge_service.dart';

class VoiceService {
  final FlutterTts _flutterTts = FlutterTts();
  final stt.SpeechToText _speech = stt.SpeechToText();
  final AutomationService _automationService = AutomationService();
  final KnowledgeService _knowledgeService = KnowledgeService();

  bool _isListening = false;
  bool _isSpeaking = false;
  // Simple wake word for now, can be improved with Porcupine or similar
  final String _wakeWord = "jarvis";

  static final VoiceService _instance = VoiceService._internal();
  factory VoiceService() => _instance;
  VoiceService._internal() {
    _init();
  }

  void _init() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(0.5);

    _flutterTts.setStartHandler(() => _isSpeaking = true);
    _flutterTts.setCompletionHandler(() => _isSpeaking = false);
    _flutterTts.setCancelHandler(() => _isSpeaking = false);

    await WakelockPlus.enable(); // Keep screen on for continuous listening
  }

  Future<void> speak(String text) async {
    if (_isSpeaking) await stopSpeaking();
    await _flutterTts.speak(text);
  }

  Future<void> stopSpeaking() async {
    await _flutterTts.stop();
    _isSpeaking = false;
  }

  Future<void> listenAndProcess() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (status) {
          print('STT Status: $status');
          if (status == 'done' || status == 'notListening') {
            _isListening = false;
            // Restart listening loop if needed
          }
        },
        onError: (error) => print('STT Error: $error'),
      );

      if (available) {
        _isListening = true;
        _speech.listen(
          onResult: (val) {
            if (val.finalResult) {
              _processCommand(val.recognizedWords);
            }
          },
          listenFor: const Duration(seconds: 10),
          pauseFor: const Duration(seconds: 3),
          partialResults: false,
        );
      }
    }
  }

  void _processCommand(String command) async {
    print("Command recognized: $command");
    command = command.toLowerCase();

    // 1. Wake word check (simplistic)
    // if (!command.contains(_wakeWord)) return; // Uncomment to enforce wake word

    if (command.contains("open")) {
      // Extract app name? "open whatsapp"
      if (command.contains("whatsapp")) {
        await speak("Opening WhatsApp");
        await _automationService.launchApp("com.whatsapp");
      } else if (command.contains("youtube")) {
        await speak("Opening YouTube");
        await _automationService.launchApp("com.google.android.youtube");
      }
    } else if (command.contains("call")) {
      // "Call Mom" -> extract name
      String name = command.replaceAll("call", "").trim();
      if (name.isNotEmpty) {
        await speak("Calling $name");
        try {
          await _automationService.makeCall(name);
        } catch (e) {
          await speak("I couldn't find contact $name");
        }
      }
    } else if (command.contains("navigate to") ||
        command.contains("take me to")) {
      String destination = command
          .replaceAll("navigate to", "")
          .replaceAll("take me to", "")
          .trim();
      if (destination.isNotEmpty) {
        await speak("Starting navigation to $destination");
        await _automationService.openGoogleMaps(destination);
      } else {
        await speak("Where would you like to go?");
      }
    } else if (command.contains("where is my")) {
      // Object finding mode
      await speak("Let's look for it.");
      // This would trigger vision service mode switch in UI
    } else if (command.contains("what is") || command.contains("who is")) {
      await speak("Let me check that for you.");
      String result = await _knowledgeService.queryWikipedia(command);
      await speak(result);
    } else if (command.contains("time")) {
      await speak(
          "The time is ${DateTime.now().hour}:${DateTime.now().minute}");
    } else {
      await speak("I didn't catch that command.");
    }
  }

  void stopListening() {
    _speech.stop();
    _isListening = false;
  }
}
