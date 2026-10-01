import '../models/puzzle.dart';
import 'level_data.dart';

/// Access point for campaign levels and the daily-puzzle pool.
class PuzzleRepository {
  final List<Puzzle> levels;
  final List<Puzzle> dailyPool;

  PuzzleRepository({List<Puzzle>? levels, List<Puzzle>? dailyPool})
    : levels = levels ?? buildAllLevels(),
      dailyPool = dailyPool ?? buildDailyPool();

  Puzzle? levelById(int id) {
    for (final p in levels) {
      if (p.id == id) return p;
    }
    return null;
  }

  Puzzle? dailyById(int id) {
    for (final p in dailyPool) {
      if (p.id == id) return p;
    }
    return null;
  }
}
