import 'package:flutter/material.dart';

import '../app/app_services.dart';
import '../app/routes.dart';
import 'game_screen.dart';

/// Daily puzzle entry: shows today's date-deterministic puzzle, or the
/// completed state with the streak when already solved.
class DailyPuzzleScreen extends StatelessWidget {
  final AppServices services;

  const DailyPuzzleScreen({super.key, required this.services});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final scheme = Theme.of(context).colorScheme;
    return ListenableBuilder(
      listenable: services.progress,
      builder: (context, _) {
        if (services.progress.isDailyDone(now)) {
          return Scaffold(
            appBar: AppBar(title: const Text("Today's Puzzle")),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      size: 84,
                      color: scheme.primary,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Done for today!',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '🔥 Daily streak: ${services.progress.dailyStreak}\n'
                      'Longest: ${services.progress.longestDailyStreak}',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge
                          ?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: () => Navigator.of(context)
                          .pushNamedAndRemoveUntil(
                            RouteNames.home,
                            (route) => false,
                          ),
                      child: const Text('Back Home'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        final puzzle = services.daily.today();
        return GameScreen(
          services: services,
          puzzle: puzzle,
          isDaily: true,
          dailyDate: now,
        );
      },
    );
  }
}
