import 'package:flutter/material.dart';

import '../app/app_services.dart';
import '../app/routes.dart';
import '../core/audio/sound_service.dart';
import '../core/constants.dart';
import '../widgets/animated_button.dart';

/// Polished home: brand, progress at a glance, and the five destinations.
class HomeScreen extends StatelessWidget {
  final AppServices services;

  const HomeScreen({super.key, required this.services});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: ListenableBuilder(
          listenable: services.progress,
          builder: (context, _) {
            final progress = services.progress;
            final total = AppConstants.totalLevels;
            final pct = progress.completionPercent(total);
            final playId = progress.unlockedLevel > total
                ? total
                : progress.unlockedLevel;
            final today = DateTime.now();
            final dailyDone = progress.isDailyDone(today);

            return ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const SizedBox(height: 24),
                Center(
                  child: Column(
                    children: [
                      RichText(
                        text: TextSpan(
                          style: Theme.of(context).textTheme.displayMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w900,
                                letterSpacing: 3,
                                color: scheme.onSurface,
                              ),
                          children: const [
                            TextSpan(text: 'ONE\n'),
                            TextSpan(text: 'MOVE'),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppConstants.homeSubtitle,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                _StatsRow(
                  scheme: scheme,
                  currentLevel: playId,
                  percent: pct,
                  streak: progress.dailyStreak,
                ),
                const SizedBox(height: 16),
                _DailyBanner(
                  scheme: scheme,
                  done: dailyDone,
                  onTap: () =>
                      Navigator.of(context).pushNamed(RouteNames.daily),
                ),
                const SizedBox(height: 28),
                AnimatedButton(
                  onTap: () {
                    services.sound.play(SoundType.tap);
                    services.haptics.tap();
                    Navigator.of(context)
                        .pushNamed(RouteNames.game, arguments: playId);
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      color: scheme.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'PLAY',
                      style: TextStyle(
                        color: scheme.onPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _MenuButton(
                  label: 'LEVELS',
                  icon: Icons.grid_view_rounded,
                  onTap: () =>
                      Navigator.of(context).pushNamed(RouteNames.levels),
                ),
                _MenuButton(
                  label: 'DAILY PUZZLE',
                  icon: Icons.calendar_today_rounded,
                  trailing: dailyDone ? '✓' : '!',
                  onTap: () =>
                      Navigator.of(context).pushNamed(RouteNames.daily),
                ),
                _MenuButton(
                  label: 'STATS',
                  icon: Icons.bar_chart_rounded,
                  onTap: () =>
                      Navigator.of(context).pushNamed(RouteNames.stats),
                ),
                _MenuButton(
                  label: 'SETTINGS',
                  icon: Icons.settings_rounded,
                  onTap: () =>
                      Navigator.of(context).pushNamed(RouteNames.settings),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    'One Puzzle. One Move. Think Different.',
                    style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final ColorScheme scheme;
  final int currentLevel;
  final double percent;
  final int streak;

  const _StatsRow({
    required this.scheme,
    required this.currentLevel,
    required this.percent,
    required this.streak,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatCard(scheme: scheme, label: 'Level', value: '$currentLevel'),
        const SizedBox(width: 12),
        _StatCard(
          scheme: scheme,
          label: 'Done',
          value: '${(percent * 100).round()}%',
        ),
        const SizedBox(width: 12),
        _StatCard(
          scheme: scheme,
          label: 'Streak',
          value: streak > 0 ? '🔥 $streak' : '—',
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final ColorScheme scheme;
  final String label;
  final String value;

  const _StatCard({
    required this.scheme,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: scheme.outline),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _DailyBanner extends StatelessWidget {
  final ColorScheme scheme;
  final bool done;
  final VoidCallback onTap;

  const _DailyBanner({
    required this.scheme,
    required this.done,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: scheme.primaryContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(
              done ? Icons.check_circle_rounded : Icons.calendar_today_rounded,
              color: scheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                done
                    ? "Today's puzzle is done. See you tomorrow!"
                    : "Today's puzzle is waiting.",
                style: TextStyle(
                  color: scheme.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_rounded, color: scheme.primary, size: 18),
          ],
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final String? trailing;
  final VoidCallback onTap;

  const _MenuButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AnimatedButton(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: scheme.outline),
          ),
          child: Row(
            children: [
              Icon(icon, color: scheme.primary),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              if (trailing != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    trailing!,
                    style: TextStyle(
                      color: scheme.onPrimaryContainer,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
