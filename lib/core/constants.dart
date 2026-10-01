/// App-wide constants.
class AppConstants {
  static const String appName = 'ONE MOVE';
  static const String tagline = 'One Puzzle. One Move. Think Different.';
  static const String homeSubtitle = 'Think. Move. Solve.';
  static const String version = '1.0.0';

  static const int totalLevels = 200;
  static const int dailyPoolSize = 60;

  /// First level id used for daily puzzles (kept out of the campaign range).
  static const int dailyIdBase = 1001;

  /// Epoch for deterministic daily-puzzle selection.
  static final DateTime dailyEpoch = DateTime(2026, 1, 1);
}

/// SharedPreferences keys.
class PrefKeys {
  static const String completedLevels = 'completed_levels';
  static const String unlockedLevel = 'unlocked_level';
  static const String attempts = 'attempts';
  static const String hintsUsed = 'hints_used';
  static const String dailyStreak = 'daily_streak';
  static const String longestDailyStreak = 'longest_daily_streak';
  static const String lastDailyKey = 'last_daily_key';
  static const String dailyDone = 'daily_done';
  static const String onboardingDone = 'onboarding_done';

  static const String sound = 'setting_sound';
  static const String haptics = 'setting_haptics';
  static const String darkMode = 'setting_dark_mode';
  static const String notifications = 'setting_notifications';
}
