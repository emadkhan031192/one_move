import 'verdict.dart';

/// Number-logic puzzles: change exactly one number so the whole sequence
/// satisfies its hidden rule. Validation checks the *rule*, not a stored
/// answer, so any genuinely valid one-move fix is accepted.
class NumberValidator {
  const NumberValidator._();

  static MoveVerdict evaluate(
    Map<String, dynamic> initial,
    Map<String, dynamic> current, {
    int attempt = 1,
  }) {
    final a = List<int>.from(initial['values'] as List);
    final b = List<int>.from(current['values'] as List);
    final rule = initial['rule'] as String;

    if (a.length != b.length) {
      return const MoveVerdict(
        solved: false,
        movesUsed: 99,
        feedback: 'Something broke — hit retry and try again.',
      );
    }

    var diffs = 0;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) diffs++;
    }

    if (diffs == 0) return noMoveVerdict;
    if (diffs > 1) return multiMoveVerdict(diffs);

    if (satisfiesRule(b, rule)) {
      return const MoveVerdict(solved: true, movesUsed: 1, feedback: 'Solved!');
    }
    return MoveVerdict(
      solved: false,
      movesUsed: 1,
      feedback: wrongMoveFeedback(attempt),
    );
  }

  /// Supported rules: 'ap', 'doubling', 'fib', 'squares', 'alt'.
  static bool satisfiesRule(List<int> v, String rule) {
    if (v.length < 3) return false;
    switch (rule) {
      case 'ap':
        final d = v[1] - v[0];
        for (var i = 2; i < v.length; i++) {
          if (v[i] - v[i - 1] != d) return false;
        }
        return true;
      case 'doubling':
        for (var i = 1; i < v.length; i++) {
          if (v[i] != 2 * v[i - 1]) return false;
        }
        return true;
      case 'fib':
        for (var i = 2; i < v.length; i++) {
          if (v[i] != v[i - 1] + v[i - 2]) return false;
        }
        return true;
      case 'squares':
        // v[i] == (s + i)^2 for some integer s >= 0.
        final s = _intSqrt(v[0]);
        if (s == null) return false;
        for (var i = 0; i < v.length; i++) {
          if (v[i] != (s + i) * (s + i)) return false;
        }
        return true;
      case 'alt':
        // Two interleaved arithmetic progressions sharing one difference.
        if (v.length < 4) return false;
        final d = v[2] - v[0];
        if (v[3] - v[1] != d) return false;
        for (var i = 2; i < v.length; i++) {
          if (v[i] - v[i - 2] != d) return false;
        }
        return true;
      default:
        return false;
    }
  }

  static int? _intSqrt(int n) {
    if (n < 0) return null;
    var s = 0;
    while (s * s < n) {
      s++;
    }
    return s * s == n ? s : null;
  }

  /// Human-readable name for a rule id (used in explanations).
  static String ruleName(String rule) {
    switch (rule) {
      case 'ap':
        return 'an arithmetic progression';
      case 'doubling':
        return 'a doubling sequence';
      case 'fib':
        return 'a Fibonacci-style sequence';
      case 'squares':
        return 'consecutive squares';
      case 'alt':
        return 'two interleaved sequences';
      default:
        return 'a pattern';
    }
  }
}
