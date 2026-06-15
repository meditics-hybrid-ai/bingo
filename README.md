# Meditics BINGO

Meditics BINGO is a simple single-player bingo game built with Flutter and Dart. The app is designed for offline play with no remote database, no backend, and no pot money or gambling mechanics.

## App Summary

- App name: Meditics BINGO
- Platform: Android and iOS
- Codebase: Flutter / Dart
- Game mode: Single player
- Backend: None
- Remote database: None
- Monetization: Google AdMob
- Distribution: Google Play Store and Apple App Store
- Logo asset: `assets/images/meditics_bingo_logo.png`

## Product Goals

1. Deliver a lightweight bingo experience that works fully on-device.
2. Keep gameplay simple, fast, and suitable for casual sessions.
3. Avoid gambling mechanics, cash prizes, pot money, player accounts, and server-side dependencies.
4. Monetize through non-intrusive ads while keeping the core game playable.
5. Prepare the app for both Google Play Store and Apple App Store release.

## Core Features

- Generate a randomized bingo card for each game.
- Start the game with a single Start button.
- Draw numbers locally from a randomized pool every 8 seconds after the game starts.
- Announce the game start with audio.
- Announce each called number with audio, such as `B 9`.
- Announce the win when BINGO is achieved.
- Display the Meditics BINGO logo in the app UI.
- Use a vibrant arcade-style visual design inspired by the app logo.
- Use generated Meditics BINGO launcher icons for Android and iOS.
- Require the player to manually tap matching numbers on the bingo card.
- Prevent marking numbers that have not been drawn yet.
- Detect valid bingo patterns.
- Show win state when the player completes a valid pattern.
- Ask for confirmation before refreshing a started or completed game.
- Show Google AdMob test banner ads during development.
- Keep the banner ad fixed in a constrained bottom strip.
- Preload and show a Google AdMob test interstitial after BINGO is achieved.
- Hide the large logo after the game starts so gameplay gets more space.
- Hide the pre-game call/status panel so the Start button is visible sooner.
- Highlight drawn-but-unmarked card numbers with a bright gold/orange state.
- Store simple local preferences, such as sound, vibration, and ad consent settings if needed.
- Display ads in appropriate places, such as after completed games or from an optional rewarded placement.

## Ads

The app uses Google AdMob through the official `google_mobile_ads` Flutter plugin.

Current development setup:

- The app automatically uses test ads in debug/profile builds and production ad placeholders in release builds.
- Android AdMob test app ID: `ca-app-pub-3940256099942544~3347511713`
- iOS AdMob test app ID: `ca-app-pub-3940256099942544~1458002511`
- Android production app ID placeholder: `ca-app-pub-0000000000000000~0000000000`
- iOS production app ID placeholder: `ca-app-pub-0000000000000000~0000000000`
- Banner ads use Google test ad unit IDs.
- Game-over interstitial ads use Google test ad unit IDs.
- Production banner and interstitial ad unit IDs currently use placeholders.
- Widget tests inject a no-op ads service so tests do not load platform ads.

Ad mode defaults:

- Debug/profile builds: Google AdMob test ads.
- Release builds: production placeholders until real AdMob IDs are available.
- Optional override: pass `--dart-define=ADMOB_FORCE_TEST_ADS=true` to force test ad unit IDs.
- Optional override: pass `--dart-define=ADMOB_FORCE_PRODUCTION_ADS=true` to force production ad unit placeholders.

Before release:

- Replace all production app ID and ad unit ID placeholders with real AdMob IDs.
- Configure app-ads.txt.
- Complete privacy disclosures for Google Play and Apple App Store.
- Configure consent handling if required by target markets.
- Keep ad placement non-disruptive and avoid interrupting active gameplay.

## Current Gameplay

1. The player starts with a fresh randomized 5x5 bingo card.
2. The center space is marked as `FREE`.
3. The player taps `Start` to begin the game.
4. Before the game starts, the large logo is shown and the call/status panel is hidden to keep the Start button easier to reach.
5. The app announces that the game has started.
6. The app draws the first number immediately, announces it, then continues drawing and announcing one number every 8 seconds.
7. The large logo is hidden and the call/status panel appears after the game starts.
8. The player manually taps a card cell to mark it.
9. A cell can only be marked if its number has already been drawn.
10. The app checks rows, columns, and diagonals after each valid mark.
11. The draw timer stops when the player completes BINGO.
12. The app announces the BINGO win.
13. If the game has started or ended, tapping refresh asks for confirmation before starting a new game.

