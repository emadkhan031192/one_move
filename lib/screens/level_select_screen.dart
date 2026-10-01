import 'package:flutter/material.dart';

import '../app/app_services.dart';
import '../app/routes.dart';
import '../core/constants.dart';
import '../widgets/level_card.dart';

/// Scrollable grid of all 200 levels with unlock/completion state.
class LevelSelectScreen extends StatelessWidget {
  final AppServices services;

  const LevelSelectScreen({super.key, required this.services});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Levels')),
      body: ListenableBuilder(
        listenable: services.progress,
        builder: (context, _) {
          final progress = services.progress;
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 0.92,
            ),
            itemCount: AppConstants.totalLevels,
            itemBuilder: (context, i) {
              final level = i + 1;
              final unlocked = progress.isUnlocked(level);
              return LevelCard(
                level: level,
                unlocked: unlocked,
                completed: progress.isCompleted(level),
                isCurrent: level == progress.unlockedLevel,
                onTap: () =>
                    Navigator.of(context)
                        .pushNamed(RouteNames.game, arguments: level),
              );
            },
          );
        },
      ),
    );
  }
}
