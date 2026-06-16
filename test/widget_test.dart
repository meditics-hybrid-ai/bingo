import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:meditics_bingo/ads/admob_service.dart';
import 'package:meditics_bingo/audio/bingo_announcer.dart';
import 'package:meditics_bingo/config/app_update_checker.dart';
import 'package:meditics_bingo/main.dart';

const _noOpAdsService = NoOpAdsService();
const _noOpUpdateChecker = _NoOpUpdateChecker();

void main() {
  testWidgets('starts automatic bingo drawing', (tester) async {
    await tester.pumpWidget(
      const MediticsBingoApp(
        announcer: SilentBingoAnnouncer(),
        adsService: _noOpAdsService,
        updateChecker: _noOpUpdateChecker,
      ),
    );

    expect(find.text('Meditics BINGO'), findsOneWidget);
    expect(find.text('Ready to play'), findsNothing);
    expect(find.text('Start'), findsOneWidget);
    expect(find.text('FREE'), findsOneWidget);

    await tester.ensureVisible(find.text('Start'));
    await tester.tap(find.byIcon(Icons.play_arrow));
    await tester.pump();

    expect(find.text('Drawing every 8 seconds'), findsOneWidget);
    expect(find.text('Running'), findsOneWidget);
    expect(find.text('No numbers drawn yet.'), findsNothing);
  });

  testWidgets('confirms refresh after game has started', (tester) async {
    await tester.pumpWidget(
      const MediticsBingoApp(
        announcer: SilentBingoAnnouncer(),
        adsService: _noOpAdsService,
        updateChecker: _noOpUpdateChecker,
      ),
    );

    await tester.ensureVisible(find.text('Start'));
    await tester.tap(find.byIcon(Icons.play_arrow));
    await tester.pump();

    await tester.tap(find.byIcon(Icons.refresh));
    await tester.pumpAndSettle();

    expect(find.text('Start a new game?'), findsOneWidget);
    expect(
      find.text(
        'Are you sure you want to start a new game? Your current progress will be lost.',
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('Start a new game?'), findsNothing);
    expect(find.text('Running'), findsOneWidget);
  });

  testWidgets('announces game start and first number', (tester) async {
    final announcer = _RecordingBingoAnnouncer();

    await tester.pumpWidget(
      MediticsBingoApp(
        announcer: announcer,
        adsService: _noOpAdsService,
        updateChecker: _noOpUpdateChecker,
      ),
    );

    await tester.ensureVisible(find.text('Start'));
    await tester.tap(find.byIcon(Icons.play_arrow));
    await tester.pump();

    expect(announcer.events.first, 'start');
    expect(
      announcer.events.where((event) => event.startsWith('number:')),
      hasLength(1),
    );
  });

  testWidgets('shows update dialog when remote config has newer version', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MediticsBingoApp(
        announcer: SilentBingoAnnouncer(),
        adsService: _noOpAdsService,
        updateChecker: _AvailableUpdateChecker(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Update available'), findsOneWidget);
    expect(find.text('Continue playing'), findsOneWidget);

    await tester.tap(find.text('Continue playing'));
    await tester.pumpAndSettle();

    expect(find.text('Update available'), findsNothing);
    expect(find.text('Start'), findsOneWidget);
  });

  testWidgets('uses softer title for required update dialog', (tester) async {
    await tester.pumpWidget(
      const MediticsBingoApp(
        announcer: SilentBingoAnnouncer(),
        adsService: _noOpAdsService,
        updateChecker: _RequiredUpdateChecker(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('New version available'), findsOneWidget);
    expect(find.text('Update required'), findsNothing);
    expect(find.text('Continue playing'), findsNothing);
  });
}

class _RecordingBingoAnnouncer implements BingoAnnouncer {
  final List<String> events = [];

  @override
  Future<void> announceBingo() async {
    events.add('bingo');
  }

  @override
  Future<void> announceGameStart() async {
    events.add('start');
  }

  @override
  Future<void> announceNumber(int number) async {
    events.add('number:$number');
  }

  @override
  Future<void> stop() async {
    events.add('stop');
  }
}

class _NoOpUpdateChecker implements AppUpdateChecker {
  const _NoOpUpdateChecker();

  @override
  Future<AppUpdateStatus> checkForUpdate() async {
    return AppUpdateStatus.upToDate();
  }
}

class _AvailableUpdateChecker implements AppUpdateChecker {
  const _AvailableUpdateChecker();

  @override
  Future<AppUpdateStatus> checkForUpdate() async {
    return const AppUpdateStatus(
      needsUpdate: true,
      isRequired: false,
      latestVersion: '1.1.0',
      message: 'A newer version of Meditics BINGO is available.',
    );
  }
}

class _RequiredUpdateChecker implements AppUpdateChecker {
  const _RequiredUpdateChecker();

  @override
  Future<AppUpdateStatus> checkForUpdate() async {
    return const AppUpdateStatus(
      needsUpdate: true,
      isRequired: true,
      latestVersion: '1.1.0',
      updateUrl: 'https://example.com/update',
      message: 'A newer version of Meditics BINGO is available.',
    );
  }
}
