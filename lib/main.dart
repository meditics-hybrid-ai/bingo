import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ads/admob_service.dart';
import 'audio/bingo_announcer.dart';
import 'game/bingo_game.dart';

const String appLogoAsset = 'assets/images/meditics_bingo_logo.png';
const List<Color> _bingoColumnColors = [
  Color(0xFFE93520),
  Color(0xFF1688F2),
  Color(0xFF26B425),
  Color(0xFFFFA000),
  Color(0xFF1857D8),
];

void main() {
  runApp(const MediticsBingoApp());
}

class MediticsBingoApp extends StatelessWidget {
  const MediticsBingoApp({super.key, this.announcer, this.adsService});

  final BingoAnnouncer? announcer;
  final AdsService? adsService;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meditics BINGO',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFFB300),
          brightness: Brightness.light,
        ),
        fontFamily: 'Arial',
        useMaterial3: true,
      ),
      home: BingoScreen(announcer: announcer, adsService: adsService),
    );
  }
}

class BingoScreen extends StatefulWidget {
  const BingoScreen({super.key, this.announcer, this.adsService});

  final BingoAnnouncer? announcer;
  final AdsService? adsService;

  @override
  State<BingoScreen> createState() => _BingoScreenState();
}

class _BingoScreenState extends State<BingoScreen> {
  final BingoGame _game = BingoGame();
  late final BingoAnnouncer _announcer =
      widget.announcer ?? TtsBingoAnnouncer();
  late final AdsService _adsService = widget.adsService ?? AdMobAdsService();
  Timer? _drawTimer;
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    unawaited(
      _adsService.initialize().then((_) {
        if (!mounted) {
          return;
        }
        _adsService.loadGameOverInterstitial();
      }),
    );
  }

  @override
  void dispose() {
    _drawTimer?.cancel();
    unawaited(_announcer.stop());
    _adsService.dispose();
    super.dispose();
  }

  void _startGame() {
    if (_isRunning || !_game.canDraw) {
      return;
    }

    int? calledNumber;
    setState(() {
      _isRunning = true;
      calledNumber = _game.drawNumber();
    });
    _announceGameStart(calledNumber);

    _drawTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted) {
        return;
      }

      if (!_game.canDraw) {
        _stopDrawing();
        return;
      }

      final calledNumber = _drawNumber();
      _announceNumber(calledNumber);

      if (!_game.canDraw) {
        _stopDrawing();
      }
    });
  }

  int? _drawNumber() {
    int? calledNumber;
    setState(() {
      calledNumber = _game.drawNumber();
    });
    return calledNumber;
  }

  void _stopDrawing() {
    _drawTimer?.cancel();
    _drawTimer = null;
    if (mounted && _isRunning) {
      setState(() {
        _isRunning = false;
      });
    } else {
      _isRunning = false;
    }
  }

  void _markCell(int index) {
    setState(() => _game.markCell(index));

    if (_game.hasBingo) {
      _stopDrawing();
      unawaited(_announcer.announceBingo());
      _adsService.showGameOverInterstitial();
    }
  }

  void _announceGameStart(int? calledNumber) {
    if (calledNumber == null) {
      return;
    }

    unawaited(() async {
      await _announcer.announceGameStart();
      if (!mounted || !_game.drawnNumbers.contains(calledNumber)) {
        return;
      }
      await _announcer.announceNumber(calledNumber);
    }());
  }

  void _announceNumber(int? calledNumber) {
    if (calledNumber == null) {
      return;
    }

    unawaited(_announcer.announceNumber(calledNumber));
  }

  Future<void> _requestNewGame() async {
    final shouldConfirm =
        _isRunning || _game.hasBingo || _game.drawnNumbers.isNotEmpty;
    if (!shouldConfirm) {
      _newGame();
      return;
    }

    final shouldReset = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Start a new game?'),
          content: const Text(
            'Are you sure you want to start a new game? Your current progress will be lost.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('New game'),
            ),
          ],
        );
      },
    );

    if (!mounted || shouldReset != true) {
      return;
    }

    _newGame();
  }

  void _newGame() {
    _drawTimer?.cancel();
    _drawTimer = null;
    unawaited(_announcer.stop());
    setState(() {
      _isRunning = false;
      _game.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF071044),
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(appLogoAsset, fit: BoxFit.cover),
          ),
        ),
        title: const Text(
          'Meditics BINGO',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            letterSpacing: 0,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF0B1D66),
        surfaceTintColor: Colors.transparent,
      ),
      body: Stack(
        children: [
          const _ArcadeBackdrop(),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final boardWidth = constraints.maxWidth
                    .clamp(0, 520)
                    .toDouble();

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 560),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const _AppLogo(),
                          const SizedBox(height: 14),
                          _StatusPanel(game: _game, isRunning: _isRunning),
                          const SizedBox(height: 16),
                          Center(
                            child: SizedBox(
                              width: boardWidth,
                              child: const _BingoHeader(),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Center(
                            child: SizedBox(
                              width: boardWidth,
                              child: _BingoBoard(
                                game: _game,
                                onCellTap: _markCell,
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          _GameActions(
                            canStart: !_isRunning && _game.canDraw,
                            hasBingo: _game.hasBingo,
                            isRunning: _isRunning,
                            onStart: _startGame,
                            onNewGame: () {
                              _requestNewGame();
                            },
                          ),
                          const SizedBox(height: 14),
                          _AdBanner(adsService: _adsService),
                          if (_adsService.isEnabled) const SizedBox(height: 14),
                          _DrawHistory(numbers: _game.drawnNumbers),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AdBanner extends StatefulWidget {
  const _AdBanner({required this.adsService});

  final AdsService adsService;

  @override
  State<_AdBanner> createState() => _AdBannerState();
}

class _AdBannerState extends State<_AdBanner> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    if (!widget.adsService.isEnabled) {
      return;
    }

    _bannerAd = widget.adsService.createBannerAd(
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) {
            setState(() => _isLoaded = true);
          }
        },
        onAdFailedToLoad: (ad, _) {
          ad.dispose();
          if (mounted) {
            setState(() {
              _bannerAd = null;
              _isLoaded = false;
            });
          }
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bannerAd = _bannerAd;
    if (!widget.adsService.isEnabled || bannerAd == null || !_isLoaded) {
      return const SizedBox.shrink();
    }

    return Center(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xEFFFFFFF),
          border: Border.all(color: const Color(0xFFFFC400), width: 2),
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(
              color: Color(0x44000000),
              blurRadius: 12,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: SizedBox(
            width: bannerAd.size.width.toDouble(),
            height: bannerAd.size.height.toDouble(),
            child: AdWidget(ad: bannerAd),
          ),
        ),
      ),
    );
  }
}

class _ArcadeBackdrop extends StatelessWidget {
  const _ArcadeBackdrop();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFB31312),
            Color(0xFFFF8F00),
            Color(0xFF0E7AC7),
            Color(0xFF061044),
          ],
          stops: [0, 0.28, 0.62, 1],
        ),
      ),
      child: SizedBox.expand(),
    );
  }
}

