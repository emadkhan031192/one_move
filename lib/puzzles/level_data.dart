import 'dart:math';

import '../core/constants.dart';
import '../models/puzzle.dart';
import '../puzzle_engine/validators/line_validator.dart';
import '../puzzle_engine/validators/matchstick_validator.dart';
import '../puzzle_engine/validators/number_validator.dart';

// ---------------------------------------------------------------------------
// Level data: 200 campaign levels + 60 daily puzzles.
//
// Every puzzle is produced by first constructing a SOLVED state and then
// applying the inverse of exactly one legal move. Solvability is therefore
// guaranteed by construction, and each puzzle stores its solved state in
// metadata['solvedState'] so tests can prove it independently.
// Generation is fully deterministic (fixed seeds).
// ---------------------------------------------------------------------------

/// Builds the full 200-level campaign. Same output on every run.
List<Puzzle> buildAllLevels() {
  final levels = <Puzzle>[];
  levels.addAll(_tutorialLevels());
  final rng = Random(20260908);
  var id = 11;

  // 11-20: tutorial top-up.
  for (var i = 0; i < 5; i++) {
    levels.add(_genMatchstick(rng, id++, Difficulty.tutorial));
  }
  for (var i = 0; i < 5; i++) {
    levels.add(_genTile(rng, id++, Difficulty.tutorial));
  }
  // 21-50: easy.
  for (var i = 0; i < 10; i++) {
    levels.add(_genMatchstick(rng, id++, Difficulty.easy));
  }
  for (var i = 0; i < 12; i++) {
    levels.add(_genTile(rng, id++, Difficulty.easy));
  }
  for (var i = 0; i < 8; i++) {
    levels.add(_genNumber(rng, id++, Difficulty.easy));
  }
  // 51-100: medium.
  for (var i = 0; i < 10; i++) {
    levels.add(_genMatchstick(rng, id++, Difficulty.medium));
  }
  for (var i = 0; i < 14; i++) {
    levels.add(_genTile(rng, id++, Difficulty.medium));
  }
  for (var i = 0; i < 12; i++) {
    levels.add(_genNumber(rng, id++, Difficulty.medium));
  }
  for (var i = 0; i < 14; i++) {
    levels.add(_genShape(rng, id++, Difficulty.medium));
  }
  // 101-150: hard.
  for (var i = 0; i < 8; i++) {
    levels.add(_genMatchstick(rng, id++, Difficulty.hard));
  }
  for (var i = 0; i < 14; i++) {
    levels.add(_genShape(rng, id++, Difficulty.hard));
  }
  for (var i = 0; i < 14; i++) {
    levels.add(_genLine(rng, id++, Difficulty.hard));
  }
  for (var i = 0; i < 14; i++) {
    levels.add(_genNumber(rng, id++, Difficulty.hard));
  }
  // 151-180: very hard.
  for (var i = 0; i < 8; i++) {
    levels.add(_genLine(rng, id++, Difficulty.veryHard));
  }
  for (var i = 0; i < 8; i++) {
    levels.add(_genLateral(rng, id++, Difficulty.veryHard));
  }
  for (var i = 0; i < 6; i++) {
    levels.add(_genMatchstick(rng, id++, Difficulty.veryHard));
  }
  for (var i = 0; i < 8; i++) {
    levels.add(_genShape(rng, id++, Difficulty.veryHard));
  }
  // 181-200: expert.
  for (var i = 0; i < 6; i++) {
    levels.add(_genLateral(rng, id++, Difficulty.expert));
  }
  for (var i = 0; i < 4; i++) {
    levels.add(_genMatchstick(rng, id++, Difficulty.expert));
  }
  for (var i = 0; i < 4; i++) {
    levels.add(_genLine(rng, id++, Difficulty.expert));
  }
  for (var i = 0; i < 3; i++) {
    levels.add(_genNumber(rng, id++, Difficulty.expert));
  }
  for (var i = 0; i < 3; i++) {
    levels.add(_genShape(rng, id++, Difficulty.expert));
  }

  assert(
    levels.length == AppConstants.totalLevels,
    'Expected 200 levels, got ${levels.length}',
  );
  return levels;
}

