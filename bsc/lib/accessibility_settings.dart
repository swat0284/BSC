import 'package:flutter/material.dart';

enum HapticsLevel { off, low, high }

class A11ySettings extends ChangeNotifier {
  double textScale = 1.1;
  bool highContrast = false;
  ThemeMode themeMode = ThemeMode.light;

  bool ttsEnabled = false;
  double ttsRate = 1.0;   // 0.7–1.3
  double ttsVolume = 1.0; // 0.0–1.0
  bool captions = true;

  HapticsLevel haptics = HapticsLevel.low;
  bool largeButtons = true;
  bool reduceMotion = false;
  bool iconLabels = true;

  void update(void Function(A11ySettings s) fn) {
    fn(this);
    notifyListeners();
  }
}
