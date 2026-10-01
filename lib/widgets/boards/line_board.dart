import 'package:flutter/material.dart';

/// Line puzzle board. Tap a line to select it, then tap the dot its end
/// should snap to. The nearest endpoint of the selected line moves.
class LineBoard extends StatefulWidget {
  final Map<String, dynamic> state;
  final ValueChanged<Map<String, dynamic>> onChanged;

  const LineBoard({super.key, required this.state, required this.onChanged});

  @override
  State<LineBoard> createState() => _LineBoardState();
}

class _LineBoardState extends State<LineBoard> {
  int? _selectedSeg;

  List<Offset> _points() => (widget.state['points'] as List)
      .map(
        (e) => Offset((e['x'] as num).toDouble(), (e['y'] as num).toDouble()),
      )
      .toList();

  List<List<int>> _segments() => (widget.state['segments'] as List)
      .map((e) => List<int>.from(e as List))
      .toList();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: (d) => _onTapDown(d, constraints.biggest),
                child: CustomPaint(
                  painter: _LinePainter(
                    points: _points(),
                    segments: _segments(),
                    selected: _selectedSeg,
                    lineColor: scheme.onSurfaceVariant,
                    accent: scheme.primary,
                    dotFill: scheme.surface,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Text(
          _selectedSeg == null
              ? 'Tap a line, then tap a dot.'
              : 'Now tap the dot this line should snap to.',
          style: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(color: scheme.onSurfaceVariant),
        ),
      ],
    );
  }

  void _onTapDown(TapDownDetails details, Size size) {
    final w = size.width;
    if (w <= 0) return;
    final tap = Offset(
      details.localPosition.dx / w,
      details.localPosition.dy / w,
    );
    final points = _points();
    final segments = _segments();

    int nearestPoint = -1;
    var bestPointDist = double.infinity;
    for (var i = 0; i < points.length; i++) {
      final d = (points[i] - tap).distance;
      if (d < bestPointDist) {
        bestPointDist = d;
        nearestPoint = i;
      }
    }

    const dotHit = 0.10;
    final sel = _selectedSeg;

    if (sel != null && bestPointDist <= dotHit) {
      // Move the selected segment's nearest endpoint to the tapped dot.
      final seg = segments[sel];
      final d0 = (points[seg[0]] - points[nearestPoint]).distance;
      final d1 = (points[seg[1]] - points[nearestPoint]).distance;
      final moveEnd = d0 <= d1 ? 0 : 1;
      if (seg[moveEnd] != nearestPoint) {
        seg[moveEnd] = nearestPoint;
        final next = Map<String, dynamic>.from(widget.state);
        next['segments'] = segments;
        setState(() => _selectedSeg = null);
        widget.onChanged(next);
      } else {
        setState(() => _selectedSeg = null);
      }
      return;
    }

    if (bestPointDist <= dotHit) {
      // Tapped a bare dot with nothing selected: clear selection.
      setState(() => _selectedSeg = null);
      return;
    }

    // Otherwise pick the nearest segment within a threshold.
    var bestSeg = -1;
    var bestSegDist = double.infinity;
    for (var i = 0; i < segments.length; i++) {
      final a = points[segments[i][0]];
      final b = points[segments[i][1]];
      final d = _distToSegment(tap, a, b);
      if (d < bestSegDist) {
        bestSegDist = d;
        bestSeg = i;
      }
    }
    if (bestSeg >= 0 && bestSegDist <= 0.07) {
      setState(() => _selectedSeg = _selectedSeg == bestSeg ? null : bestSeg);
    } else {
      setState(() => _selectedSeg = null);
    }
  }

  double _distToSegment(Offset p, Offset a, Offset b) {
    final ab = b - a;
    final len2 = ab.distanceSquared;
    if (len2 == 0) return (p - a).distance;
    var t = ((p - a).dx * ab.dx + (p - a).dy * ab.dy) / len2;
    t = t.clamp(0.0, 1.0);
    final proj = a + ab * t;
    return (p - proj).distance;
  }
}

class _LinePainter extends CustomPainter {
  final List<Offset> points;
  final List<List<int>> segments;
  final int? selected;
  final Color lineColor;
  final Color accent;
  final Color dotFill;

  const _LinePainter({
    required this.points,
    required this.segments,
    required this.selected,
    required this.lineColor,
    required this.accent,
    required this.dotFill,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    Offset px(Offset p) => Offset(p.dx * w, p.dy * w);

    for (var i = 0; i < segments.length; i++) {
      final a = px(points[segments[i][0]]);
      final b = px(points[segments[i][1]]);
      final isSel = selected == i;
      canvas.drawLine(
        a,
        b,
        Paint()
          ..color = isSel ? accent : lineColor
          ..strokeWidth = isSel ? 9 : 6
          ..strokeCap = StrokeCap.round,
      );
    }

    for (final p in points) {
      final c = px(p);
      canvas.drawCircle(c, 15, Paint()..color = dotFill);
      canvas.drawCircle(
        c,
        15,
        Paint()
          ..color = accent
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
      canvas.drawCircle(c, 5, Paint()..color = accent);
    }
  }

  @override
  bool shouldRepaint(covariant _LinePainter old) {
    if (old.selected != selected) return true;
    if (old.segments.length != segments.length) return true;
    for (var i = 0; i < segments.length; i++) {
      if (old.segments[i][0] != segments[i][0] ||
          old.segments[i][1] != segments[i][1]) {
        return true;
      }
    }
    return false;
  }
}
