import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/puzzle.dart';

/// Celebrates a solved puzzle: particles-ish scale animation, the
/// explanation ("how it works"), and next steps including spoiler-free share.
class SuccessOverlay extends StatefulWidget {
  final Puzzle puzzle;
  final int attempts;
  final bool hasNext;
  final bool isDaily;
  final VoidCallback onNext;
  final VoidCallback onHome;

  const SuccessOverlay({
    super.key,
    required this.puzzle,
    required this.attempts,
    required this.hasNext,
    required this.onNext,
    required this.onHome,
    this.isDaily = false,
  });

  @override
  State<SuccessOverlay> createState() => _SuccessOverlayState();
}

class _SuccessOverlayState extends State<SuccessOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _scale = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ScaleTransition(
      scale: _scale,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 28),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_rounded,
                  size: 40,
                  color: scheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'SOLVED!',
                style: Theme.of(context).textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w900, letterSpacing: 1.2),
              ),
              const SizedBox(height: 8),
              Text(
                widget.isDaily
                    ? 'Daily Puzzle · ${widget.attempts} '
                          '${widget.attempts == 1 ? 'attempt' : 'attempts'}'
                    : 'Level ${widget.puzzle.id} · ${widget.attempts} '
                          '${widget.attempts == 1 ? 'attempt' : 'attempts'}',
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  widget.puzzle.explanation,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: widget.onHome,
                      child: const Text('Home'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _share,
                      icon: const Icon(Icons.share_rounded, size: 18),
                      label: const Text('Share'),
                    ),
                  ),
                ],
              ),
              if (widget.hasNext) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: widget.onNext,
                    style: FilledButton.styleFrom(
                      backgroundColor: scheme.primary,
                    ),
                    child: const Text('Next Level →'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _share() async {
    final label = widget.isDaily ? 'Daily Puzzle' : 'Level ${widget.puzzle.id}';
    final text =
        '🧠 ONE MOVE\n'
        '$label ✓\n'
        'Attempts: ${widget.attempts}\n'
        'Can you solve it in one move?';
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Result copied — paste it anywhere to share. '
          'No spoilers included.',
        ),
      ),
    );
  }
}
