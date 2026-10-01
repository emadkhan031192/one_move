import 'shape_validator.dart';
import 'verdict.dart';

/// Lateral-thinking puzzles reuse the shape mechanics, but the winning move
/// must be the piece the player assumed was fixed ([lockedId]).
class LateralValidator {
  const LateralValidator._();

  static MoveVerdict evaluate(
    Map<String, dynamic> initial,
    Map<String, dynamic> current,
    int? lockedId, {
    int attempt = 1,
  }) {
    return ShapeValidator.evaluate(
      initial,
      current,
      attempt: attempt,
      mustMoveId: lockedId,
    );
  }
}
