import 'package:flutter/material.dart';

import '../models/puzzle.dart';
import 'boards/line_board.dart';
import 'boards/matchstick_board.dart';
import 'boards/number_board.dart';
import 'boards/shape_board.dart';
import 'boards/tile_board.dart';

/// Dispatches to the interactive renderer for the puzzle's type.
class PuzzleBoard extends StatelessWidget {
  final Puzzle puzzle;
  final Map<String, dynamic> state;
  final ValueChanged<Map<String, dynamic>> onChanged;
  final bool locked;

  const PuzzleBoard({
    super.key,
    required this.puzzle,
    required this.state,
    required this.onChanged,
    this.locked = false,
  });

  @override
  Widget build(BuildContext context) {
    final Widget child;
    switch (puzzle.type) {
      case PuzzleType.matchstick:
        child = MatchstickBoard(state: state, onChanged: onChanged);
        break;
      case PuzzleType.tile:
        child = TileBoard(state: state, onChanged: onChanged);
        break;
      case PuzzleType.number:
        child = NumberBoard(state: state, onChanged: onChanged);
        break;
      case PuzzleType.shape:
        child = ShapeBoard(state: state, onChanged: onChanged);
        break;
      case PuzzleType.lateral:
        child = ShapeBoard(state: state, onChanged: onChanged, lateral: true);
        break;
      case PuzzleType.line:
        child = LineBoard(state: state, onChanged: onChanged);
        break;
    }
    return IgnorePointer(ignoring: locked, child: child);
  }
}
