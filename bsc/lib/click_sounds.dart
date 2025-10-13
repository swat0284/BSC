import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

class ClickSounds {
  static Future<void> play() async {
    try {
      // Light haptic for accessibility/feedback (non-blocking)
      HapticFeedback.selectionClick();
    } catch (_) {}

    try {
      final p = AudioPlayer();
      p.setReleaseMode(ReleaseMode.stop);
      await p.play(AssetSource('audio/click.mp3'));
      // Dispose player when clip finishes
      unawaited(p.onPlayerComplete.first.then((_) => p.dispose()));
    } catch (_) {
      // Silently ignore if asset missing or audio fails
    }
  }
}
