import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  TtsService._();
  static final TtsService instance = TtsService._();

  final FlutterTts _tts = FlutterTts();
  bool _initialized = false;
  bool _isSpeaking = false;

  bool get isSpeaking => _isSpeaking;

  Future<void> _ensureInit({String? language}) async {
    if (_initialized) return;
    // Try to set sensible defaults for Polish; ignore failures silently.
    try {
      await _tts.setLanguage(language ?? 'pl-PL');
    } catch (_) {}
    await _tts.setPitch(1.0);
    _tts.setStartHandler(() => _isSpeaking = true);
    _tts.setCompletionHandler(() => _isSpeaking = false);
    _tts.setCancelHandler(() => _isSpeaking = false);
    _initialized = true;
  }

  Future<void> configure({double? rate, double? volume, String? language}) async {
    await _ensureInit(language: language);
    if (rate != null) {
      await _tts.setSpeechRate(rate.clamp(0.1, 1.5));
    }
    if (volume != null) {
      await _tts.setVolume(volume.clamp(0.0, 1.0));
    }
  }

  Future<void> speak(String text, {double? rate, double? volume, String? language}) async {
    if (text.trim().isEmpty) return;
    await _ensureInit(language: language);
    if (rate != null) {
      await _tts.setSpeechRate(rate.clamp(0.1, 1.5));
    }
    if (volume != null) {
      await _tts.setVolume(volume.clamp(0.0, 1.0));
    }
    await _tts.stop();
    _isSpeaking = true;
    await _tts.speak(text);
  }

  Future<void> stop() async {
    await _tts.stop();
    _isSpeaking = false;
  }
}

