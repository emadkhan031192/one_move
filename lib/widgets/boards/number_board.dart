import 'package:flutter/material.dart';

/// Number sequence board. Tap a number to select it, then adjust with
/// + / −. The engine counts how many positions differ from the initial
/// state, so fiddling with two numbers is correctly judged as two moves.
class NumberBoard extends StatefulWidget {
  final Map<String, dynamic> state;
  final ValueChanged<Map<String, dynamic>> onChanged;

  const NumberBoard({super.key, required this.state, required this.onChanged});

  @override
  State<NumberBoard> createState() => _NumberBoardState();
}

class _NumberBoardState extends State<NumberBoard> {
  int? _selected;

  @override
  Widget build(BuildContext context) {
    final values = List<int>.from(widget.state['values'] as List);
    final scheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            for (var i = 0; i < values.length; i++)
              GestureDetector(
                onTap: () =>
                    setState(() => _selected = _selected == i ? null : i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 62,
                  height: 62,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _selected == i
                        ? scheme.primaryContainer
                        : scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _selected == i ? scheme.primary : scheme.outline,
                      width: _selected == i ? 2.5 : 1,
                    ),
                  ),
                  child: Text(
                    '${values[i]}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: scheme.onSurface,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _stepper(context, scheme, Icons.remove, -1),
            const SizedBox(width: 16),
            Text(
              _selected == null
                  ? 'Tap a number first.'
                  : 'Adjusting #${_selected! + 1}',
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(width: 16),
            _stepper(context, scheme, Icons.add, 1),
          ],
        ),
      ],
    );
  }

  Widget _stepper(
    BuildContext context,
    ColorScheme scheme,
    IconData icon,
    int delta,
  ) {
    return GestureDetector(
      onTap: _selected == null ? null : () => _adjust(delta),
      child: Opacity(
        opacity: _selected == null ? 0.35 : 1,
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: scheme.primary,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Icon(icon, color: scheme.onPrimary, size: 28),
        ),
      ),
    );
  }

  void _adjust(int delta) {
    final sel = _selected;
    if (sel == null) return;
    final values = List<int>.from(widget.state['values'] as List);
    final nv = (values[sel] + delta).clamp(0, 99);
    if (nv == values[sel]) return;
    values[sel] = nv;
    final next = Map<String, dynamic>.from(widget.state);
    next['values'] = values;
    widget.onChanged(next);
  }
}