/// Builds the deterministic daily-puzzle pool (ids 1001+).
List<Puzzle> buildDailyPool() {
  final rng = Random(424242);
  final pool = <Puzzle>[];
  final gens = <Puzzle Function(Random, int)>[
    (r, id) => _genMatchstick(r, id, Difficulty.medium),
    (r, id) => _genTile(r, id, Difficulty.medium),
    (r, id) => _genNumber(r, id, Difficulty.medium),
    (r, id) => _genShape(r, id, Difficulty.medium),
    (r, id) => _genLine(r, id, Difficulty.medium),
  ];
  for (var i = 0; i < AppConstants.dailyPoolSize; i++) {
    pool.add(gens[i % gens.length](rng, AppConstants.dailyIdBase + i));
  }
  return pool;
}

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

bool _isDigit(String ch) => RegExp(r'^\d$').hasMatch(ch);

String _ordinal(int n) {
  if (n >= 11 && n <= 13) return '${n}th';
  switch (n % 10) {
    case 1:
      return '${n}st';
    case 2:
      return '${n}nd';
    case 3:
      return '${n}rd';
    default:
      return '${n}th';
  }
}

String _pick(Random rng, List<String> items) =>
    items[rng.nextInt(items.length)];

/// True when a multi-digit number token starts with '0'.
bool _hasLeadingZero(List<String> chars) {
  final token = StringBuffer();
  void flush() {
    if (token.length > 1 && token.toString().startsWith('0')) {
      throw const _LeadingZero();
    }
    token.clear();
  }

  try {
    for (final ch in chars) {
      if (_isDigit(ch)) {
        token.write(ch);
      } else {
        flush();
      }
    }
    flush();
  } on _LeadingZero {
    return true;
  }
  return false;
}

class _LeadingZero {
  const _LeadingZero();
}

// ---------------------------------------------------------------------------
// Levels 1-10: hand-authored tutorial arc.
// ---------------------------------------------------------------------------