class _AppLogo extends StatelessWidget {
  const _AppLogo();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFFFD54F), width: 3),
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(
              color: Color(0x66000000),
              blurRadius: 22,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            appLogoAsset,
            width: 132,
            height: 132,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

class _StatusPanel extends StatelessWidget {
  const _StatusPanel({required this.game, required this.isRunning});

  final BingoGame game;
  final bool isRunning;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final currentNumber = game.currentNumber;
    final title = game.hasBingo
        ? 'BINGO!'
        : currentNumber == null
        ? 'Ready to play'
        : isRunning
        ? 'Drawing every 5 seconds'
        : 'Current number';

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: game.hasBingo
              ? const [Color(0xFFFFF176), Color(0xFF29D65D)]
              : const [Color(0xFFFFFFFF), Color(0xFFFFF4C6)],
        ),
        border: Border.all(color: const Color(0xFFFFC400), width: 3),
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x55000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                children: [
                  Text(
                    title,
                    style: textTheme.titleMedium?.copyWith(
                      color: const Color(0xFF102261),
                      fontWeight: FontWeight.w900,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    game.hasBingo
                        ? 'You completed a winning line.'
                        : currentNumber == null
                        ? 'Tap Start to begin.'
                        : 'Tap the matching number on your card.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF26335F),
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            _NumberBall(
              label: game.hasBingo
                  ? 'WIN'
                  : currentNumber == null
                  ? 'GO'
                  : _formatBingoNumber(currentNumber),
              isWin: game.hasBingo,
            ),
          ],
        ),
      ),
    );
  }
}

class _NumberBall extends StatelessWidget {
  const _NumberBall({required this.label, required this.isWin});

