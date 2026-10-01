import 'package:flutter/material.dart';

import '../app/app_services.dart';
import '../app/routes.dart';
import '../core/audio/sound_service.dart';
import '../core/constants.dart';
import '../core/utils.dart';
import '../models/puzzle.dart';
import '../puzzle_engine/puzzle_engine.dart';
import '../widgets/level_header.dart';
import '../widgets/puzzle_board.dart';
import '../widgets/retry_button.dart';
import '../widgets/success_overlay.dart';

/// The one-move arena. Used for campaign levels and the daily puzzle.
/// Every board change is judged by [PuzzleEngine] against the initial state.
class GameScreen extends StatefulWidget {
  final AppServices services;
  final Puzzle puzzle;
  final bool isDaily;
  final DateTime? dailyDate;

  const GameScreen({
    super.key,
    required this.services,
    required this.puzzle,
    this.isDaily = false,
    this.dailyDate,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late Map<String, dynamic> _initial;
  late Map<String, dynamic> _current;
  late HintProgression _hints;
  int _attempts = 0;
  bool _solved = false;
  bool _bannerDismissed = false;
  String _feedback = '';
  double _shakeOffset = 0;
  int _shakeToken = 0;
  int _retryToken = 0;

  @override
  void initState() {
    super.initState();
    _initial = deepCopyState(widget.puzzle.initialState);
    _current = deepCopyState(widget.puzzle.initialState);
    _hints = HintProgression(widget.puzzle.hints);
  }

  Future<void> _onChanged(Map<String, dynamic> next) async {
    if (_solved) return;
    setState(() => _current = next);
    final verdict = PuzzleEngine.evaluate(
      widget.puzzle,
      _initial,
      _current,
      attempt: _attempts + 1,
    );
    if (verdict.movesUsed == 0) {
      setState(() => _feedback = '');
      return;
    }
    _attempts++;
    if (verdict.solved) {
      await _onSolved();
    } else {
      await widget.services.progress.recordAttempt();
      widget.services.sound.play(SoundType.incorrect);
      widget.services.haptics.error();
      if (!mounted) return;
      setState(() => _feedback = verdict.feedback);
      _shake();
    }
  }

  Future<void> _onSolved() async {
    setState(() {
      _solved = true;
      _feedback = '';
    });
    widget.services.sound.play(SoundType.success);
    widget.services.haptics.success();
    if (widget.isDaily) {
      await widget.services.progress.completeDaily(
        widget.dailyDate ?? DateTime.now(),
      );
      widget.services.sound.play(SoundType.dailyComplete);
    } else {
      await widget.services.progress.completeLevel(widget.puzzle.id);
      widget.services.sound.play(SoundType.unlock);
    }
    if (!mounted) return;
    final hasNext =
        !widget.isDaily && widget.puzzle.id < AppConstants.totalLevels;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: EdgeInsets.zero,
        child: SuccessOverlay(
          puzzle: widget.puzzle,
          attempts: _attempts,
          hasNext: hasNext,
          isDaily: widget.isDaily,
          onNext: () {
            Navigator.of(context).pop();
            Navigator.of(context).pushReplacementNamed(
              RouteNames.game,
              arguments: widget.puzzle.id + 1,
            );
          },
          onHome: () {
            Navigator.of(context).pop();
            Navigator.of(context)
                .pushNamedAndRemoveUntil(RouteNames.home, (route) => false);
          },
        ),
      ),
    );
  }

  void _retry() {
    widget.services.sound.play(SoundType.tap);
    widget.services.haptics.tap();
    setState(() {
      _current = deepCopyState(_initial);
      _feedback = '';
      _retryToken++;
    });
  }

  void _showHint() {
    final revealed = _hints.revealNext();
    if (revealed != null) {
      widget.services.progress.useHint();
      widget.services.sound.play(SoundType.tap);
    }
    setState(() {});
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hints'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < _hints.visible.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Theme.of(ctx).colorScheme.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${i + 1}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Theme.of(ctx).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Text(_hints.visible[i])),
                  ],
                ),
              ),
            if (!_hints.hasMore)
              Text(
                'That was the last hint — the rest is up to you.',
                style: Theme.of(ctx).textTheme.bodySmall,
              ),
          ],
        ),
        actions: [
          if (widget.services.ads.isAvailable)
            TextButton(
              onPressed: () async {
                final earned = await widget.services.ads.showRewardedAd();
                if (!mounted) return;
                if (earned) {
                  Navigator.of(ctx).pop();
                  _showHint();
                }
              },
              child: const Text('Free hint (ad)'),
            ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              if (_hints.hasMore) _showHint();
            },
            child: Text(_hints.hasMore ? 'Next hint' : 'Close'),
          ),
        ],
      ),
    );
  }

  void _shake() {
    final token = ++_shakeToken;
    Future(() async {
      for (final o in [14.0, -11.0, 8.0, -5.0, 3.0, 0.0]) {
        if (!mounted || token != _shakeToken) return;
        setState(() => _shakeOffset = o);
        await Future.delayed(const Duration(milliseconds: 50));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final p = widget.puzzle;
    final subtitle = widget.isDaily
        ? 'Daily · 🔥 ${widget.services.progress.dailyStreak}'
        : '${p.type.label} · ${p.difficulty.label}';

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: LevelHeader(
                title: widget.isDaily ? "Today's Puzzle" : 'Level ${p.id}',
                subtitle: subtitle,
                onBack: () => Navigator.of(context).pop(),
                onHint: _showHint,
                hintsRevealed: _hints.revealed,
              ),
            ),
            if (!_bannerDismissed)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.bolt_rounded, color: scheme.primary, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'You have ONE move.',
                          style: TextStyle(
                            color: scheme.onPrimaryContainer,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => setState(() => _bannerDismissed = true),
                        child: Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: scheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      p.title,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      p.instruction,
                      style: Theme.of(context).textTheme.bodyMedium
                          ?.copyWith(color: scheme.onSurfaceVariant),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 22),
                    Transform.translate(
                      offset: Offset(_shakeOffset, 0),
                      child: PuzzleBoard(
                        key: ValueKey(
                          'board_${p.id}_${widget.isDaily}_$_retryToken',
                        ),
                        puzzle: p,
                        state: _current,
                        onChanged: _onChanged,
                        locked: _solved,
                      ),
                    ),
                    const SizedBox(height: 16),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: _feedback.isEmpty
                          ? const SizedBox(key: ValueKey('empty'), height: 24)
                          : Text(
                              _feedback,
                              key: ValueKey(_feedback),
                              style: TextStyle(
                                color: scheme.error,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RetryButton(onRetry: _retry),
                  const SizedBox(width: 16),
                  Text(
                    'Attempts: $_attempts',
                    style: Theme.of(context).textTheme.bodyMedium
                        ?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
