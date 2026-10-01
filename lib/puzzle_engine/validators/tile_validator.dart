import '../../core/utils.dart';
import 'verdict.dart';

/// Tile puzzles: change exactly one tile so the grid matches the target
/// pattern hidden in the puzzle state.
class TileValidator {
  const TileValidator._();

  static MoveVerdict evaluate(
    Map<String, dynamic> initial,
    Map<String, dynamic> current, {
    int attempt = 1,
  }) {
    final a = List<int>.from(initial['grid'] as List);
    final b = List<int>.from(current['grid'] as List);
    final target = List<int>.from(initial['target'] as List);

    if (a.length != b.length || a.length != target.length) {
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

    if (listEquals(b, target)) {
      return const MoveVerdict(solved: true, movesUsed: 1, feedback: 'Solved!');
    }
    return MoveVerdict(
      solved: false,
      movesUsed: 1,
      feedback: wrongMoveFeedback(attempt),
    );
  }
}
