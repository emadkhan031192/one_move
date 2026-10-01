import 'package:flutter/services.dart';

/// Subtle haptic feedback, gated by the user's settings toggle.
class HapticService {
  bool enabled = true;

  Future<void> _run(Future<void> Function() action) async {
    if (!enabled) return;
    try {
      await action();
    } catch (_) {
      // Haptics unavailable — never let this break gameplay.
    }
  }

  Future<void> tap() => _run(HapticFeedback.lightImpact);
  Future<void> move() => _run(HapticFeedback.mediumImpact);
  Future<void> success() => _run(HapticFeedback.mediumImpact);
  Future<void> error() => _run(HapticFeedback.heavyImpact);
}
