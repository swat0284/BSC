import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'accessibility_settings.dart';

class Haptics {
  static HapticsLevel _level(BuildContext context) {
    final s = Provider.of<A11ySettings>(context, listen: false);
    return s.haptics;
  }

  static void tap(BuildContext context) {
    final lvl = _level(context);
    if (lvl == HapticsLevel.off) return;
    if (lvl == HapticsLevel.high) {
      HapticFeedback.selectionClick();
    } else {
      HapticFeedback.selectionClick();
    }
  }

  static void notify(BuildContext context) {
    final lvl = _level(context);
    if (lvl == HapticsLevel.off) return;
    if (lvl == HapticsLevel.high) {
      HapticFeedback.mediumImpact();
    } else {
      HapticFeedback.selectionClick();
    }
  }

  static void outcome(BuildContext context, String reaction) {
    final lvl = _level(context);
    if (lvl == HapticsLevel.off) return;
    switch (reaction) {
      case 'bezpieczna':
        lvl == HapticsLevel.high ? HapticFeedback.lightImpact() : HapticFeedback.selectionClick();
        break;
      case 'niebezpieczna':
        HapticFeedback.heavyImpact();
        break;
      case 'współudział':
      case 'neutralna':
      default:
        HapticFeedback.selectionClick();
    }
  }
}

