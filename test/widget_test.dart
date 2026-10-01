import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:one_move/app/app_services.dart';
import 'package:one_move/core/audio/sound_service.dart';
import 'package:one_move/core/haptics/haptic_service.dart';
import 'package:one_move/puzzles/puzzle_repository.dart';
import 'package:one_move/screens/game_screen.dart';
import 'package:one_move/screens/home_screen.dart';
import 'package:one_move/screens/level_select_screen.dart';
import 'package:one_move/screens/settings_screen.dart';
import 'package:one_move/services/ad_service.dart';
import 'package:one_move/services/progress_service.dart';
import 'package:one_move/services/settings_service.dart';
import 'package:one_move/widgets/level_card.dart';

Future<AppServices> makeServices() async {
  SharedPreferences.setMockInitialValues({});
  final progress = ProgressService();
  final settings = SettingsService();
  await progress.load();
  await settings.load();
  return AppServices(
    progress: progress,
    settings: settings,
    sound: SoundService(),
    haptics: HapticService(),
    ads: AdService(),
    repository: PuzzleRepository(),
  );
}

void main() {
  group('home screen', () {
    testWidgets('shows brand, stats and all destinations', (tester) async {
      final services = await makeServices();
      await tester.pumpWidget(
        MaterialApp(home: HomeScreen(services: services)),
      );
      await tester.pumpAndSettle();
      expect(find.text('PLAY'), findsOneWidget);
      expect(find.text('LEVELS'), findsOneWidget);
      expect(find.text('DAILY PUZZLE'), findsOneWidget);
      expect(find.text('STATS'), findsOneWidget);
      expect(find.text('SETTINGS'), findsOneWidget);
      expect(find.text('Level'), findsOneWidget);
    });
  });

  group('level select', () {
    testWidgets('renders the grid with locks beyond progress', (tester) async {
      final services = await makeServices();
      await tester.pumpWidget(
        MaterialApp(home: LevelSelectScreen(services: services)),
      );
      await tester.pumpAndSettle();
      expect(find.text('01'), findsOneWidget);
      // Level 2 starts locked.
      final card2 = tester.widget<LevelCard>(
        find.byWidgetPredicate((w) => w is LevelCard && w.level == 2),
      );
      expect(card2.unlocked, isFalse);
    });

    testWidgets('completing a level unlocks it in the grid', (tester) async {
      final services = await makeServices();
      await services.progress.completeLevel(1);
      await tester.pumpWidget(
        MaterialApp(home: LevelSelectScreen(services: services)),
      );
      await tester.pumpAndSettle();
      final card2 = tester.widget<LevelCard>(
        find.byWidgetPredicate((w) => w is LevelCard && w.level == 2),
      );
      expect(card2.unlocked, isTrue);
    });
  });

  group('game screen', () {
    testWidgets('shows title, instruction, retry and hint controls', (
      tester,
    ) async {
      final services = await makeServices();
      final puzzle = services.repository.levelById(1)!;
      await tester.pumpWidget(
        MaterialApp(
          home: GameScreen(services: services, puzzle: puzzle),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Level 1'), findsOneWidget);
      expect(find.text('First Move'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
      expect(find.text('You have ONE move.'), findsOneWidget);
      expect(find.byIcon(Icons.lightbulb_outline_rounded), findsOneWidget);
    });

    testWidgets('solving level 1 shows the success overlay', (tester) async {
      final services = await makeServices();
      final puzzle = services.repository.levelById(1)!;
      await tester.pumpWidget(
        MaterialApp(
          home: GameScreen(services: services, puzzle: puzzle),
        ),
      );
      await tester.pumpAndSettle();

      // Select the 9, then pick 6.
      await tester.tap(find.text('9').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('6').first);
      await tester.pumpAndSettle();

      expect(find.text('SOLVED!'), findsOneWidget);
      expect(services.progress.isCompleted(1), isTrue);
      expect(services.progress.unlockedLevel, 2);
    });

    testWidgets('hint button reveals hints progressively', (tester) async {
      final services = await makeServices();
      final puzzle = services.repository.levelById(1)!;
      await tester.pumpWidget(
        MaterialApp(
          home: GameScreen(services: services, puzzle: puzzle),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.lightbulb_outline_rounded));
      await tester.pumpAndSettle();
      expect(find.text('Look at the last digit.'), findsOneWidget);
      expect(find.text('Next hint'), findsOneWidget);
      expect(services.progress.hintsUsed, 1);
    });
  });

  group('settings screen', () {
    testWidgets('shows toggles and data actions', (tester) async {
      final services = await makeServices();
      await tester.pumpWidget(
        MaterialApp(home: SettingsScreen(services: services)),
      );
      await tester.pumpAndSettle();
      expect(find.text('Sound'), findsOneWidget);
      expect(find.text('Haptics'), findsOneWidget);
      expect(find.text('Dark mode'), findsOneWidget);
      expect(find.text('Reset progress'), findsOneWidget);
      expect(find.text('Privacy'), findsOneWidget);
    });

    testWidgets('toggling dark mode persists', (tester) async {
      final services = await makeServices();
      await tester.pumpWidget(
        MaterialApp(home: SettingsScreen(services: services)),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Dark mode'));
      await tester.pumpAndSettle();
      expect(services.settings.darkMode, isTrue);
    });
  });
}
