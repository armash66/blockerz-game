# BLOCKERZ

Blockerz is a local multiplayer strategy board game built with Flutter.
The core loop is simple: move one tile, then your previous tile becomes blocked. Trap the opponent so they have no legal moves left.

## What is in this version

- Game modes:
  - PvP (same device)
  - PvAI with Easy and Hard difficulty
- Board sizes: `5x5`, `7x7`, `9x9`
- Starting piece counts by board size:
  - `5x5` -> 2 pieces/player
  - `7x7` -> 3 pieces/player
  - `9x9` -> 4 pieces/player
- Powerups (optional) with animated card draw every 3 completed turns:
  - Extra Move: move again without ending turn
  - Wall Builder: block any empty tile
  - Path Clearer: remove a blocked tile
- Board themes: Classic, Neon, Ice, Lava
- Light/Dark UI toggle
- Material 3 UI + Google Fonts (`Outfit`)

## Rules

1. Select one of your pieces.
2. Move exactly one tile orthogonally (up, down, left, right) to an empty cell.
3. The cell you moved from becomes permanently blocked.
4. If a player has no legal moves at the start of their turn, they lose.

## AI behavior

- Easy: random legal move.
- Hard: heuristic move selection (center preference + pressure on nearby opponent pieces).

## Project structure

- `lib/main.dart` - app entry (`BlockerzApp`)
- `lib/screens/home_screen.dart` - landing + rules dialog
- `lib/screens/mode_select_screen.dart` - mode, difficulty, powerups, theme, board size
- `lib/screens/game_screen.dart` - board rendering and gameplay interactions
- `lib/core/game_state.dart` - game rules, turn flow, win check, inventories
- `lib/core/ai_player.dart` - AI move generation
- `lib/core/powerup.dart` - powerup definitions
- `lib/core/app_theme.dart` - board/UI themes
- `lib/widgets/` - reusable UI components

## Run locally

```bash
flutter pub get
flutter run
```

## Test

```bash
flutter test
```

## Notes

- Package name in `pubspec.yaml` is currently `lockgrid`.
- App branding/title in UI is `BLOCKERZ`.
