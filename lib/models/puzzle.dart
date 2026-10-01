/// Core data models for ONE MOVE.
///
/// These types are intentionally plain Dart (no Flutter dependency) so the
/// puzzle engine and level generators stay testable in isolation.

/// The six puzzle mechanics supported by the game.
enum PuzzleType { matchstick, tile, shape, line, number, lateral }

extension PuzzleTypeX on PuzzleType {
  String get label {
    switch (this) {
      case PuzzleType.matchstick:
        return 'Matchstick';
      case PuzzleType.tile:
        return 'Tile';
      case PuzzleType.shape:
        return 'Shape';
      case PuzzleType.line:
        return 'Line';
      case PuzzleType.number:
        return 'Number';
      case PuzzleType.lateral:
        return 'Lateral';
    }
  }

  /// Short description of what "one move" means for this type.
  String get moveDescription {
    switch (this) {
      case PuzzleType.matchstick:
        return 'Move one matchstick (change one digit).';
      case PuzzleType.tile:
        return 'Change exactly one tile.';
      case PuzzleType.shape:
        return 'Move exactly one shape.';
      case PuzzleType.line:
        return 'Move exactly one line.';
      case PuzzleType.number:
        return 'Change exactly one number.';
      case PuzzleType.lateral:
        return 'Move exactly one piece — even the "locked" one.';
    }
  }
}

/// Difficulty bands used across the 200-level campaign.
enum Difficulty { tutorial, easy, medium, hard, veryHard, expert }

extension DifficultyX on Difficulty {
  String get label {
    switch (this) {
      case Difficulty.tutorial:
        return 'Tutorial';
      case Difficulty.easy:
        return 'Easy';
      case Difficulty.medium:
        return 'Medium';
      case Difficulty.hard:
        return 'Hard';
      case Difficulty.veryHard:
        return 'Very Hard';
      case Difficulty.expert:
        return 'Expert';
    }
  }

  /// 1..6 star rating for UI.
  int get stars => index + 1;
}

/// A single puzzle.
///
/// [initialState] and the solved state stored in [metadata]['solvedState']
/// are JSON-encodable maps whose schema depends on [type]:
///
/// * matchstick: {'chars': ['3','+','3','=','9']}
/// * tile:       {'size': 3, 'options': 2, 'grid': [...], 'target': [...]}
/// * number:     {'values': [...], 'rule': 'ap', 'target': [...]}
/// * shape:      {'cells': 9, 'shapes': [{'id':0,'kind':'circle','cell':0}],
///                'target': {'0': 4}}
/// * line:       {'points': [{'x':0.2,'y':0.2}], 'segments': [[0,1]],
///                'goal': 'no_cross'}
/// * lateral:    same as shape, plus {'lockedId': 1}
class Puzzle {
  final int id;
  final PuzzleType type;
  final Difficulty difficulty;
  final String title;
  final String instruction;
  final Map<String, dynamic> initialState;
  final List<String> hints;
  final String explanation;
  final Map<String, dynamic> metadata;

  const Puzzle({
    required this.id,
    required this.type,
    required this.difficulty,
    required this.title,
    required this.instruction,
    required this.initialState,
    required this.hints,
    required this.explanation,
    this.metadata = const {},
  }) : assert(hints.length == 3, 'Every puzzle must carry exactly 3 hints');

  /// The state produced by the intended winning move, when known.
  /// Generators always populate this; used by tests to prove solvability.
  Map<String, dynamic>? get solvedState {
    final s = metadata['solvedState'];
    if (s is Map) return Map<String, dynamic>.from(s);
    return null;
  }

  /// Copies this puzzle with a different id (used for generator fallbacks).
  Puzzle copyWithId(int newId) => Puzzle(
    id: newId,
    type: type,
    difficulty: difficulty,
    title: title,
    instruction: instruction,
    initialState: Map<String, dynamic>.from(initialState),
    hints: List<String>.from(hints),
    explanation: explanation,
    metadata: Map<String, dynamic>.from(metadata),
  );
}

/// Tracks progressive hint disclosure for one puzzle attempt.
class HintProgression {
  final List<String> hints;
  int revealed = 0;

  HintProgression(this.hints) : assert(hints.length == 3);

  bool get hasMore => revealed < hints.length;

  /// Reveals the next hint, or null when all are shown.
  String? revealNext() {
    if (!hasMore) return null;
    return hints[revealed++];
  }

  List<String> get visible => hints.sublist(0, revealed);
}