List<Puzzle> _tutorialLevels() {
  Map<String, dynamic> solvedChars(List<String> chars) => {
    'chars': List<String>.from(chars),
  };
  return [
    Puzzle(
      id: 1,
      type: PuzzleType.matchstick,
      difficulty: Difficulty.tutorial,
      title: 'First Move',
      instruction:
          'Move ONE matchstick to make the equation true. '
          'Tap a digit, then pick its new form.',
      initialState: {
        'chars': ['3', '+', '3', '=', '9'],
      },
      hints: const [
        'Look at the last digit.',
        'The 9 is built from 6 matchsticks — and so is the 6.',
        'Tap the 9, then choose 6.',
      ],
      explanation:
          '3 + 3 = 6. One stick moved inside the 9 turned it into '
          'a 6. That is the whole game: one move, correctly placed.',
      metadata: {
        'solvedState': solvedChars(['3', '+', '3', '=', '6']),
      },
    ),
    Puzzle(
      id: 2,
      type: PuzzleType.matchstick,
      difficulty: Difficulty.tutorial,
      title: 'Look Left',
      instruction:
          'Move ONE matchstick to make the equation true. '
          'Tap a digit, then pick its new form.',
      initialState: {
        'chars': ['0', '+', '1', '=', '7'],
      },
      hints: const [
        'The first digit looks wrong.',
        '0 and 6 are both made of 6 matchsticks.',
        'Tap the 0, then choose 6.',
      ],
      explanation:
          '6 + 1 = 7. The fix was at the very start — always scan '
          'the whole equation.',
      metadata: {
        'solvedState': solvedChars(['6', '+', '1', '=', '7']),
      },
    ),
    Puzzle(
      id: 3,
      type: PuzzleType.tile,
      difficulty: Difficulty.tutorial,
      title: 'Rhythm',
      instruction:
          'Change exactly ONE tile to complete the pattern. '
          'Tap a tile to cycle it.',
      initialState: {
        'size': 3,
        'options': 2,
        'grid': [0, 1, 0, 1, 1, 1, 0, 1, 0],
        'target': [0, 1, 0, 1, 0, 1, 0, 1, 0],
      },
      hints: const [
        'One tile breaks the checkerboard.',
        'Look at the very center.',
        'Tap the center tile.',
      ],
      explanation:
          'A checkerboard alternates every tile. The center tile '
          'broke the rhythm.',
      metadata: {
        'solvedState': {
          'size': 3,
          'options': 2,
          'grid': [0, 1, 0, 1, 0, 1, 0, 1, 0],
          'target': [0, 1, 0, 1, 0, 1, 0, 1, 0],
        },
      },
    ),
    Puzzle(
      id: 4,
      type: PuzzleType.tile,
      difficulty: Difficulty.tutorial,
      title: 'The Obvious Trap',
      instruction:
          'Change exactly ONE tile to complete the pattern. '
          'Tap a tile to cycle it.',
      initialState: {
        'size': 3,
        'options': 2,
        'grid': [1, 0, 0, 0, 1, 0, 0, 0, 0],
        'target': [0, 0, 0, 0, 1, 0, 0, 0, 0],
      },
      hints: const [
        'Only one tile is wrong — but which one?',
        'The pattern is "a single dot in the middle".',
        'Tap the top-left corner tile.',
      ],
      explanation:
          'You wanted to tap the obvious middle tile. The corner '
          'was the intruder. Question the obvious.',
      metadata: {
        'solvedState': {
          'size': 3,
          'options': 2,
          'grid': [0, 0, 0, 0, 1, 0, 0, 0, 0],
          'target': [0, 0, 0, 0, 1, 0, 0, 0, 0],
        },
      },
    ),
    Puzzle(
      id: 5,
      type: PuzzleType.shape,
      difficulty: Difficulty.tutorial,
      title: 'Come Home',
      instruction:
          'Move exactly ONE shape to complete the arrangement. '
          'Tap a shape, then tap its destination.',
      initialState: {
        'cells': 9,
        'shapes': [
          {'id': 0, 'kind': 'circle', 'cell': 0},
          {'id': 1, 'kind': 'circle', 'cell': 1},
          {'id': 2, 'kind': 'circle', 'cell': 3},
          {'id': 3, 'kind': 'circle', 'cell': 8},
        ],
        'target': {'0': 0, '1': 1, '2': 3, '3': 4},
      },
      hints: const [
        'Three circles form a corner — one wandered off.',
        'The block belongs in the top-left.',
        'Tap the bottom-right circle, then tap the empty cell beside the others.',
      ],
      explanation:
          'Four circles, one 2x2 block. The stray circle just '
          'needed to come home.',
      metadata: {
        'solvedState': {
          'cells': 9,
          'shapes': [
            {'id': 0, 'kind': 'circle', 'cell': 0},
            {'id': 1, 'kind': 'circle', 'cell': 1},
            {'id': 2, 'kind': 'circle', 'cell': 3},
            {'id': 3, 'kind': 'circle', 'cell': 4},
          ],
          'target': {'0': 0, '1': 1, '2': 3, '3': 4},
        },
      },
    ),
    Puzzle(
      id: 6,
      type: PuzzleType.lateral,
      difficulty: Difficulty.tutorial,
      title: 'Just A Badge',
      instruction: 'Complete the arrangement with ONE move.',
      initialState: {
        'cells': 9,
        'shapes': [
          {'id': 0, 'kind': 'triangle', 'cell': 0},
          {'id': 1, 'kind': 'circle', 'cell': 8},
        ],
        'target': {'0': 4, '1': 8},
      },
      hints: const [
        'One piece is out of place.',
        'The lock is just a badge. Trust your eyes.',
        'Tap the "locked" triangle, then tap the center cell.',
      ],
      explanation:
          'The lock was decoration. In ONE MOVE nothing is '
          'off-limits — question the assumption.',
      metadata: {
        'lockedId': 0,
        'solvedState': {
          'cells': 9,
          'shapes': [
            {'id': 0, 'kind': 'triangle', 'cell': 4},
            {'id': 1, 'kind': 'circle', 'cell': 8},
          ],
          'target': {'0': 4, '1': 8},
        },
      },
    ),
    Puzzle(
      id: 7,
      type: PuzzleType.number,
      difficulty: Difficulty.tutorial,
      title: 'Two Suspects',
      instruction:
          'Change exactly ONE number to fix the sequence. '
          'Tap a number to select it, then use + / −.',
      initialState: {
        'values': [3, 6, 9, 12, 14],
        'rule': 'ap',
        'target': [3, 6, 9, 12, 15],
      },
      hints: const [
        'Four numbers agree. One disagrees.',
        'It is an arithmetic progression: +3 each step.',
        'Change the last number to 15.',
      ],
      explanation:
          '3, 6, 9, 12… +3 each time. Only 14 → 15 keeps the rule. '
          'The other "wrong-looking" numbers were innocent.',
      metadata: {
        'solvedState': {
          'values': [3, 6, 9, 12, 15],
          'rule': 'ap',
          'target': [3, 6, 9, 12, 15],
        },
      },
    ),
    Puzzle(
      id: 8,
      type: PuzzleType.lateral,
      difficulty: Difficulty.tutorial,
      title: 'Again?',
      instruction: 'Complete the arrangement with ONE move.',
      initialState: {
        'cells': 9,
        'shapes': [
          {'id': 0, 'kind': 'square', 'cell': 3},
          {'id': 1, 'kind': 'triangle', 'cell': 5},
          {'id': 2, 'kind': 'circle', 'cell': 0},
        ],
        'target': {'0': 3, '1': 5, '2': 4},
      },
      hints: const [
        'The pattern wants a circle in the middle.',
        'Something "unmovable" is standing in the way.',
        'Move the locked circle to the center cell.',
      ],
      explanation:
          'The locked piece again. Locks are suggestions here — '
          'the circle belonged in the center.',
      metadata: {
        'lockedId': 2,
        'solvedState': {
          'cells': 9,
          'shapes': [
            {'id': 0, 'kind': 'square', 'cell': 3},
            {'id': 1, 'kind': 'triangle', 'cell': 5},
            {'id': 2, 'kind': 'circle', 'cell': 4},
          ],
          'target': {'0': 3, '1': 5, '2': 4},
        },
      },
    ),
    Puzzle(
      id: 9,
      type: PuzzleType.line,
      difficulty: Difficulty.tutorial,
      title: 'Uncross',
      instruction:
          'Uncross the lines with ONE move. Tap a line, then tap '
          'the dot its end should snap to.',
      initialState: {
        'points': [
          {'x': 0.25, 'y': 0.25},
          {'x': 0.75, 'y': 0.25},
          {'x': 0.25, 'y': 0.75},
          {'x': 0.75, 'y': 0.75},
        ],
        'segments': [
          [0, 3],
          [2, 3],
          [1, 2],
        ],
        'goal': 'no_cross',
      },
      hints: const [
        'Two lines cross in the middle.',
        'Tap the diagonal line first.',
        'Tap the line from top-left to bottom-right, then tap the top-right dot.',
      ],
      explanation:
          'One line was reaching for the wrong corner. '
          'Re-attaching its end uncrossed everything.',
      metadata: {
        'solvedState': {
          'points': [
            {'x': 0.25, 'y': 0.25},
            {'x': 0.75, 'y': 0.25},
            {'x': 0.25, 'y': 0.75},
            {'x': 0.75, 'y': 0.75},
          ],
          'segments': [
            [0, 1],
            [2, 3],
            [1, 2],
          ],
          'goal': 'no_cross',
        },
      },
    ),
    Puzzle(
      id: 10,
      type: PuzzleType.matchstick,
      difficulty: Difficulty.tutorial,
      title: 'The First "OH!"',
      instruction:
          'Move ONE matchstick to make the equation true. '
          'Tap a digit, then pick its new form.',
      initialState: {
        'chars': ['6', '-', '5', '=', '4'],
      },
      hints: const [
        'You keep staring at the answer. Stop.',
        'The mistake is the very first digit.',
        'Tap the 6, then choose 9: 9 − 5 = 4.',
      ],
      explanation:
          '9 − 5 = 4. The move was the first thing on the board — '
          'the last place you looked.',
      metadata: {
        'solvedState': solvedChars(['9', '-', '5', '=', '4']),
      },
    ),
  ];
}

