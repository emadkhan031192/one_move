import 'verdict.dart';

/// Matchstick puzzles: the equation is a list of characters. A legal move
/// relocates exactly one matchstick *within* a single character, so the
/// changed character must keep the same stick count and the resulting
/// equation must be mathematically true.
class MatchstickValidator {
  const MatchstickValidator._();

  static const Map<String, int> stickCounts = {
    '0': 6,
    '1': 2,
    '2': 5,
    '3': 5,
    '4': 4,
    '5': 5,
    '6': 6,
    '7': 3,
    '8': 7,
    '9': 6,
    '+': 2,
    '-': 1,
    '=': 2,
  };

  /// Digits that can be produced by moving one stick inside [digit].
  static List<String> alternativesFor(String digit) {
    final count = stickCounts[digit];
    if (count == null) return const [];
    return stickCounts.entries
        .where(
          (e) =>
              e.value == count &&
              e.key != digit &&
              RegExp(r'^\d$').hasMatch(e.key),
        )
        .map((e) => e.key)
        .toList();
  }

  static MoveVerdict evaluate(
    Map<String, dynamic> initial,
    Map<String, dynamic> current, {
    int attempt = 1,
  }) {
    final a = List<String>.from(initial['chars'] as List);
    final b = List<String>.from(current['chars'] as List);

    if (a.length != b.length) {
      return const MoveVerdict(
        solved: false,
        movesUsed: 99,
        feedback: 'Something broke — hit retry and try again.',
      );
    }

    final diffs = <int>[];
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) diffs.add(i);
    }

    if (diffs.isEmpty) return noMoveVerdict;
    if (diffs.length > 1) return multiMoveVerdict(diffs.length);

    final i = diffs.single;
    final before = stickCounts[a[i]] ?? -1;
    final after = stickCounts[b[i]] ?? -1;
    if (before < 0 || before != after) {
      return const MoveVerdict(
        solved: false,
        movesUsed: 1,
        feedback:
            'A real move shifts exactly one matchstick — '
            'the stick count has to balance.',
      );
    }

    if (equationTrue(b.join())) {
      return const MoveVerdict(solved: true, movesUsed: 1, feedback: 'Solved!');
    }
    return MoveVerdict(
      solved: false,
      movesUsed: 1,
      feedback: wrongMoveFeedback(attempt),
    );
  }

  /// True when [equation] like "12+7=19" is mathematically correct.
  /// Supports multi-digit integers and + / -.
  static bool equationTrue(String equation) {
    final m = RegExp(r'^(\d+)([+-])(\d+)=(\d+)$').firstMatch(equation);
    if (m == null) return false;
    final x = int.parse(m.group(1)!);
    final y = int.parse(m.group(3)!);
    final z = int.parse(m.group(4)!);
    final result = m.group(2) == '+' ? x + y : x - y;
    return result == z;
  }
}
