import 'package:flutter/services.dart';

/// Sound effects for game events.
///
/// Uses only Flutter's built-in system sounds — no audio assets, no
/// copyrighted material, works offline, and degrades silently when the
/// device cannot play sound. The game is fully playable with sound off.
enum SoundType { tap, move, incorrect, success, unlock, dailyComplete }

class SoundService {
  bool enabled = true;

  Future<void> play(SoundType type) async {
    if (!enabled) return;
    try {
      switch (type) {
        case SoundType.tap:
        case SoundType.move:
          await SystemSound.play(SystemSoundType.click);
          break;
        case SoundType.incorrect:
        case SoundType.success:
        case SoundType.unlock:
        case SoundType.dailyComplete:
          await SystemSound.play(SystemSoundType.alert);
          break;
      }
    } catch (_) {
      // Audio unavailable — never let this break gameplay.
    }
  }
}
