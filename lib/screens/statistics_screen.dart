import 'package:flutter/material.dart';

import '../app/app_services.dart';
import '../core/constants.dart';

/// Clean statistics overview.
class StatisticsScreen extends StatelessWidget {
  final AppServices services;

  const StatisticsScreen({super.key, required this.services});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Statistics')),
      body: ListenableBuilder(
        listenable: services.progress,
        builder: (context, _) {
          final p = services.progress;
          final stats = [
            ('Solved', '${p.completedLevels.length}'),
            ('Attempted', '${p.attempts}'),
            ('Success rate', '${(p.successRate * 100).toStringAsFixed(0)}%'),
            ('Current streak', p.dailyStreak > 0 ? '🔥 ${p.dailyStreak}' : '—'),
            (
              'Longest streak',
              p.longestDailyStreak > 0 ? '🔥 ${p.longestDailyStreak}' : '—',
            ),
            ('Hints used', '${p.hintsUsed}'),
            (
              'Hardest level',
              p.hardestLevelSolved > 0 ? '${p.hardestLevelSolved}' : '—',
            ),
            (
              'Completion',
              '${(p.completionPercent(AppConstants.totalLevels) * 100).toStringAsFixed(1)}%',
            ),
          ];
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.6,
            ),
            itemCount: stats.length,
            itemBuilder: (context, i) {
              final (label, value) = stats[i];
              return Container(
                decoration: BoxDecoration(
                  color: scheme.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: scheme.outline),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 13,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
