# 🚫 BLOCKERZ - Strategy Board Game

> "Trap your opponent. Own the board."

**Blockerz** is a modern, fast-paced strategy game built with **Flutter**. It combines the classic "Isolation" mechanic with dynamic powerups, variable board sizes, and a sleek, responsive UI.

---

## ✨ Features

### 🎮 Game Modes
-   **PvP (Player vs Player)**: Battle a friend on the same device.
-   **PvAI (Player vs AI)**: Challenge the computer!
    -   **Easy Mode**: Random moves for casual play.
    -   **Hard Mode**: A greedy algorithm that fights for control.

### ⚡ Powerup System
Spice up the strategy with game-changing abilities! Be careful—you only draw one random card every 3 turns.
-   **🚀 High Jump**: Leap anywhere within range 3, ignoring obstacles.
-   **💣 Bomb**: Destroy a blocked cell to open new paths.
-   **🛡️ Shield**: Protect your previous tile from being blocked for one turn.
-   **⏩ Double Move**: Move twice in a single turn to outmaneuver your opponent.

### 🎨 Customization
-   **Board Sizes**: Play on **5x5** (Quick), **7x7** (Tactical), or **9x9** (Marathon) grids.
-   **Dynamic Themes**:
    -   **Classic**: Clean, dark aesthetic.
    -   **Neon**: Glowing cyber-future vibes.
    -   **Ice**: Cool blue tones for a chill game.
-   **Dark/Light Mode**: Toggle anytime to suit your environment.

---

## 📜 How to Play

1.  **Move**: Select your piece and move to any adjacent empty tile (horizontal, vertical, or diagonal).
2.  **Block**: The tile you moved **FROM** is permanently blocked (marked with an X). You cannot move there again!
3.  **Trap**: The goal is to survive. If a player cannot make a valid move, they **LOSE**. The last player standing wins!

---

## 🚀 Getting Started

To run this project locally:

1.  **Prerequisites**: Ensure you have [Flutter](https://flutter.dev/docs/get-started/install) installed.

2.  **Clone the repository**:
    ```bash
    git clone https://github.com/armash66/blockerz-game.git
    cd blockerz
    ```

3.  **Get Dependencies**:
    ```bash
    flutter pub get
    ```

4.  **Run the App**:
    ```bash
    flutter run
    ```

---

## 🛠️ Built With

-   **Flutter** - UI Framework
-   **Dart** - Programming Language
-   **Provider** (Implicit State Management via standard Flutter State)

---

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

---

© 2026 **Armash Ansari**. All rights reserved.
