import '../core/constants.dart';
import '../core/utils.dart';
import '../models/puzzle.dart';
import '../puzzles/puzzle_repository.dart';

/// Date-deterministic daily puzzles. Works fully offline: the puzzle for a
/// date is `pool[daysSinceEpoch % poolSize]`, so every device and every
/// launch agrees on "today's puzzle".
class DailyPuzzleService {
  final PuzzleRepository repository;

  DailyPuzzleService(this.repository);

  Puzzle puzzleForDate(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    final days = d.difference(AppConstants.dailyEpoch).inDays;
    final index = posMod(days, repository.dailyPool.length);
    return repository.dailyPool[index];
  }

  Puzzle today() => puzzleForDate(DateTime.now());
}
