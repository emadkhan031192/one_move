import 'package:flutter/material.dart';

/// One cell of the level-select grid: number, checkmark, or lock.
class LevelCard extends StatelessWidget {
  final int level;
  final bool unlocked;
  final bool completed;
  final bool isCurrent;
  final VoidCallback? onTap;

  const LevelCard({
    super.key,
    required this.level,
    required this.unlocked,
    required this.completed,
    required this.isCurrent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = !unlocked
        ? scheme.surfaceContainerHighest.withOpacity(0.6)
        : completed
        ? scheme.primaryContainer
        : isCurrent
        ? scheme.primary
        : scheme.surface;
    final fg = !unlocked
        ? scheme.onSurfaceVariant.withOpacity(0.5)
        : completed
        ? scheme.onPrimaryContainer
        : isCurrent
        ? scheme.onPrimary
        : scheme.onSurface;

    return GestureDetector(
      onTap: unlocked ? onTap : null,
      child: Semantics(
        label: unlocked
            ? 'Level $level${completed ? ', completed' : ''}'
            : 'Level $level, locked',
        button: true,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isCurrent && unlocked ? scheme.primary : scheme.outline,
              width: isCurrent && unlocked ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                level.toString().padLeft(2, '0'),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: fg,
                ),
              ),
              const SizedBox(height: 2),
              Icon(
                !unlocked
                    ? Icons.lock_outline
                    : completed
                    ? Icons.check
                    : Icons.play_arrow_rounded,
                size: 16,
                color: fg,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
