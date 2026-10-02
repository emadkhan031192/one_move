import 'verdict.dart';

/// Shape puzzles: relocate exactly one shape so every shape sits on its
/// target cell.
class ShapeValidator {
  const ShapeValidator._();

  /// Parses the target map stored as {'<id>': cell}.
  static Map<int, int> parseTarget(Map<String, dynamic> state) {
    final raw = state['target'] as Map;
    return raw.map((k, v) => MapEntry(int.parse(k.toString()), v as int));
  }

  static List<_Shape> _shapes(Map<String, dynamic> state) {
    return (state['shapes'] as List)
        .map((e) => _Shape(id: e['id'] as int, cell: e['cell'] as int))
        .toList();
  }

  static MoveVerdict evaluate(
    Map<String, dynamic> initial,
    Map<String, dynamic> current, {
    int attempt = 1,
    int? mustMoveId,
  }) {
    final a = _shapes(initial);
    final b = _shapes(current);
    final target = parseTarget(initial);

    if (a.length != b.length) {
      return const MoveVerdict(
        solved: false,
        movesUsed: 99,
        feedback: 'Something broke — hit retry and try again.',
      );
    }

    final moved = <int>[];
    for (var i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id) {
        return const MoveVerdict(
          solved: false,
          movesUsed: 99,
          feedback: 'Something broke — hit retry and try again.',
        );
      }
      if (a[i].cell != b[i].cell) moved.add(a[i].id);
    }

    if (moved.isEmpty) return noMoveVerdict;
    if (moved.length > 1) return multiMoveVerdict(moved.length);

    final movedId = moved.single;
    if (mustMoveId != null && movedId != mustMoveId) {
      return const MoveVerdict(
        solved: false,
        movesUsed: 1,
        feedback: 'The obvious pieces were not the answer…',
      );
    }

    for (final s in b) {
      if (target[s.id] != s.cell) {
        return MoveVerdict(
          solved: false,
          movesUsed: 1,
          feedback: wrongMoveFeedback(attempt),
        );
      }
    }
    return const MoveVerdict(solved: true, movesUsed: 1, feedback: 'Solved!');
  }
}

class _Shape {
  final int id;
  final int cell;
  const _Shape({required this.id, required this.cell});
}
