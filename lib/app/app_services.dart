import '../core/audio/sound_service.dart';
import '../core/haptics/haptic_service.dart';
import '../puzzles/puzzle_repository.dart';
import '../services/ad_service.dart';
import '../services/daily_puzzle_service.dart';
import '../services/progress_service.dart';
import '../services/settings_service.dart';

/// Everything the screens need, passed down explicitly (no globals).
class AppServices {
  final ProgressService progress;
  final SettingsService settings;
  final SoundService sound;
  final HapticService haptics;
  final AdService ads;
  final PuzzleRepository repository;
  late final DailyPuzzleService daily = DailyPuzzleService(repository);

  AppServices({
    required this.progress,
    required this.settings,
    required this.sound,
    required this.haptics,
    required this.ads,
    required this.repository,
  });
}
