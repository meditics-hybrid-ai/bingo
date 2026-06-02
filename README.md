# Meditics BINGO

Meditics BINGO is a simple single-player bingo game built with Flutter and Dart. The app is designed for offline play with no remote database, no backend, and no pot money or gambling mechanics.

## App Summary

- App name: Meditics BINGO
- Platform: Android and iOS
- Codebase: Flutter / Dart
- Game mode: Single player
- Backend: None
- Remote database: None
- Monetization: Ads
- Distribution: Google Play Store and Apple App Store

## Product Goals

1. Deliver a lightweight bingo experience that works fully on-device.
2. Keep gameplay simple, fast, and suitable for casual sessions.
3. Avoid gambling mechanics, cash prizes, pot money, player accounts, and server-side dependencies.
4. Monetize through non-intrusive ads while keeping the core game playable.
5. Prepare the app for both Google Play Store and Apple App Store release.

## Core Features

- Generate a randomized bingo card for each game.
- Start the game with a single Start button.
- Draw numbers locally from a randomized pool every 5 seconds after the game starts.
- Announce the game start with audio.
- Announce each called number with audio, such as `B 9`.
- Announce the win when BINGO is achieved.
- Require the player to manually tap matching numbers on the bingo card.
- Prevent marking numbers that have not been drawn yet.
- Detect valid bingo patterns.
- Show win state when the player completes a valid pattern.
- Ask for confirmation before refreshing a started or completed game.
- Store simple local preferences, such as sound, vibration, and ad consent settings if needed.
- Display ads in appropriate places, such as after completed games or from an optional rewarded placement.

## Current Gameplay

1. The player starts with a fresh randomized 5x5 bingo card.
2. The center space is marked as `FREE`.
3. The player taps `Start` to begin the game.
4. The app announces that the game has started.
5. The app draws the first number immediately, announces it, then continues drawing and announcing one number every 5 seconds.
6. The player manually taps a card cell to mark it.
7. A cell can only be marked if its number has already been drawn.
8. The app checks rows, columns, and diagonals after each valid mark.
9. The draw timer stops when the player completes BINGO.
10. The app announces the BINGO win.
11. If the game has started or ended, tapping refresh asks for confirmation before starting a new game.

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
- Add automatic 5-second number drawing after Start. Done.
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

- Integrate a mobile ads SDK.
- Choose ad placements that do not interrupt active gameplay.
- Add test ads during development.
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
