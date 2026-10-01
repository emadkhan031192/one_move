/// The engine's judgment of a player's attempt.
class MoveVerdict {
  final bool solved;
  final int movesUsed;
  final String feedback;

  const MoveVerdict({
    required this.solved,
    required this.movesUsed,
    required this.feedback,
  });
}

/// Feedback when no move has been made yet.
const MoveVerdict noMoveVerdict = MoveVerdict(
  solved: false,
  movesUsed: 0,
  feedback: 'You have ONE move. Make it count.',
);

/// Feedback when more than one meaningful change is detected.
MoveVerdict multiMoveVerdict(int moves) => MoveVerdict(
  solved: false,
  movesUsed: moves,
  feedback: 'That was $moves moves — you only get ONE. Hit retry and commit.',
);

/// Rotating "wrong, but keep thinking" feedback (never just "WRONG").
String wrongMoveFeedback(int attempt) {
  const messages = [
    'Not quite.',
    'Close… rethink the rule.',
    "That wasn't the move.",
    'Look at the whole puzzle.',
  ];
  return messages[(attempt - 1).abs() % messages.length];
}
