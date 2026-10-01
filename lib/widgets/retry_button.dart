import 'package:flutter/material.dart';

/// Instant-retry button — one tap, no confirmation dialogs.
class RetryButton extends StatelessWidget {
  final VoidCallback onRetry;

  const RetryButton({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onRetry,
      icon: const Icon(Icons.refresh_rounded),
      label: const Text('Retry'),
    );
  }
}