// ---------------------------------------------------------------------------
// Matchstick generator
// ---------------------------------------------------------------------------

Puzzle _genMatchstick(Random rng, int id, Difficulty diff) {
  const titles = [
    'Sticky Situation',
    'One Stick Away',
    'Balancing Act',
    'Match Point',
    'False Equation',
    'The Moved Match',
    'Off By A Stick',
    'Think Sticks',
  ];
  const instruction =
      'Move ONE matchstick to make the equation true. '
      'Tap a digit, then pick its new form.';

  for (var attempt = 0; attempt < 80; attempt++) {
    final twoDigit = diff.index >= Difficulty.medium.index;
    final maxN = twoDigit ? 39 : 9;
    var a = 1 + rng.nextInt(maxN);
    var b = 1 + rng.nextInt(maxN);
    final plus = rng.nextBool();
    if (!plus && b > a) {
      final t = a;
      a = b;
      b = t;
    }
    final c = plus ? a + b : a - b;
    if (twoDigit && c > 99) continue;
    final op = plus ? '+' : '-';
    final correct = '$a$op$b=$c';
    final chars = correct.split('');

    final positions = <int>[];
    for (var i = 0; i < chars.length; i++) {
      if (_isDigit(chars[i]) &&
          MatchstickValidator.alternativesFor(chars[i]).isNotEmpty) {
        positions.add(i);
      }
    }
    if (positions.isEmpty) continue;
    final pos = positions[rng.nextInt(positions.length)];
    final alts = MatchstickValidator.alternativesFor(chars[pos]);
    final broken = List<String>.from(chars);
    broken[pos] = alts[rng.nextInt(alts.length)];
    if (_hasLeadingZero(broken)) continue;
    if (MatchstickValidator.equationTrue(broken.join())) continue;

    final brokenEq = broken.join();
    return Puzzle(
      id: id,
      type: PuzzleType.matchstick,
      difficulty: diff,
      title: _pick(rng, titles),
      instruction: instruction,
      initialState: {'chars': broken},
      hints: [
        'Look at the ${_ordinal(pos + 1)} character.',
        'One matchstick inside that digit is out of place.',
        'Tap the ${broken[pos]}, then choose ${chars[pos]}.',
      ],
      explanation:
          '$brokenEq is wrong. Moving one stick inside the '
          '${broken[pos]} turns it into ${chars[pos]}: $correct.',
      metadata: {
        'solvedState': {'chars': List<String>.from(chars)},
      },
    );
  }

  // Practically unreachable fallback — still a valid puzzle.
  return Puzzle(
    id: id,
    type: PuzzleType.matchstick,
    difficulty: diff,
    title: 'Sticky Situation',
    instruction: instruction,
    initialState: {
      'chars': ['3', '+', '3', '=', '9'],
    },
    hints: const [
      'Look at the last character.',
      'One matchstick inside that digit is out of place.',
      'Tap the 9, then choose 6.',
    ],
    explanation: '3 + 3 = 6.',
    metadata: {
      'solvedState': {
        'chars': ['3', '+', '3', '=', '6'],
      },
    },
  );
}

