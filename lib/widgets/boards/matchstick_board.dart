import 'package:flutter/material.dart';

import '../../puzzle_engine/validators/matchstick_validator.dart';

/// Renders a matchstick equation. Tap a digit to select it, then tap one of
/// the offered alternative forms (all reachable by moving a single stick).
class MatchstickBoard extends StatefulWidget {
  final Map<String, dynamic> state;
  final ValueChanged<Map<String, dynamic>> onChanged;

  const MatchstickBoard({
    super.key,
    required this.state,
    required this.onChanged,
  });

  @override
  State<MatchstickBoard> createState() => _MatchstickBoardState();
}

class _MatchstickBoardState extends State<MatchstickBoard> {
  int? _selected;

  @override
  Widget build(BuildContext context) {
    final chars = List<String>.from(widget.state['chars'] as List);
    final scheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 6,
          runSpacing: 8,
          children: [
            for (var i = 0; i < chars.length; i++)
              _charBox(context, chars, i, scheme),
          ],
        ),
        const SizedBox(height: 22),
        if (_selected != null)
          _candidates(context, chars, scheme)
        else
          Text(
            'Tap a digit to move one of its matchsticks.',
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: scheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
      ],
    );
  }

  Widget _charBox(
    BuildContext context,
    List<String> chars,
    int i,
    ColorScheme scheme,
  ) {
    final ch = chars[i];
    final movable = MatchstickValidator.alternativesFor(ch).isNotEmpty;
    final selected = _selected == i;
    return GestureDetector(
      onTap: movable
          ? () => setState(() => _selected = selected ? null : i)
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 52,
        height: 72,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected
              ? scheme.primaryContainer
              : scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? scheme.primary : scheme.outline,
            width: selected ? 2.5 : 1,
          ),
        ),
        child: Text(
          ch,
          style: TextStyle(
            fontSize: 38,
            fontWeight: FontWeight.w800,
            color: movable ? scheme.onSurface : scheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  Widget _candidates(
    BuildContext context,
    List<String> chars,
    ColorScheme scheme,
  ) {
    final i = _selected!;
    final current = chars[i];
    final options = [current, ...MatchstickValidator.alternativesFor(current)];
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Move one stick in "$current" to make…',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 10),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 10,
          children: [
            for (final opt in options)
              GestureDetector(
                onTap: () => _choose(i, chars, opt),
                child: Container(
                  width: 52,
                  height: 64,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: opt == current
                        ? scheme.surfaceContainerHighest
                        : scheme.primary,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    opt,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: opt == current
                          ? scheme.onSurfaceVariant
                          : scheme.onPrimary,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  void _choose(int i, List<String> chars, String choice) {
    setState(() => _selected = null);
    if (choice == chars[i]) return; // no change, no move
    final nextChars = List<String>.from(chars);
    nextChars[i] = choice;
    final next = Map<String, dynamic>.from(widget.state);
    next['chars'] = nextChars;
    widget.onChanged(next);
  }
}
