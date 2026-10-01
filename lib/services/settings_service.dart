import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants.dart';

/// User-facing settings, persisted locally.
class SettingsService extends ChangeNotifier {
  bool sound = true;
  bool haptics = true;
  bool darkMode = false;
  bool notifications = true;

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      sound = prefs.getBool(PrefKeys.sound) ?? true;
      haptics = prefs.getBool(PrefKeys.haptics) ?? true;
      darkMode = prefs.getBool(PrefKeys.darkMode) ?? false;
      notifications = prefs.getBool(PrefKeys.notifications) ?? true;
    } catch (_) {
      // Keep defaults when storage is unavailable.
    }
    notifyListeners();
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(PrefKeys.sound, sound);
      await prefs.setBool(PrefKeys.haptics, haptics);
      await prefs.setBool(PrefKeys.darkMode, darkMode);
      await prefs.setBool(PrefKeys.notifications, notifications);
    } catch (_) {}
  }

  Future<void> setSound(bool v) async {
    sound = v;
    notifyListeners();
    await _save();
  }

  Future<void> setHaptics(bool v) async {
    haptics = v;
    notifyListeners();
    await _save();
  }

  Future<void> setDarkMode(bool v) async {
    darkMode = v;
    notifyListeners();
    await _save();
  }

  Future<void> setNotifications(bool v) async {
    notifications = v;
    notifyListeners();
    await _save();
  }
}