// ---------------------------------------------------------------------------
// Tile generator
// ---------------------------------------------------------------------------

Puzzle _genTile(Random rng, int id, Difficulty diff) {
  const titles = [
    'Odd One Out',
    'Pattern Breaker',
    'Almost Perfect',
    'The Wrong Tile',
    'See The Pattern',
  ];
  const instruction =
      'Change exactly ONE tile to complete the pattern. '
      'Tap a tile to cycle it.';
  const patternNames = {
    'checker': 'checkerboard',
    'border': 'border',
    'stripes': 'stripes',
    'cross': 'X',
  };

  final size = diff.index <= Difficulty.easy.index
      ? 3
      : diff == Difficulty.medium
      ? 4
      : 5;
  final options = diff.index >= Difficulty.hard.index
      ? 3 + rng.nextInt(2)
      : diff == Difficulty.medium
      ? 3
      : 2;
  final patternKeys = patternNames.keys.toList();

  final pattern = patternKeys[rng.nextInt(patternKeys.length)];
  final target = List<int>.generate(size * size, (i) {
    final r = i ~/ size;
    final c = i % size;
    switch (pattern) {
      case 'checker':
        return (r + c) % 2;
      case 'border':
        return (r == 0 || c == 0 || r == size - 1 || c == size - 1) ? 1 : 0;
      case 'stripes':
        return r % options;
      case 'cross':
        return (r == c || r + c == size - 1) ? 1 : 0;
      default:
        return 0;
    }
  });

  final pos = rng.nextInt(target.length);
  final newVal = (target[pos] + 1 + rng.nextInt(options - 1)) % options;
  final grid = List<int>.from(target);
  grid[pos] = newVal;
  final r = pos ~/ size;
  final c = pos % size;
  final name = patternNames[pattern]!;

  return Puzzle(
    id: id,
    type: PuzzleType.tile,
    difficulty: diff,
    title: _pick(rng, titles),
    instruction: instruction,
    initialState: {
      'size': size,
      'options': options,
      'grid': grid,
      'target': List<int>.from(target),
    },
    hints: [
      'Study the pattern — one tile breaks it.',
      'It is almost a perfect $name.',
      'Tap the tile at row ${r + 1}, column ${c + 1}.',
    ],
    explanation:
        'The pattern was a $name. The tile at row ${r + 1}, '
        'column ${c + 1} was the intruder.',
    metadata: {
      'solvedState': {
        'size': size,
        'options': options,
        'grid': List<int>.from(target),
        'target': List<int>.from(target),
      },
    },
  );
}

