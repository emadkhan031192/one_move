import 'verdict.dart';

/// Line puzzles: re-attach exactly one line (change one of its endpoints)
/// so that no two lines cross. The goal is always evaluated geometrically —
/// any crossing-free one-line fix counts.
class LineValidator {
  const LineValidator._();

  static List<_Pt> _points(Map<String, dynamic> state) {
    return (state['points'] as List)
        .map((e) => _Pt((e['x'] as num).toDouble(), (e['y'] as num).toDouble()))
        .toList();
  }

  /// Segments as a set of 'min-max' endpoint keys (order-insensitive).
  static Set<String> _segKeys(Map<String, dynamic> state) {
    return (state['segments'] as List).map((e) {
      final l = List<int>.from(e as List);
      final p = l[0] <= l[1] ? l : [l[1], l[0]];
      return '${p[0]}-${p[1]}';
    }).toSet();
  }

  static MoveVerdict evaluate(
    Map<String, dynamic> initial,
    Map<String, dynamic> current, {
    int attempt = 1,
  }) {
    final aKeys = _segKeys(initial);
    final bKeys = _segKeys(current);
    final points = _points(current);

    if (aKeys.length != bKeys.length) {
      return const MoveVerdict(
        solved: false,
        movesUsed: 99,
        feedback: 'Lines can only be re-attached, not added or removed.',
      );
    }

    final removed = aKeys.difference(bKeys).length;
    if (removed == 0) return noMoveVerdict;
    if (removed > 1) return multiMoveVerdict(removed);

    if (_hasCrossing(points, bKeys)) {
      return const MoveVerdict(
        solved: false,
        movesUsed: 1,
        feedback: 'Those lines still cross…',
      );
    }
    return const MoveVerdict(solved: true, movesUsed: 1, feedback: 'Solved!');
  }

  /// True if any two segments cross at an interior point.
  /// Exported for tests and generators.
  static bool hasCrossing(
    List<Map<String, double>> points,
    List<List<int>> segments,
  ) {
    final pts = points.map((e) => _Pt(e['x']!, e['y']!)).toList();
    final keys = segments.map((s) {
      final p = s[0] <= s[1] ? s : [s[1], s[0]];
      return '${p[0]}-${p[1]}';
    }).toSet();
    return _hasCrossing(pts, keys);
  }

  static bool _hasCrossing(List<_Pt> pts, Set<String> keys) {
    final segs = keys.map((k) {
      final parts = k.split('-');
      return [int.parse(parts[0]), int.parse(parts[1])];
    }).toList();
    for (var i = 0; i < segs.length; i++) {
      for (var j = i + 1; j < segs.length; j++) {
        final s1 = segs[i];
        final s2 = segs[j];
        // Shared endpoints are fine — only interior crossings count.
        if (s1[0] == s2[0] ||
            s1[0] == s2[1] ||
            s1[1] == s2[0] ||
            s1[1] == s2[1]) {
          continue;
        }
        if (_properCross(pts[s1[0]], pts[s1[1]], pts[s2[0]], pts[s2[1]])) {
          return true;
        }
      }
    }
    return false;
  }

  static double _orient(_Pt a, _Pt b, _Pt c) =>
      (b.x - a.x) * (c.y - a.y) - (b.y - a.y) * (c.x - a.x);

  static bool _properCross(_Pt p1, _Pt p2, _Pt p3, _Pt p4) {
    final o1 = _orient(p1, p2, p3);
    final o2 = _orient(p1, p2, p4);
    final o3 = _orient(p3, p4, p1);
    final o4 = _orient(p3, p4, p2);
    return (o1 * o2 < 0) && (o3 * o4 < 0);
  }
}

class _Pt {
  final double x;
  final double y;
  const _Pt(this.x, this.y);
}
