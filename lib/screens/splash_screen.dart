import 'package:flutter/material.dart';

import '../app/app_services.dart';
import '../app/routes.dart';

/// Brief brand splash while the app settles, then routes onward.
class SplashScreen extends StatefulWidget {
  final AppServices services;

  const SplashScreen({super.key, required this.services});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1100), () {
      if (!mounted) return;
      final next = widget.services.progress.onboardingDone
          ? RouteNames.home
          : RouteNames.onboarding;
      Navigator.of(context).pushReplacementNamed(next);
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _LogoMark(scheme: scheme),
            const SizedBox(height: 24),
            RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                  color: scheme.onSurface,
                ),
                children: const [
                  TextSpan(text: 'ONE '),
                  TextSpan(text: 'MOVE'),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Think. Move. Solve.',
              style: Theme.of(context).textTheme.bodyLarge
                  ?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _LogoMark extends StatelessWidget {
  final ColorScheme scheme;
  const _LogoMark({required this.scheme});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        color: scheme.primary,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Icon(
        Icons.arrow_forward_rounded,
        size: 52,
        color: scheme.onPrimary,
      ),
    );
  }
}
