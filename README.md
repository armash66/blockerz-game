# BLOCKERZ

Blockerz is a local multiplayer strategy board game built with Flutter.
The core loop is simple: move one tile, then your previous tile becomes blocked. Trap the opponent so they have no legal moves left.

## Features

- **Game Modes**:
  - PvP (same device)
  - PvAI with Easy and **Strategic (Minimax)** Hard difficulty.
- **Advanced Controls**:
  - **Undo/Redo**: Full move history support to experiment with strategies.
  - **Time Controls**: Chess-like timers (1m, 5m, 10m) for competitive play.
- **Onboarding**:
  - **Interactive Tutorial**: A step-by-step guide for new players.
- **Board Customization**:
  - Sizes: `5x5`, `7x7`, `9x9`
  - Themes: Classic, Neon, Ice, Lava
  - Dynamic Piece Counts: Automatically adjusts based on board size.
- **Powerups (Optional)**:
  - **Extra Move**: Move again without ending turn.
  - **Wall Builder**: Block any empty tile.
  - **Path Clearer**: Remove a blocked tile.
  - **Stealth Move**: Move without leaving a block behind.
- **Audio & Haptics**:
  - Immersive background music.
  - Satisfying sound effects and haptic feedback for every move and interaction.

## Rules

1. Select one of your pieces.
2. Move exactly one tile orthogonally (up, down, left, right) to an empty cell.
3. The cell you moved from becomes permanently blocked.
4. If a player has no legal moves at the start of their turn, they lose.

## AI Behavior

- **Easy**: Random legal move selection.
- **Hard**: **Deep Minimax Search** with Alpha-Beta pruning, optimized for board mobility and control.

## Project Structure

- `lib/main.dart` - App entry (`BlockerzApp`)
- `lib/screens/` - Home, Mode Selection, and Core Gameplay screens.
- `lib/core/` - Logic for game state, AI, audio management, and themes.
- `lib/widgets/` - Reusable UI components (buttons, tutorial, overlays).

## Run Locally

```bash
flutter pub get
flutter run
```

## Build for Android

Ensure you have a device or emulator connected:

```bash
flutter run -d <device_id>
```

---
*Built with ❤️ using Flutter*
