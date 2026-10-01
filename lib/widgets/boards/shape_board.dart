import 'package:flutter/material.dart';

/// Shape arrangement board (also used for lateral puzzles). Tap a shape to
/// select it, then tap an empty cell to move it there. Exactly one
/// relocation is the "one move".
class ShapeBoard extends StatefulWidget {
  final Map<String, dynamic> state;
  final ValueChanged<Map<String, dynamic>> onChanged;
  final bool lateral;

  const ShapeBoard({
    super.key,
    required this.state,
    required this.onChanged,
    this.lateral = false,
  });

  @override
  State<ShapeBoard> createState() => _ShapeBoardState();
}

class _ShapeBoardState extends State<ShapeBoard> {
  int? _selectedId;

  List<Map<String, dynamic>> _shapes() {
    return (widget.state['shapes'] as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  int? _lockedId() {
    if (!widget.lateral) return null;
    final v = widget.state['lockedId'];
    return v is int ? v : null;
  }

  @override
  Widget build(BuildContext context) {
    final shapes = _shapes();
    final lockedId = _lockedId();
    final scheme = Theme.of(context).colorScheme;
    final byCell = {for (final s in shapes) s['cell'] as int: s};

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: 9,
      itemBuilder: (context, cell) {
        final shape = byCell[cell];
        final selected = shape != null && shape['id'] as int == _selectedId;
        return GestureDetector(
          onTap: () => _onCellTap(cell, shape),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              color: selected
                  ? scheme.primaryContainer
                  : scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selected ? scheme.primary : scheme.outline,
                width: selected ? 2.5 : 1,
              ),
            ),
            child: shape == null
                ? null
                : Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                        size: const Size(48, 48),
                        painter: _ShapePainter(
                          kind: shape['kind'] as String,
                          color: scheme.primary,
                        ),
                      ),
                      if (lockedId != null && shape['id'] as int == lockedId)
                        const Positioned(
                          right: 6,
                          top: 6,
                          child: Icon(Icons.lock_outline, size: 16),
                        ),
                    ],
                  ),
          ),
        );
      },
    );
  }

  void _onCellTap(int cell, Map<String, dynamic>? shape) {
    if (_selectedId == null) {
      if (shape != null) {
        setState(() => _selectedId = shape['id'] as int);
      }
      return;
    }
    if (shape != null) {
      final tappedId = shape['id'] as int;
      setState(() => _selectedId = tappedId == _selectedId ? null : tappedId);
      return;
    }
    // Empty cell: relocate the selected shape.
    final shapes = _shapes();
    for (final s in shapes) {
      if (s['id'] as int == _selectedId) s['cell'] = cell;
    }
    final next = Map<String, dynamic>.from(widget.state);
    next['shapes'] = shapes;
    setState(() => _selectedId = null);
    widget.onChanged(next);
  }
}

class _ShapePainter extends CustomPainter {
  final String kind;
  final Color color;

  const _ShapePainter({required this.kind, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 - 4;
    final path = Path();
    switch (kind) {
      case 'square':
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: c, width: r * 1.7, height: r * 1.7),
            const Radius.circular(8),
          ),
          paint,
        );
        break;
      case 'triangle':
        path.moveTo(c.dx, c.dy - r);
        path.lineTo(c.dx + r, c.dy + r * 0.9);
        path.lineTo(c.dx - r, c.dy + r * 0.9);
        path.close();
        canvas.drawPath(path, paint);
        break;
      default: // circle
        canvas.drawCircle(c, r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ShapePainter oldDelegate) =>
      oldDelegate.kind != kind || oldDelegate.color != color;
}
