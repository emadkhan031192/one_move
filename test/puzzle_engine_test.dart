import 'package:flutter_test/flutter_test.dart';
import 'package:one_move/models/puzzle.dart';
import 'package:one_move/puzzle_engine/puzzle_engine.dart';

Puzzle _p(
  PuzzleType type,
  Map<String, dynamic> initial, {
  Map<String, dynamic> metadata = const {},
}) => Puzzle(
  id: 1,
  type: type,
  difficulty: Difficulty.easy,
  title: 't',
  instruction: 'i',
  initialState: initial,
  hints: const ['h1', 'h2', 'h3'],
  explanation: 'e',
  metadata: metadata,
);

void main() {
  group('matchstick', () {
    final initial = {
      'chars': ['3', '+', '3', '=', '9'],
    };
    test('valid one-stick fix solves', () {
      final v = PuzzleEngine.evaluate(
        _p(PuzzleType.matchstick, initial),
        initial,
        {
          'chars': ['3', '+', '3', '=', '6'],
        },
      );
      expect(v.solved, isTrue);
      expect(v.movesUsed, 1);
    });

    test('wrong equation with one legal stick move is not solved', () {
      final v = PuzzleEngine.evaluate(
        _p(PuzzleType.matchstick, initial),
        initial,
        {
          'chars': ['3', '+', '3', '=', '0'],
        },
      );
      expect(v.solved, isFalse);
      expect(v.movesUsed, 1);
      expect(v.feedback, isNotEmpty);
    });

    test('two changed digits count as two moves', () {
      final v = PuzzleEngine.evaluate(
        _p(PuzzleType.matchstick, initial),
        initial,
        {
          'chars': ['3', '+', '2', '=', '6'],
        },
      );
      expect(v.solved, isFalse);
      expect(v.movesUsed, 2);
    });

    test('stick-count violation is rejected', () {
      // 9 (6 sticks) -> 8 (7 sticks) is not a single-stick move.
      final v = PuzzleEngine.evaluate(
        _p(PuzzleType.matchstick, initial),
        initial,
        {
          'chars': ['3', '+', '3', '=', '8'],
        },
      );
      expect(v.solved, isFalse);
      expect(v.movesUsed, 1);
      expect(v.feedback, contains('matchstick'));
    });

    test('no change is not solved', () {
      final v = PuzzleEngine.evaluate(
        _p(PuzzleType.matchstick, initial),
        initial,
        {
          'chars': ['3', '+', '3', '=', '9'],
        },
      );
      expect(v.solved, isFalse);
      expect(v.movesUsed, 0);
    });
  });

  group('tile', () {
    final initial = {
      'size': 3,
      'options': 2,
      'grid': [0, 1, 0, 1, 1, 1, 0, 1, 0],
      'target': [0, 1, 0, 1, 0, 1, 0, 1, 0],
    };
    test('fixing the single wrong tile solves', () {
      final v = PuzzleEngine.evaluate(_p(PuzzleType.tile, initial), initial, {
        'size': 3,
        'options': 2,
        'grid': [0, 1, 0, 1, 0, 1, 0, 1, 0],
        'target': [0, 1, 0, 1, 0, 1, 0, 1, 0],
      });
      expect(v.solved, isTrue);
      expect(v.movesUsed, 1);
    });

    test('changing a correct tile is not solved', () {
      final v = PuzzleEngine.evaluate(_p(PuzzleType.tile, initial), initial, {
        'size': 3,
        'options': 2,
        'grid': [1, 1, 0, 1, 1, 1, 0, 1, 0],
        'target': [0, 1, 0, 1, 0, 1, 0, 1, 0],
      });
      expect(v.solved, isFalse);
      expect(v.movesUsed, 1);
    });

    test('two changed tiles count as two moves', () {
      final v = PuzzleEngine.evaluate(_p(PuzzleType.tile, initial), initial, {
        'size': 3,
        'options': 2,
        'grid': [0, 1, 0, 1, 0, 0, 0, 1, 0],
        'target': [0, 1, 0, 1, 0, 1, 0, 1, 0],
      });
      expect(v.solved, isFalse);
      expect(v.movesUsed, 2);
    });
  });

  group('number', () {
    final initial = {
      'values': [3, 6, 9, 12, 14],
      'rule': 'ap',
      'target': [3, 6, 9, 12, 15],
    };
    test('restoring the progression solves', () {
      final v = PuzzleEngine.evaluate(_p(PuzzleType.number, initial), initial, {
        'values': [3, 6, 9, 12, 15],
        'rule': 'ap',
        'target': [3, 6, 9, 12, 15],
      });
      expect(v.solved, isTrue);
    });

    test('a different single change that breaks the rule fails', () {
      final v = PuzzleEngine.evaluate(_p(PuzzleType.number, initial), initial, {
        'values': [3, 6, 9, 12, 13],
        'rule': 'ap',
        'target': [3, 6, 9, 12, 15],
      });
      expect(v.solved, isFalse);
      expect(v.movesUsed, 1);
    });

    test('touching two numbers is two moves', () {
      final v = PuzzleEngine.evaluate(_p(PuzzleType.number, initial), initial, {
        'values': [3, 6, 9, 12, 15].map((e) => e).toList()..[0] = 4,
        'rule': 'ap',
        'target': [3, 6, 9, 12, 15],
      });
      // [4,6,9,12,15] differs in two spots from initial.
      expect(v.movesUsed, 2);
      expect(v.solved, isFalse);
    });
  });

  group('shape', () {
    Map<String, dynamic> state(List<int> cells) => {
      'cells': 9,
      'shapes': [
        for (var i = 0; i < cells.length; i++)
          {'id': i, 'kind': 'circle', 'cell': cells[i]},
      ],
      'target': {'0': 0, '1': 1, '2': 3, '3': 4},
    };
    final initial = state([0, 1, 3, 8]);

    test('moving the stray shape home solves', () {
      final v = PuzzleEngine.evaluate(
        _p(PuzzleType.shape, initial),
        initial,
        state([0, 1, 3, 4]),
      );
      expect(v.solved, isTrue);
      expect(v.movesUsed, 1);
    });

    test('moving a shape to the wrong cell fails', () {
      final v = PuzzleEngine.evaluate(
        _p(PuzzleType.shape, initial),
        initial,
        state([0, 1, 3, 7]),
      );
      expect(v.solved, isFalse);
      expect(v.movesUsed, 1);
    });

    test('moving two shapes fails the one-move rule', () {
      final v = PuzzleEngine.evaluate(
        _p(PuzzleType.shape, initial),
        initial,
        state([2, 1, 3, 4]),
      );
      expect(v.solved, isFalse);
      expect(v.movesUsed, 2);
    });
  });

  group('line', () {
    final points = [
      {'x': 0.25, 'y': 0.25},
      {'x': 0.75, 'y': 0.25},
      {'x': 0.25, 'y': 0.75},
      {'x': 0.75, 'y': 0.75},
    ];
    Map<String, dynamic> state(List<List<int>> segs) => {
      'points': points,
      'segments': segs,
      'goal': 'no_cross',
    };
    final initial = state([
      [0, 3],
      [2, 3],
      [1, 2],
    ]);

    test('uncrossing with one re-attachment solves', () {
      final v = PuzzleEngine.evaluate(
        _p(PuzzleType.line, initial),
        initial,
        state([
          [0, 1],
          [2, 3],
          [1, 2],
        ]),
      );
      expect(v.solved, isTrue);
      expect(v.movesUsed, 1);
    });

    test('still-crossed lines fail', () {
      final v = PuzzleEngine.evaluate(
        _p(PuzzleType.line, initial),
        initial,
        state([
          [0, 3],
          [0, 2],
          [1, 2],
        ]),
      );
      // [0,3] and [1,2] still cross at the center.
      expect(v.solved, isFalse);
      expect(v.movesUsed, 1);
    });

    test('re-attaching two lines is two moves', () {
      final v = PuzzleEngine.evaluate(
        _p(PuzzleType.line, initial),
        initial,
        state([
          [0, 1],
          [2, 1],
          [1, 2],
        ]),
      );
      expect(v.solved, isFalse);
      expect(v.movesUsed, 2);
    });
  });

  group('lateral', () {
    final initial = {
      'cells': 9,
      'shapes': [
        {'id': 0, 'kind': 'square', 'cell': 3},
        {'id': 1, 'kind': 'triangle', 'cell': 5},
        {'id': 2, 'kind': 'circle', 'cell': 0},
      ],
      'target': {'0': 3, '1': 5, '2': 4},
    };
    Map<String, dynamic> moved(int id, int cell) {
      final shapes = (initial['shapes'] as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
      for (final s in shapes) {
        if (s['id'] == id) s['cell'] = cell;
      }
      return {
        'cells': 9,
        'shapes': shapes,
        'target': {'0': 3, '1': 5, '2': 4},
      };
    }

    test('moving the locked piece solves', () {
      final v = PuzzleEngine.evaluate(
        _p(PuzzleType.lateral, initial, metadata: {'lockedId': 2}),
        initial,
        moved(2, 4),
      );
      expect(v.solved, isTrue);
    });

    test('moving an unlocked piece does not solve', () {
      final v = PuzzleEngine.evaluate(
        _p(PuzzleType.lateral, initial, metadata: {'lockedId': 2}),
        initial,
        moved(0, 4),
      );
      expect(v.solved, isFalse);
      expect(v.feedback, contains('obvious'));
    });
  });

  group('robustness', () {
    test('malformed state fails gracefully instead of throwing', () {
      final p = _p(PuzzleType.tile, {
        'size': 3,
        'options': 2,
        'grid': [0, 1],
        'target': [0, 1],
      });
      final v = PuzzleEngine.evaluate(p, p.initialState, {'bogus': true});
      expect(v.solved, isFalse);
    });
  });
}
