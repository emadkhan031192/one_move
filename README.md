# ONE MOVE — One Puzzle. One Move. Think Different.

A complete, playable Flutter puzzle game built around one rule: **every puzzle
is solved with exactly one meaningful move.** The game rewards creative
thinking, not fast tapping.

## Features

- **200 hand-tuned levels** across 6 puzzle types and 6 difficulty bands:
  - 🔥 Matchstick equations — move one stick to fix the math
  - 🧩 Tile grids — flip the single wrong tile
  - 🔢 Number sequences — find and fix the intruder
  - ⬛ Shape sorting — return the stray shape home
  - ➖ Line untangling — re-attach one line to remove every crossing
  - 🌀 Lateral thinking — move the piece that *shouldn't* move
- **Real puzzle engine** — every move is judged by a rules engine, not a
  memorized answer. Wrong answers get coaching feedback, never just "nope".
- **One-move rule** — the engine counts every change; touch two things and the
  level won't accept it.
- **3 progressive hints per level**, hint usage tracked in stats
- **Sequential unlocking** — finish a level to open the next
- **Daily puzzle** with streak tracking (deterministic: same date = same puzzle
  on every device)
- **Stats**: solved count, success rate, streaks, hardest level, completion %
- **Settings**: sound, haptics, dark mode, notifications toggle, reset progress
- **Offline-first**, no accounts, no login — all data stays on the device
- Portrait, light + dark themes, haptic + sound feedback

## Getting started

Requirements: Flutter 3.24+ (Dart 3.4+), Android SDK for device builds.

```bash
flutter pub get
flutter run
```

Run the tests:

```bash
flutter test
```

Format + analyze (CI enforces both):

```bash
dart format .
flutter analyze
```

Build a release APK:

```bash
flutter build apk --release
```

CI (`.github/workflows/build_apk.yml`) runs format check → analyze → tests →
release APK build on every push, and uploads the APK as an artifact. It signs
with a generated debug keystore; replace the signing config with a real
keystore before any production release.

## Project structure

```
lib/
  main.dart                 app entry: services, orientation, runApp
  app/                      OneMoveApp, named routes, service bundle, themes
  models/                   Puzzle, PuzzleType, Difficulty, HintProgression
  core/                     utils, constants, sound, haptics
  puzzle_engine/            PuzzleEngine + per-type validators + verdicts
  puzzles/                  level_data.dart (all 200 + daily pool), repository
  services/                 progress, settings, daily puzzle, ads (stub)
  screens/                  splash, onboarding, home, level select, game,
                            daily, stats, settings
  widgets/                  boards per puzzle type, overlays, buttons
test/                       engine, levels, services, widget tests
android/                    Gradle config, manifest, icons
```

## How a move is judged

`PuzzleEngine.evaluate(puzzle, initialState, currentState)`:

1. Diffs the current state against the initial state → `movesUsed`.
2. Runs the type-specific validator (e.g. matchstick: exactly one digit
   changed, same matchstick count, equation true; number: sequence satisfies
   its named rule; line: one segment re-attached, zero interior crossings).
3. `solved` only when exactly one move was made **and** the goal predicate
   holds. Otherwise a coaching hint explains what went wrong.

## Adding a puzzle

Levels are generated in `lib/puzzles/level_data.dart`. Each generator builds a
*solved* state first, applies the inverse of one legal move to create the
starting state, and stores the solved state in `metadata['solved']` so tests
prove every level is solvable. Hand-authored tutorial levels (1–10) live at the
top of `buildAllLevels()`. Every level needs: id, type, difficulty, title,
instruction, initial state, 3 hints, explanation.

## Roadmap

- Pack 2: word and logic puzzles
- Optional rewarded-ad hints (the `AdService` seam is ready)
- iOS build flavor
- Cloud backup opt-in

## License

MIT — see LICENSE.
