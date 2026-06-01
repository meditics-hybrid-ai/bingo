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
- Draw numbers locally from a randomized pool.
- Mark matching numbers on the bingo card.
- Detect valid bingo patterns.
- Show win state when the player completes a valid pattern.
- Start a new game at any time.
- Store simple local preferences, such as sound, vibration, and ad consent settings if needed.
- Display ads in appropriate places, such as after completed games or from an optional rewarded placement.

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

- Build the bingo card generator.
- Build the number draw engine.
- Track marked cells and drawn numbers.
- Implement bingo pattern detection.
- Add unit tests for card generation, number drawing, and win detection.

### Phase 3: Gameplay UI

- Design the main game screen.
- Add card grid, drawn number display, draw button, reset button, and win state.
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