## Non-Goals

- No multiplayer mode for the first release.
- No remote database or backend API.
- No pot money, cash rewards, betting, wagering, or prize redemption.
- No account registration or login.
- No real-time chat, leaderboard, or social layer.

## Proposed Development Plan

### Phase 1: Project Foundation

- Create the Flutter project structure.
- Confirm Android and iOS platform targets.
- Set app name, bundle identifier, package name, launcher icon, and splash screen.
- Add Meditics BINGO logo asset and generated Android/iOS launcher icons. Done.
- Establish code organization for game logic, UI, state, services, and shared widgets.
- Add linting and basic test setup.

### Phase 2: Game Logic

- Build the bingo card generator. Done.
- Build the number draw engine. Done.
- Track marked cells and drawn numbers. Done.
- Implement bingo pattern detection. Done.
- Require manual marking only after a number has been drawn. Done.
- Add unit tests for card generation, number drawing, manual marking, and win detection. Done.

### Phase 3: Gameplay UI

- Design the main game screen. Done.
- Add card grid, drawn number display, Start button, refresh button, and win state. Done.
- Add Meditics BINGO logo to the app UI. Done.
- Add vibrant logo-inspired styling for the background, bingo board, number calls, actions, and recent draws. Done.
- Hide the large logo after game start to improve gameplay space. Done.
- Hide the pre-game call/status panel so the Start button is visible sooner. Done.
- Add automatic 8-second number drawing after Start. Done.
- Add a more visible drawn-but-unmarked tile state. Done.
- Add refresh confirmation for started or completed games. Done.
- Add audio announcements for game start, called numbers, and BINGO win. Done.
- Add responsive layouts for phones and tablets.
- Add simple animations and feedback for marking cells and winning.
- Add sound and haptic feedback controls if desired.

### Phase 4: Local State

- Save lightweight preferences locally.
- Keep current game state during app lifecycle interruptions if needed.
- Add privacy-safe local settings for ads and user preferences.

### Phase 5: Ads

- Integrate Google AdMob mobile ads SDK. Done.
- Choose ad placements that do not interrupt active gameplay. Done.
- Keep the banner ad fixed in a constrained bottom strip. Done.
- Automatically select test ads for non-release builds and production placeholders for release builds. Done.
- Add test ads during development. Done.
- Add production ad unit IDs through environment or build configuration.
- Validate Google Play and Apple App Store policy requirements for ad disclosure and tracking permissions.

### Phase 6: Polish and QA

- Test on multiple Android and iOS screen sizes.
- Verify offline play behavior.
- Confirm no backend or remote database dependency exists.
- Add accessibility labels and adequate color contrast.
- Run unit, widget, and manual smoke tests.
- Prepare release builds for Android and iOS.

### Phase 7: Store Release

- Prepare app icon, screenshots, description, privacy policy, and store metadata.
- Configure Android signing and Play Console release track.
- Configure iOS signing, App Store Connect listing, and TestFlight testing.
- Complete privacy nutrition labels and ad/tracking disclosures.
- Submit to Google Play Store and Apple App Store.

## Suggested Technical Structure

```text
lib/
  main.dart
  app/
  game/
    models/
    services/
    state/
    widgets/
  ads/
  settings/
  shared/
```

## Local Development

Install Flutter, then run:

```sh
flutter pub get
flutter run
```

Run tests:

```sh
flutter test
```

## Release Checklist

- App display name is set to `Meditics BINGO`.
- Android package ID is final.
- iOS bundle ID is final.
- App icon and splash screen are production-ready.
- Ads use production IDs only in release builds.
- No gambling, betting, pot money, or real-money reward language appears in the app or store listing.
- Privacy policy is published and linked in both stores.
- Android release signing is configured.
- iOS signing and provisioning are configured.
- Store screenshots and metadata are complete.