  final String label;
  final bool isWin;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isWin
              ? const [Color(0xFFFFF176), Color(0xFFFF6F00)]
              : const [Color(0xFF25D7FF), Color(0xFF164DDB)],
        ),
        border: Border.all(color: Colors.white, width: 4),
        boxShadow: const [
          BoxShadow(
            color: Color(0x55000000),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: SizedBox(
        width: 86,
        height: 86,
        child: Center(
          child: Text(
            label,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontSize: label.length > 3 ? 22 : 26,
              fontWeight: FontWeight.w900,
              shadows: const [
                Shadow(
                  color: Color(0x99000000),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class _BingoHeader extends StatelessWidget {
  const _BingoHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: 'BINGO'.characters.indexed.map((entry) {
        final index = entry.$1;
        final letter = entry.$2;
        final color = _bingoColumnColors[index];
        return Expanded(
          child: Center(
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [color.withValues(alpha: 0.82), color],
                ),
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x55000000),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: SizedBox(
                width: 48,
                height: 48,
                child: Center(
                  child: Text(
                    letter,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _BingoBoard extends StatelessWidget {
  const _BingoBoard({required this.game, required this.onCellTap});

  final BingoGame game;
  final ValueChanged<int> onCellTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFFFFF), Color(0xFFFFD54F), Color(0xFF0B2C91)],
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: AspectRatio(
          aspectRatio: 1,
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            itemCount: game.card.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: bingoBoardSize,
              crossAxisSpacing: 6,
              mainAxisSpacing: 6,
            ),
            itemBuilder: (context, index) {
              final cell = game.card[index];
              final isMarked = game.markedIndexes.contains(index);
              final canMark = game.canMarkCell(index);
              return _BingoCellTile(
                cell: cell,
                index: index,
                isMarked: isMarked,
                canMark: canMark,
                onTap: () => onCellTap(index),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _BingoCellTile extends StatelessWidget {
  const _BingoCellTile({
    required this.cell,
    required this.index,
    required this.isMarked,
    required this.canMark,
    required this.onTap,
  });

  final BingoCell cell;
  final int index;
  final bool isMarked;
  final bool canMark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final columnColor = _bingoColumnColors[index % bingoBoardSize];
    final foreground = isMarked ? Colors.white : const Color(0xFF17201D);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isMarked ? null : onTap,
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isMarked
                  ? [columnColor.withValues(alpha: 0.95), columnColor]
                  : const [Color(0xFFFFFDF2), Color(0xFFFFE7A3)],
            ),
            border: Border.all(
              color: canMark
                  ? const Color(0xFFFFF176)
                  : isMarked
                  ? Colors.white
                  : const Color(0xFFFFB300),
              width: canMark || isMarked ? 3 : 1.5,
            ),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: canMark
                    ? const Color(0x99FFD54F)
                    : const Color(0x33000000),
                blurRadius: canMark ? 12 : 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: Text(
              cell.isFreeSpace ? 'FREE' : '${cell.label}',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: foreground,
                fontSize: cell.isFreeSpace ? 15 : null,
                fontWeight: FontWeight.w900,
                shadows: isMarked
                    ? const [
                        Shadow(
                          color: Color(0x88000000),
                          blurRadius: 3,
                          offset: Offset(0, 1),
                        ),
                      ]
                    : null,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

class _GameActions extends StatelessWidget {
  const _GameActions({
    required this.canStart,
    required this.hasBingo,
    required this.isRunning,
    required this.onStart,
    required this.onNewGame,
  });

  final bool canStart;
  final bool hasBingo;
  final bool isRunning;
  final VoidCallback onStart;
  final VoidCallback onNewGame;

  @override
  Widget build(BuildContext context) {
    final startGradient = isRunning
        ? const [Color(0xFF1E88E5), Color(0xFF00C2FF)]
        : const [Color(0xFFFFD54F), Color(0xFFFF6D00)];

    return Row(
      children: [
        Expanded(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: startGradient),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x66000000),
                  blurRadius: 14,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: FilledButton.icon(
              onPressed: canStart ? onStart : null,
              icon: Icon(isRunning ? Icons.hourglass_top : Icons.play_arrow),
              label: Text(
                hasBingo
                    ? 'Game Complete'
                    : isRunning
                    ? 'Running'
                    : 'Start',
              ),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.transparent,
                disabledBackgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                disabledForegroundColor: Colors.white70,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFF1744), Color(0xFFD50000)],
            ),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: const [
              BoxShadow(
                color: Color(0x66000000),
                blurRadius: 14,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: IconButton(
            onPressed: onNewGame,
            tooltip: 'New game',
            color: Colors.white,
            icon: const Icon(Icons.refresh),
          ),
        ),
      ],
    );
  }
}

class _DrawHistory extends StatelessWidget {
  const _DrawHistory({required this.numbers});

  final List<int> numbers;

  @override
  Widget build(BuildContext context) {
    final latestNumbers = numbers.reversed.take(12).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xEFFFFFFF),
            border: Border.all(color: const Color(0xFFFFC400), width: 2),
            borderRadius: BorderRadius.circular(8),
            boxShadow: const [
              BoxShadow(
                color: Color(0x44000000),
                blurRadius: 12,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recent draws',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: const Color(0xFF0B1D66),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                if (latestNumbers.isEmpty)
                  const Text(
                    'No numbers drawn yet.',
                    style: TextStyle(
                      color: Color(0xFF26335F),
                      fontWeight: FontWeight.w700,
                    ),
                  )
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: latestNumbers.map((number) {
                      final color =
                          _bingoColumnColors[_columnIndexForNumber(number)];
                      return DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [color.withValues(alpha: 0.85), color],
                          ),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          child: Text(
                            _formatBingoNumber(number),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

String _formatBingoNumber(int number) {
  final letter = bingoLetterForNumber(number);
  return '$letter-$number';
}

int _columnIndexForNumber(int number) {
  if (number <= 15) {
    return 0;
  }
  if (number <= 30) {
    return 1;
  }
  if (number <= 45) {
    return 2;
  }
  if (number <= 60) {
    return 3;
  }
  return 4;
}