// ---------------------------------------------------------------------------
// Number generator
// ---------------------------------------------------------------------------

Puzzle _genNumber(Random rng, int id, Difficulty diff) {
  const titles = [
    'Broken Sequence',
    'One Number Off',
    'Find The Rule',
    'Sequence Breaker',
    'The Wrong Number',
  ];
  const instruction =
      'Change exactly ONE number to fix the sequence. '
      'Tap a number to select it, then use + / −.';

  final rules = diff == Difficulty.easy
      ? ['ap']
      : diff == Difficulty.medium
      ? ['ap', 'doubling']
      : ['ap', 'doubling', 'fib', 'squares', 'alt'];
  final len = diff == Difficulty.easy
      ? 4
      : diff == Difficulty.medium
      ? 5
      : 6;

  for (var attempt = 0; attempt < 80; attempt++) {
    final rule = rules[rng.nextInt(rules.length)];
    final seq = _numberSequence(rng, rule, len);
    if (seq == null) continue;
    final pos = rng.nextInt(len);
    var placed = false;
    final corrupted = List<int>.from(seq);
    for (var t = 0; t < 12 && !placed; t++) {
      final delta = (1 + rng.nextInt(3)) * (rng.nextBool() ? 1 : -1);
      final nv = seq[pos] + delta;
      if (nv < 0 || nv == seq[pos]) continue;
      corrupted[pos] = nv;
      if (!NumberValidator.satisfiesRule(corrupted, rule)) placed = true;
    }
    if (!placed) continue;

    final ruleName = NumberValidator.ruleName(rule);
    return Puzzle(
      id: id,
      type: PuzzleType.number,
      difficulty: diff,
      title: _pick(rng, titles),
      instruction: instruction,
      initialState: {
        'values': corrupted,
        'rule': rule,
        'target': List<int>.from(seq),
      },
      hints: [
        'Find the number that breaks the pattern.',
        'The sequence is $ruleName.',
        'Change the ${_ordinal(pos + 1)} number to ${seq[pos]}.',
      ],
      explanation:
          'The sequence was $ruleName: ${seq.join(', ')}. '
          'Only ${corrupted[pos]} → ${seq[pos]} restores it.',
      metadata: {
        'solvedState': {
          'values': List<int>.from(seq),
          'rule': rule,
          'target': List<int>.from(seq),
        },
      },
    );
  }

  return _tutorialLevels()[6].copyWithId(id);
}

List<int>? _numberSequence(Random rng, String rule, int len) {
  switch (rule) {
    case 'ap':
      final s = 1 + rng.nextInt(12);
      final d = 1 + rng.nextInt(9);
      return List<int>.generate(len, (i) => s + i * d);
    case 'doubling':
      final s = 1 + rng.nextInt(3);
      return List<int>.generate(len, (i) => s * (1 << i));
    case 'fib':
      final f1 = 1 + rng.nextInt(4);
      final f2 = f1 + 1 + rng.nextInt(4);
      final v = [f1, f2];
      for (var i = 2; i < len; i++) {
        v.add(v[i - 1] + v[i - 2]);
      }
      return v;
    case 'squares':
      final s = rng.nextInt(4);
      return List<int>.generate(len, (i) => (s + i) * (s + i));
    case 'alt':
      final s1 = 1 + rng.nextInt(9);
      final s2 = 1 + rng.nextInt(9);
      final d = 1 + rng.nextInt(6);
      return List<int>.generate(
        len,
        (i) => i.isEven ? s1 + (i ~/ 2) * d : s2 + (i ~/ 2) * d,
      );
    default:
      return null;
  }
}

