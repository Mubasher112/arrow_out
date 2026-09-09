# Arrow Path - Cross-Platform Mobile Puzzle Game

**Arrow Path** is a production-ready mobile puzzle game inspired by arrow extraction mechanics. Built with **Flutter** and **Dart** for both **Android** and **iOS** from a single codebase following Clean Architecture principles.

---

## 🎯 Gameplay Mechanics

1. The player sees a grid board (4x4 up to 8x8) filled with arrow tiles.
2. Each arrow points in one of four directions: **Up**, **Down**, **Left**, or **Right**.
3. When the player taps an arrow tile:
   - **Path Clear:** If no other arrow blocks its ray to the boundary of the board, the arrow animates leaving the board, removes itself from the grid, and updates move counts.
   - **Path Blocked:** If another arrow blocks its path, the arrow remains in place and triggers a wobble/shake feedback.
4. **Goal:** Clear all arrows off the board in the fewest possible moves.

---

## 🏗️ Architecture

The codebase strictly follows Clean Architecture with explicit layer boundaries:

```
lib/
├── config/              # App environment configurations
├── domain/              # Pure domain logic & business rules (UI independent)
│   ├── models/          # Arrow, GameBoard, LevelDefinition, LevelProgress, Enums
│   ├── repositories/    # Abstract repositories (GameRepository)
│   ├── game_engine.dart # Core game state machine & path clearance algorithm
│   ├── level_solver.dart# O(N^2) exact solver algorithm
│   └── level_generator.dart # Procedural solvable level generator
├── data/                # Data implementations & persistence
│   └── repositories/    # LocalGameRepository using SharedPreferences
├── services/            # Services (AudioService, LevelLoaderService)
├── ui/                  # Flutter presentation layer
│   ├── theme/          # Casual mobile game theme & color palette
│   ├── widgets/        # ArrowTileWidget, ArrowBoardWidget, SettingsDialog, LevelCompleteOverlay
│   └── screens/        # HomeScreen, LevelSelectScreen, GameScreen
└── main.dart            # Application entry point
```

---

## 📱 Features

- **100 Playable Levels:** Procedurally generated and pre-compiled into `assets/levels/levels.json`. Every single level is 100% verified solvable.
- **Progressive Difficulty Curve:**
  - **Levels 1–10:** 4x4 / 5x5 simple boards, 4–8 arrows.
  - **Levels 11–30:** 5x5 / 6x6 medium boards, 8–15 arrows with blocking.
  - **Levels 31–60:** 6x6 / 7x7 large boards, 15–25 arrows.
  - **Levels 61–100:** 7x7 / 8x8 complex multi-step puzzles, 25+ arrows.
- **Interactive Game Board:** Custom-painted rounded directional arrows with smooth animations for tap, blocked shake, exit translation, and level clear overlay.
- **Game Assists:**
  - **Undo:** Step backwards through move history.
  - **Hint:** Uses `LevelSolver` to highlight an unblocked arrow ready to leave.
  - **Restart:** Instantly restart the current level attempt.
- **Persistence:** Local storage of completed levels, stars earned (1–3), best move count, and audio preferences via `SharedPreferences`.
- **Responsive Layout:** Adapts dynamically to mobile phones and tablets in portrait orientation.

---

## 🛠️ Build & Setup Instructions

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.x stable)
- Dart SDK 3.x
- Android Studio / Xcode (for native device builds)

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Run Tests
```bash
flutter test
```

### 3. Run Application
```bash
# Debug Mode
flutter run

# Release Mode (Android)
flutter run --release
```

### 4. Build Bundles
#### Android
```bash
flutter build apk --release
# or App Bundle for Google Play
flutter build appbundle --release
```

#### iOS
```bash
flutter build ios --no-codesign
```
*Note: iOS compilation and signing require Xcode on macOS.*

---

## 🧪 Testing Coverage

The project includes unit and widget tests:
- **Domain Logic Tests:** `models_test.dart`, `game_engine_test.dart`
- **Solver & Level Asset Tests:** `level_solver_test.dart` (verifies all 100 levels)
- **Data Repository Tests:** `local_game_repository_test.dart`
- **UI & Widget Tests:** `home_screen_test.dart`, `level_select_screen_test.dart`, `game_screen_test.dart`, `level_complete_overlay_test.dart`

Run all tests with:
```bash
flutter test
```

---

## 📄 License
This project is custom developed with original assets and code.
