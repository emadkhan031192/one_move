import '../models/puzzle.dart';
import 'validators/lateral_validator.dart';
import 'validators/line_validator.dart';
import 'validators/matchstick_validator.dart';
import 'validators/number_validator.dart';
import 'validators/shape_validator.dart';
import 'validators/tile_validator.dart';
import 'validators/verdict.dart';

/// The single source of truth for "did the player solve it?".
///
/// Every judgment is made by comparing the *resulting puzzle state* against
/// the initial state and the puzzle's goal — never by trusting which button
/// the UI thinks was pressed. The one-move rule is enforced here: a verdict
/// is only `solved` when exactly one meaningful move happened.
class PuzzleEngine {
  const PuzzleEngine._();

  static MoveVerdict evaluate(
    Puzzle puzzle,
    Map<String, dynamic> initial,
    Map<String, dynamic> current, {
    int attempt = 1,
  }) {
    try {
      switch (puzzle.type) {
        case PuzzleType.matchstick:
          return MatchstickValidator.evaluate(
            initial,
            current,
            attempt: attempt,
          );
        case PuzzleType.tile:
          return TileValidator.evaluate(initial, current, attempt: attempt);
        case PuzzleType.number:
          return NumberValidator.evaluate(initial, current, attempt: attempt);
        case PuzzleType.shape:
          return ShapeValidator.evaluate(initial, current, attempt: attempt);
        case PuzzleType.line:
          return LineValidator.evaluate(initial, current, attempt: attempt);
        case PuzzleType.lateral:
          final locked = puzzle.metadata['lockedId'];
          return LateralValidator.evaluate(
            initial,
            current,
            locked is int ? locked : null,
            attempt: attempt,
          );
      }
    } catch (_) {
      // Corrupted / unexpected state shapes fail gracefully, never crash.
      return const MoveVerdict(
        solved: false,
        movesUsed: 0,
        feedback: 'Hmm, that state did not make sense. Retry the level.',
      );
    }
  }
}
