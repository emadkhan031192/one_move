import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants.dart';
import '../core/utils.dart';

/// Persists and exposes everything about the player's journey:
/// unlocked/completed levels, attempts, hints, daily streaks, onboarding.
class ProgressService extends ChangeNotifier {
  Set<int> completedLevels = {};
  int unlockedLevel = 1;
  int attempts = 0;
  int hintsUsed = 0;
  int dailyStreak = 0;
  int longestDailyStreak = 0;
  String? lastDailyKey;
  Set<String> dailyDone = {};
  bool onboardingDone = false;

  bool _loaded = false;
  bool get loaded => _loaded;

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      completedLevels = (prefs.getStringList(PrefKeys.completedLevels) ?? [])
          .map((e) => int.tryParse(e) ?? -1)
          .where((e) => e > 0)
          .toSet();
      unlockedLevel = prefs.getInt(PrefKeys.unlockedLevel) ?? 1;
      if (unlockedLevel < 1) unlockedLevel = 1;
      if (unlockedLevel > AppConstants.totalLevels) {
        unlockedLevel = AppConstants.totalLevels;
      }
      attempts = prefs.getInt(PrefKeys.attempts) ?? 0;
      hintsUsed = prefs.getInt(PrefKeys.hintsUsed) ?? 0;
      dailyStreak = prefs.getInt(PrefKeys.dailyStreak) ?? 0;
      longestDailyStreak = prefs.getInt(PrefKeys.longestDailyStreak) ?? 0;
      lastDailyKey = prefs.getString(PrefKeys.lastDailyKey);
      dailyDone = (prefs.getStringList(PrefKeys.dailyDone) ?? []).toSet();
      onboardingDone = prefs.getBool(PrefKeys.onboardingDone) ?? false;
    } catch (_) {
      // Corrupted storage: start clean rather than crash.
      _resetMemory();
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
        PrefKeys.completedLevels,
        completedLevels.map((e) => e.toString()).toList(),
      );
      await prefs.setInt(PrefKeys.unlockedLevel, unlockedLevel);
      await prefs.setInt(PrefKeys.attempts, attempts);
      await prefs.setInt(PrefKeys.hintsUsed, hintsUsed);
      await prefs.setInt(PrefKeys.dailyStreak, dailyStreak);
      await prefs.setInt(PrefKeys.longestDailyStreak, longestDailyStreak);
      if (lastDailyKey != null) {
        await prefs.setString(PrefKeys.lastDailyKey, lastDailyKey!);
      }
      await prefs.setStringList(PrefKeys.dailyDone, dailyDone.toList());
      await prefs.setBool(PrefKeys.onboardingDone, onboardingDone);
    } catch (_) {
      // Storage failure must never break gameplay.
    }
  }

  bool isUnlocked(int id) => id <= unlockedLevel;
  bool isCompleted(int id) => completedLevels.contains(id);

  /// Records a judged move that did not solve the puzzle.
  Future<void> recordAttempt() async {
    attempts++;
    notifyListeners();
    await _save();
  }

  /// Marks a campaign level solved (counts as an attempt) and unlocks next.
  Future<void> completeLevel(int id) async {
    attempts++;
    completedLevels.add(id);
    if (id >= unlockedLevel && id < AppConstants.totalLevels) {
      unlockedLevel = id + 1;
    }
    notifyListeners();
    await _save();
  }

  Future<void> useHint() async {
    hintsUsed++;
    notifyListeners();
    await _save();
  }

  bool isDailyDone(DateTime date) => dailyDone.contains(dateKey(date));

  /// Marks a daily puzzle complete and maintains the streak.
  Future<void> completeDaily(DateTime date) async {
    final key = dateKey(date);
    if (dailyDone.contains(key)) return;
    dailyDone.add(key);
    final yesterdayKey = dateKey(date.subtract(const Duration(days: 1)));
    if (lastDailyKey == yesterdayKey) {
      dailyStreak += 1;
    } else {
      dailyStreak = 1;
    }
    longestDailyStreak = max(longestDailyStreak, dailyStreak);
    lastDailyKey = key;
    notifyListeners();
    await _save();
  }

  double completionPercent(int total) {
    if (total <= 0) return 0;
    return completedLevels.length / total;
  }

  int get hardestLevelSolved =>
      completedLevels.isEmpty ? 0 : completedLevels.reduce(max);

  double get successRate =>
      attempts == 0 ? 0 : completedLevels.length / attempts;

  Future<void> setOnboardingDone() async {
    onboardingDone = true;
    notifyListeners();
    await _save();
  }

  Future<void> resetProgress() async {
    _resetMemory();
    notifyListeners();
    await _save();
  }

  void _resetMemory() {
    completedLevels = {};
    unlockedLevel = 1;
    attempts = 0;
    hintsUsed = 0;
    dailyStreak = 0;
    longestDailyStreak = 0;
    lastDailyKey = null;
    dailyDone = {};
    onboardingDone = false;
  }
}