// ---------------------------------------------------------------------------
// Shape + lateral generators
// ---------------------------------------------------------------------------

const _shapeKinds = ['circle', 'square', 'triangle'];

String _cellName(int cell) {
  final r = cell ~/ 3;
  final c = cell % 3;
  return 'row ${r + 1}, column ${c + 1}';
}

Puzzle _genShape(Random rng, int id, Difficulty diff) =>
    _genShapeOrLateral(rng, id, diff, PuzzleType.shape);

Puzzle _genLateral(Random rng, int id, Difficulty diff) =>
    _genShapeOrLateral(rng, id, diff, PuzzleType.lateral);

Puzzle _genShapeOrLateral(
  Random rng,
  int id,
  Difficulty diff,
  PuzzleType type,
) {
  final lateral = type == PuzzleType.lateral;
  final titles = lateral
      ? const [
          'Question Everything',
          'The Locked Piece',
          'Assumptions',
          'Not So Fast',
          'Look Closer',
        ]
      : const [
          'Out Of Place',
          'Shape Up',
          'The Missing Spot',
          'Arrangement',
          'Find Its Home',
        ];
  final instruction = lateral
      ? 'Complete the arrangement with ONE move.'
      : 'Move exactly ONE shape to complete the arrangement. '
            'Tap a shape, then tap its destination.';

  final count = diff.index <= Difficulty.easy.index
      ? 3
      : diff == Difficulty.medium
      ? 4
      : 5;
  // (name, cells)
  const themes = [
    ('row', [3, 4, 5]),
    ('column', [1, 4, 7]),
    ('diagonal', [0, 4, 8]),
    ('block', [0, 1, 3, 4]),
    ('corners', [0, 2, 6, 8]),
    ('plus', [1, 3, 4, 5, 7]),
  ];

  for (var attempt = 0; attempt < 60; attempt++) {
    final theme = themes[rng.nextInt(themes.length)];
    final themeName = theme.$1;
    final cells = theme.$2;
    if (cells.length != count) continue;

    final order = List<int>.generate(count, (i) => i)..shuffle(rng);
    final kindPool = List<String>.from(_shapeKinds)..shuffle(rng);
    final target = <int, int>{};
    final kinds = <int, String>{};
    for (var k = 0; k < count; k++) {
      final shapeId = order[k];
      target[shapeId] = cells[k];
      kinds[shapeId] = kindPool[k % kindPool.length];
    }

    final moveId = rng.nextInt(count);
    final occupied = Set<int>.from(cells);
    final empties = List<int>.generate(
      9,
      (i) => i,
    ).where((c) => !occupied.contains(c)).toList();
    if (empties.isEmpty) continue;
    final dest = empties[rng.nextInt(empties.length)];

    List<Map<String, dynamic>> buildShapes(Map<int, int> positions) {
      final list = <Map<String, dynamic>>[];
      for (var i = 0; i < count; i++) {
        list.add({'id': i, 'kind': kinds[i], 'cell': positions[i]});
      }
      return list;
    }

    final targetPositions = Map<int, int>.from(target);
    final initialPositions = Map<int, int>.from(target);
    initialPositions[moveId] = dest;
    final targetJson = target.map((k, v) => MapEntry(k.toString(), v));
    final kind = kinds[moveId]!;

    final solvedState = {
      'cells': 9,
      'shapes': buildShapes(targetPositions),
      'target': Map<String, int>.from(targetJson),
      if (lateral) 'lockedId': moveId,
    };

    return Puzzle(
      id: id,
      type: type,
      difficulty: diff,
      title: _pick(rng, titles),
      instruction: instruction,
      initialState: {
        'cells': 9,
        'shapes': buildShapes(initialPositions),
        'target': Map<String, int>.from(targetJson),
        if (lateral) 'lockedId': moveId,
      },
      hints: [
        'One shape is out of place.',
        lateral ? 'Do not trust the lock.' : 'Picture the finished $themeName.',
        lateral
            ? 'The "locked" $kind can move — send it to ${_cellName(target[moveId]!)}.'
            : 'The $kind belongs at ${_cellName(target[moveId]!)}.',
      ],
      explanation: lateral
          ? 'The lock was just a badge. The $kind belonged at '
                '${_cellName(target[moveId]!)} — questioning the assumption '
                'was the whole puzzle.'
          : 'One move: the $kind goes to ${_cellName(target[moveId]!)}, '
                'completing the $themeName.',
      metadata: {if (lateral) 'lockedId': moveId, 'solvedState': solvedState},
    );
  }

  // Unreachable-in-practice fallback.
  return _tutorialLevels()[4].copyWithId(id);
}

