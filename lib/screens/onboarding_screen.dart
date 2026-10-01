import 'package:flutter/material.dart';

import '../app/app_services.dart';
import '../app/routes.dart';

/// Four-page first-launch introduction. Skippable; completion is persisted.
class OnboardingScreen extends StatefulWidget {
  final AppServices services;

  const OnboardingScreen({super.key, required this.services});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pages = const PageController();
  int _index = 0;

  static const _slides = [
    (
      title: 'ONE MOVE',
      body: 'Every puzzle has one important move.',
      icon: Icons.looks_one_rounded,
    ),
    (
      title: 'Think first',
      body: 'Think before you move. There are no take-backs — only retries.',
      icon: Icons.psychology_rounded,
    ),
    (
      title: 'Doubt the obvious',
      body: 'Sometimes the obvious answer is wrong. Question your assumptions.',
      icon: Icons.visibility_off_rounded,
    ),
    (
      title: "Let's play",
      body: 'One puzzle. One move. Think different.',
      icon: Icons.play_arrow_rounded,
    ),
  ];

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await widget.services.progress.setOnboardingDone();
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(RouteNames.home);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        actions: [TextButton(onPressed: _finish, child: const Text('Skip'))],
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pages,
              itemCount: _slides.length,
              onPageChanged: (i) => setState(() => _index = i),
              itemBuilder: (context, i) {
                final slide = _slides[i];
                return Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: scheme.primaryContainer,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          slide.icon,
                          size: 60,
                          color: scheme.primary,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        slide.title,
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.w900),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        slide.body,
                        style: Theme.of(context).textTheme.bodyLarge
                            ?.copyWith(color: scheme.onSurfaceVariant),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < _slides.length; i++)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _index == i ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _index == i ? scheme.primary : scheme.outline,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  if (_index == _slides.length - 1) {
                    _finish();
                  } else {
                    _pages.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  }
                },
                child: Text(
                  _index == _slides.length - 1 ? "Let's play" : 'Next',
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
