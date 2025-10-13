import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class Progress extends ChangeNotifier {
  int points = 0;
  int safeCount = 0;
  int neutralCount = 0;
  int riskyCount = 0;

  bool trainingMode = false;

  int dailyTarget = 3; // cele dzienne: liczba bezpiecznych wyborów
  DateTime _dailyDate = DateTime.now();
  int dailyProgress = 0;

  List<String> badges = <String>[];

  int get level => (points ~/ 100) + 1;

  void toggleTraining(bool v) {
    trainingMode = v;
    notifyListeners();
    _persist();
  }

  void setDailyTarget(int v) {
    dailyTarget = v;
    notifyListeners();
    _persist();
  }

  void _rollDailyDate() {
    final now = DateTime.now();
    if (now.year != _dailyDate.year || now.month != _dailyDate.month || now.day != _dailyDate.day) {
      _dailyDate = now;
      dailyProgress = 0;
    }
  }

  void award(String reaction) {
    _rollDailyDate();
    switch (reaction) {
      case 'bezpieczna':
        points += 10;
        safeCount++;
        dailyProgress++;
        break;
      case 'neutralna':
      case 'współudział':
        points += 3;
        neutralCount++;
        break;
      case 'niebezpieczna':
      default:
        riskyCount++;
        break;
    }
    _checkBadges();
    notifyListeners();
    _persist();
  }

  void _checkBadges() {
    void add(String id) { if (!badges.contains(id)) badges.add(id); }
    if (safeCount >= 1) add('pierwsza_bezpieczna');
    if (safeCount >= 10) add('dziesiec_bezpiecznych');
    if (points >= 100) add('100_punktow');
    if (dailyProgress >= dailyTarget && dailyTarget > 0) add('cel_dzienny');
  }
}

extension ProgressPersistence on Progress {
  Future<void> load() async {
    try {
      final sp = await SharedPreferences.getInstance();
      final raw = sp.getString('progress_v1');
      if (raw == null) return;
      final map = json.decode(raw) as Map<String, dynamic>;
      points = map['points'] as int? ?? points;
      safeCount = map['safeCount'] as int? ?? safeCount;
      neutralCount = map['neutralCount'] as int? ?? neutralCount;
      riskyCount = map['riskyCount'] as int? ?? riskyCount;
      trainingMode = map['trainingMode'] as bool? ?? trainingMode;
      dailyTarget = map['dailyTarget'] as int? ?? dailyTarget;
      dailyProgress = map['dailyProgress'] as int? ?? dailyProgress;
      final dd = map['dailyDate'] as String?;
      if (dd != null && dd.isNotEmpty) {
        _dailyDate = DateTime.tryParse(dd) ?? _dailyDate;
      }
      final badgesList = (map['badges'] as List?)?.cast<String>();
      if (badgesList != null) badges = List<String>.from(badgesList);
      _rollDailyDate();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> _persist() async {
    try {
      final sp = await SharedPreferences.getInstance();
      final map = <String, dynamic>{
        'points': points,
        'safeCount': safeCount,
        'neutralCount': neutralCount,
        'riskyCount': riskyCount,
        'trainingMode': trainingMode,
        'dailyTarget': dailyTarget,
        'dailyProgress': dailyProgress,
        'dailyDate': _dailyDate.toIso8601String(),
        'badges': badges,
      };
      await sp.setString('progress_v1', json.encode(map));
    } catch (_) {}
  }
}
