import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:one_move/core/utils.dart';
import 'package:one_move/models/puzzle.dart';
import 'package:one_move/puzzles/puzzle_repository.dart';
import 'package:one_move/services/daily_puzzle_service.dart';
import 'package:one_move/services/progress_service.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  group('progress + unlocking', () {
    test('starts at level 1 with nothing completed', () async {
      final p = ProgressService();
      await p.load();
      expect(p.unlockedLevel, 1);
      expect(p.isUnlocked(1), isTrue);
      expect(p.isUnlocked(2), isFalse);
      expect(p.completedLevels, isEmpty);
    });

    test('completing a level unlocks the next one', () async {
      final p = ProgressService();
      await p.load();
      await p.completeLevel(1);
      expect(p.isCompleted(1), isTrue);
      expect(p.unlockedLevel, 2);
      expect(p.isUnlocked(2), isTrue);
      expect(p.isUnlocked(3), isFalse);
      await p.completeLevel(2);
      expect(p.unlockedLevel, 3);
    });

    test('replaying a completed level does not over-unlock', () async {
      final p = ProgressService();
      await p.load();
      await p.completeLevel(1);
      await p.completeLevel(1);
      expect(p.unlockedLevel, 2);
    });

    test('attempts and hints are tracked', () async {
      final p = ProgressService();
      await p.load();
      await p.recordAttempt();
      await p.recordAttempt();
      await p.useHint();
      expect(p.attempts, 2);
      expect(p.hintsUsed, 1);
      expect(p.successRate, 0);
      await p.completeLevel(1);
      expect(p.attempts, 3);
      expect(p.successRate, closeTo(1 / 3, 0.001));
      expect(p.hardestLevelSolved, 1);
    });

    test('progress persists across service instances', () async {
      final p = ProgressService();
      await p.load();
      await p.completeLevel(7);
      await p.useHint();
      final p2 = ProgressService();
      await p2.load();
      expect(p2.isCompleted(7), isTrue);
      expect(p2.unlockedLevel, 8);
      expect(p2.hintsUsed, 1);
    });

    test('reset clears everything', () async {
      final p = ProgressService();
      await p.load();
      await p.completeLevel(3);
      await p.resetProgress();
      expect(p.completedLevels, isEmpty);
      expect(p.unlockedLevel, 1);
      expect(p.attempts, 0);
      expect(p.hintsUsed, 0);
      final p2 = ProgressService();
      await p2.load();
      expect(p2.unlockedLevel, 1);
    });

    test('completion percent', () async {
      final p = ProgressService();
      await p.load();
      await p.completeLevel(1);
      await p.completeLevel(2);
      expect(p.completionPercent(200), 0.01);
    });
  });

  group('daily puzzles', () {
    test('same calendar date always yields the same puzzle', () {
      final repo = PuzzleRepository();
      final svc = DailyPuzzleService(repo);
      final a = svc.puzzleForDate(DateTime(2026, 5, 4));
      final b = svc.puzzleForDate(DateTime(2026, 5, 4, 23, 59, 59));
      expect(a.id, b.id);
    });

    test('consecutive dates yield different puzzles', () {
      final repo = PuzzleRepository();
      final svc = DailyPuzzleService(repo);
      final a = svc.puzzleForDate(DateTime(2026, 5, 4));
      final b = svc.puzzleForDate(DateTime(2026, 5, 5));
      expect(a.id, isNot(b.id));
    });

    test('streak grows on consecutive days', () async {
      final p = ProgressService();
      await p.load();
      await p.completeDaily(DateTime(2026, 3, 1));
      expect(p.dailyStreak, 1);
      expect(p.isDailyDone(DateTime(2026, 3, 1)), isTrue);
      await p.completeDaily(DateTime(2026, 3, 2));
      expect(p.dailyStreak, 2);
      expect(p.longestDailyStreak, 2);
    });

    test('streak resets after a missed day', () async {
      final p = ProgressService();
      await p.load();
      await p.completeDaily(DateTime(2026, 3, 1));
      await p.completeDaily(DateTime(2026, 3, 2));
      await p.completeDaily(DateTime(2026, 3, 4)); // skipped the 3rd
      expect(p.dailyStreak, 1);
      expect(p.longestDailyStreak, 2);
    });

    test('completing the same day twice is a no-op', () async {
      final p = ProgressService();
      await p.load();
      await p.completeDaily(DateTime(2026, 3, 1));
      await p.completeDaily(DateTime(2026, 3, 1));
      expect(p.dailyStreak, 1);
    });
  });

  group('hints', () {
    test('hints reveal progressively and stop at three', () {
      final h = HintProgression(['a', 'b', 'c']);
      expect(h.hasMore, isTrue);
      expect(h.revealNext(), 'a');
      expect(h.revealNext(), 'b');
      expect(h.visible, ['a', 'b']);
      expect(h.revealNext(), 'c');
      expect(h.hasMore, isFalse);
      expect(h.revealNext(), isNull);
      expect(h.visible, ['a', 'b', 'c']);
    });
  });

  group('utils', () {
    test('dateKey is stable per calendar day', () {
      expect(
        dateKey(DateTime(2026, 1, 5, 23, 59)),
        dateKey(DateTime(2026, 1, 5, 0, 1)),
      );
      expect(dateKey(DateTime(2026, 1, 5)), '2026-01-05');
    });

    test('posMod handles negatives', () {
      expect(posMod(-1, 60), 59);
      expect(posMod(61, 60), 1);
    });
  });
}
