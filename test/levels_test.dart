import 'package:flutter_test/flutter_test.dart';
import 'package:one_move/core/constants.dart';
import 'package:one_move/core/utils.dart';
import 'package:one_move/models/puzzle.dart';
import 'package:one_move/puzzle_engine/puzzle_engine.dart';
import 'package:one_move/puzzles/level_data.dart';

void main() {
  final levels = buildAllLevels();

  test('builds exactly 200 levels with ids 1..200', () {
    expect(levels.length, AppConstants.totalLevels);
    final ids = levels.map((p) => p.id).toList()..sort();
    expect(ids, List.generate(200, (i) => i + 1));
  });

  test('every level has 3 hints, an explanation and an instruction', () {
    for (final p in levels) {
      expect(p.hints.length, 3, reason: 'level ${p.id} hints');
      expect(
        p.explanation.isNotEmpty,
        isTrue,
        reason: 'level ${p.id} explanation',
      );
      expect(
        p.instruction.isNotEmpty,
        isTrue,
        reason: 'level ${p.id} instruction',
      );
      expect(p.title.isNotEmpty, isTrue, reason: 'level ${p.id} title');
    }
  });

  test('every level is solvable via its stored solved state', () {
    for (final p in levels) {
      final solved = p.solvedState;
      expect(solved, isNotNull, reason: 'level ${p.id} is missing solvedState');
      final verdict = PuzzleEngine.evaluate(p, p.initialState, solved!);
      expect(
        verdict.solved,
        isTrue,
        reason: 'level ${p.id} (${p.type.label}) is not solvable',
      );
      expect(verdict.movesUsed, 1, reason: 'level ${p.id} movesUsed');
    }
  });

  test('no level starts already solved', () {
    for (final p in levels) {
      final verdict = PuzzleEngine.evaluate(
        p,
        p.initialState,
        deepCopyState(p.initialState),
      );
      expect(verdict.solved, isFalse, reason: 'level ${p.id}');
      expect(verdict.movesUsed, 0, reason: 'level ${p.id}');
    }
  });

  test('difficulty bands match the spec', () {
    void band(int from, int to, Difficulty d) {
      for (var id = from; id <= to; id++) {
        final p = levels.firstWhere((e) => e.id == id);
        expect(p.difficulty, d, reason: 'level $id');
      }
    }

    band(1, 20, Difficulty.tutorial);
    band(21, 50, Difficulty.easy);
    band(51, 100, Difficulty.medium);
    band(101, 150, Difficulty.hard);
    band(151, 180, Difficulty.veryHard);
    band(181, 200, Difficulty.expert);
  });

  test('all six puzzle types are represented', () {
    final types = levels.map((p) => p.type).toSet();
    expect(types.length, PuzzleType.values.length);
  });

  test('daily pool has 60 deterministic puzzles', () {
    final a = buildDailyPool();
    final b = buildDailyPool();
    expect(a.length, AppConstants.dailyPoolSize);
    expect(a.map((p) => p.id).toList(), b.map((p) => p.id).toList());
    for (final p in a) {
      final solved = p.solvedState!;
      final verdict = PuzzleEngine.evaluate(p, p.initialState, solved);
      expect(verdict.solved, isTrue, reason: 'daily ${p.id}');
    }
  });
}
