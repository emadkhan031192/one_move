import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app/app.dart';
import 'app/app_services.dart';
import 'core/audio/sound_service.dart';
import 'core/haptics/haptic_service.dart';
import 'puzzles/puzzle_repository.dart';
import 'services/ad_service.dart';
import 'services/progress_service.dart';
import 'services/settings_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  final progress = ProgressService();
  final settings = SettingsService();
  await Future.wait([progress.load(), settings.load()]);

  final sound = SoundService()..enabled = settings.sound;
  final haptics = HapticService()..enabled = settings.haptics;
  settings.addListener(() {
    sound.enabled = settings.sound;
    haptics.enabled = settings.haptics;
  });

  final services = AppServices(
    progress: progress,
    settings: settings,
    sound: sound,
    haptics: haptics,
    ads: AdService(),
    repository: PuzzleRepository(),
  );

  runApp(OneMoveApp(services: services));
}
