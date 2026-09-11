# Arrow Path - Version 1.0.0+1 Release Notes Candidate

## 🚀 Overview
**Arrow Path** is a cross-platform (Android & iOS) arrow-extraction mobile puzzle game built with Flutter and Dart following Clean Architecture principles.

---

## 🎯 Key Features Included in Release Candidate

### 1. Gameplay Engine & Solvability
- Grid puzzle engine supporting 4x4, 5x5, 6x6, 7x7, and 8x8 grid sizes.
- Exact $O(N^2)$ greedy extraction `LevelSolver` ensuring **100% solvability** without deadlocks.
- Multi-step Undo, Solver-based Hinting, and Restart options.

### 2. Level System & Progression
- **500 Solvably Verified Levels** pre-compiled in `assets/levels/levels.json`.
- **10 Chapters** with progressive difficulty structure (Tutorial, Easy, Medium, Hard, Expert).
- Star rating system (1–3 stars) based on par move performance.
- Interactive Level Map displaying winding progress paths.

### 3. Retention & Economy
- **Daily Challenges:** Deterministic date-based seed puzzles with 🔥 streak tracking.
- **Daily Login Rewards:** 7-day calendar rewards.
- **Weekly Challenges:** 4 weekly objective challenges with countdown timers.
- **Limited-Time Live Events:** "Arrow Festival" event with objective progress tracking.
- **In-Game Economy:** Coins soft currency earned via level completions, 3-star runs, and daily streaks. Idempotent transaction IDs prevent duplicate reward claims.
- **Achievements:** 11 milestone achievements.

### 4. Account & Cloud Save
- **Guest Mode:** Complete offline playability without account creation.
- **Authentication:** Abstracted Google, Apple, and Facebook sign-in abstractions.
- **Cloud Save & Synchronization:** Local-first background sync with deterministic conflict resolution (`ProgressMergeService`).

### 5. Social Competition
- **Leaderboards:** Paginated global rankings (Total Stars desc, completed levels tie-breaker) and Friends leaderboards.
- **Friends System:** Player search, sending/accepting friend requests, public profile views, and blocking.

### 6. Monetization & Security
- **Ad Abstractions:** Interstitial frequency caps (min 3 levels, 2 min cooldown, first-time player protection), banner placements, and optional rewarded ads for extra hints/coins.
- **In-App Purchases:** `remove_ads` product purchase and restore entitlement flow.
- **Security:** Zero committed credentials or private keys. Privacy Policy and Terms of Service URLs configured.

---

## 📦 Store Submission Steps

### Google Play Console (Android)
1. **App Bundle:** Build release bundle: `flutter build appbundle --release`.
2. **Keystore:** Create release keystore, update `key.properties`, and configure signing in `android/app/build.gradle.kts`.
3. **Internal Testing:** Upload `.aab` to Google Play Console -> Internal Testing track.
4. **Listing Data:** Provide screenshots, feature graphics, app icon, data safety declaration, and Privacy Policy URL (`https://arrowgo.com/privacy`).

### Apple App Store Connect (iOS)
1. **Archive:** Open `ios/Runner.xcworkspace` in Xcode on macOS and select `Product -> Archive`.
2. **App Store Connect:** Upload archive, configure App Store listing, Apple Sign-In capabilities, in-app purchase `remove_ads`, and privacy policy URL.