// ---------------------------------------------------------------------------
// Line generator
// ---------------------------------------------------------------------------

class _LineTemplate {
  final List<Map<String, double>> points;
  final List<List<int>> solved;
  final List<List<int>> initial;
  final String hint3;
  const _LineTemplate(this.points, this.solved, this.initial, this.hint3);
}

List<Map<String, double>> _pts(List<List<double>> coords) =>
    coords.map((c) => {'x': c[0], 'y': c[1]}).toList();

_LineTemplate _lineT1() => _LineTemplate(
  _pts([
    [0.25, 0.25],
    [0.75, 0.25],
    [0.25, 0.75],
    [0.75, 0.75],
  ]),
  [
    [0, 1],
    [2, 3],
    [1, 2],
  ],
  [
    [0, 3],
    [2, 3],
    [1, 2],
  ],
  'Tap the diagonal line, then tap the top-right dot.',
);

_LineTemplate _lineT2() => _LineTemplate(
  _pts([
    [0.25, 0.25],
    [0.75, 0.25],
    [0.25, 0.75],
    [0.75, 0.75],
  ]),
  [
    [0, 1],
    [2, 3],
    [0, 3],
  ],
  [
    [1, 2],
    [2, 3],
    [0, 3],
  ],
  'Tap the diagonal line, then tap the top-left dot.',
);

_LineTemplate _lineT3() => _LineTemplate(
  _pts([
    [0.25, 0.25],
    [0.75, 0.25],
    [0.25, 0.75],
    [0.75, 0.75],
    [0.5, 0.5],
  ]),
  [
    [0, 1],
    [1, 2],
    [4, 0],
  ],
  [
    [0, 3],
    [1, 2],
    [4, 0],
  ],
  'Tap the long diagonal, then tap the top-right dot.',
);

_LineTemplate _lineT4() => _LineTemplate(
  _pts([
    [0.2, 0.3],
    [0.8, 0.3],
    [0.2, 0.7],
    [0.8, 0.7],
    [0.5, 0.05],
    [0.5, 0.2],
  ]),
  [
    [0, 1],
    [2, 3],
    [1, 2],
    [4, 5],
  ],
  [
    [0, 3],
    [2, 3],
    [1, 2],
    [4, 5],
  ],
  'Tap the diagonal crossing the middle, then tap the top-right dot.',
);

Puzzle _genLine(Random rng, int id, Difficulty diff) {
  const titles = ['Crossed Lines', 'Untangle', 'One Line Fix', 'The Crossing'];
  const instruction =
      'Uncross the lines with ONE move. Tap a line, then tap '
      'the dot its end should snap to.';

  final templates = diff.index >= Difficulty.hard.index
      ? [_lineT3, _lineT4]
      : [_lineT1, _lineT2];

  for (var attempt = 0; attempt < 20; attempt++) {
    final t = templates[rng.nextInt(templates.length)]();
    // By construction one endpoint moved; verify the geometry contract.
    if (LineValidator.hasCrossing(t.points, t.solved)) continue;
    if (!LineValidator.hasCrossing(t.points, t.initial)) continue;

    Map<String, dynamic> stateOf(List<List<int>> segs) => {
      'points': t.points.map((p) => Map<String, double>.from(p)).toList(),
      'segments': segs.map((s) => List<int>.from(s)).toList(),
      'goal': 'no_cross',
    };

    return Puzzle(
      id: id,
      type: PuzzleType.line,
      difficulty: diff,
      title: _pick(rng, titles),
      instruction: instruction,
      initialState: stateOf(t.initial),
      hints: [
        'Two lines cross. Only one needs to move.',
        'Tap the crossing line, then tap the dot where its end belongs.',
        t.hint3,
      ],
      explanation:
          'One line was reaching for the wrong dot. Re-attaching '
          'its end uncrossed everything.',
      metadata: {'solvedState': stateOf(t.solved)},
    );
  }

  // Unreachable-in-practice fallback.
  return _tutorialLevels()[8].copyWithId(id);
}
