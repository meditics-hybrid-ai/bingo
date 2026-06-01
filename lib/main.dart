import 'dart:async';

import 'package:flutter/material.dart';

import 'game/bingo_game.dart';

void main() {
  runApp(const MediticsBingoApp());
}

class MediticsBingoApp extends StatelessWidget {
  const MediticsBingoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meditics BINGO',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E6F5C),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const BingoScreen(),
    );
  }
}

class BingoScreen extends StatefulWidget {
  const BingoScreen({super.key});

  @override
  State<BingoScreen> createState() => _BingoScreenState();
}

class _BingoScreenState extends State<BingoScreen> {
  final BingoGame _game = BingoGame();
  Timer? _drawTimer;
  bool _isRunning = false;

  @override
  void dispose() {
    _drawTimer?.cancel();
    super.dispose();
  }

  void _startGame() {
    if (_isRunning || !_game.canDraw) {
      return;
    }

    setState(() {
      _isRunning = true;
      _game.drawNumber();
    });

    _drawTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted) {
        return;
      }

      if (!_game.canDraw) {
        _stopDrawing();
        return;
      }

      setState(_game.drawNumber);

      if (!_game.canDraw) {
        _stopDrawing();
      }
    });
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
    }
  }

  void _newGame() {
    _drawTimer?.cancel();
    _drawTimer = null;
    setState(() {
      _isRunning = false;
      _game.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F2),
      appBar: AppBar(
        title: const Text('Meditics BINGO'),
        centerTitle: true,
        backgroundColor: colorScheme.surface,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final boardWidth = constraints.maxWidth.clamp(0, 520).toDouble();

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
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
                          child: _BingoBoard(game: _game, onCellTap: _markCell),
                        ),
                      ),
                      const SizedBox(height: 18),
                      _GameActions(
                        canStart: !_isRunning && _game.canDraw,
                        hasBingo: _game.hasBingo,
                        isRunning: _isRunning,
                        onStart: _startGame,
                        onNewGame: _newGame,
                      ),
                      const SizedBox(height: 14),
                      _DrawHistory(numbers: _game.drawnNumbers),
                    ],
                  ),
                ),
              ),
            );
          },
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
    final colorScheme = Theme.of(context).colorScheme;
    final currentNumber = game.currentNumber;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: game.hasBingo ? const Color(0xFFEAF6EC) : Colors.white,
        border: Border.all(
          color: game.hasBingo ? const Color(0xFF2E7D32) : colorScheme.outline,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              game.hasBingo
                  ? 'BINGO!'
                  : currentNumber == null
                  ? 'Ready to play'
                  : isRunning
                  ? 'Drawing every 5 seconds'
                  : 'Current number',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              game.hasBingo
                  ? 'You completed a winning line.'
                  : currentNumber == null
                  ? 'Tap Start to begin.'
                  : _formatBingoNumber(currentNumber),
              style: textTheme.headlineSmall?.copyWith(
                color: game.hasBingo
                    ? const Color(0xFF2E7D32)
                    : colorScheme.primary,
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
            ),
          ],
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
      children: 'BINGO'.characters.map((letter) {
        return Expanded(
          child: Center(
            child: Text(
              letter,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
                color: const Color(0xFF12352F),
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
    return AspectRatio(
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
            isMarked: isMarked,
            canMark: canMark,
            onTap: () => onCellTap(index),
          );
        },
      ),
    );
  }
}

class _BingoCellTile extends StatelessWidget {
  const _BingoCellTile({
    required this.cell,
    required this.isMarked,
    required this.canMark,
    required this.onTap,
  });

  final BingoCell cell;
  final bool isMarked;
  final bool canMark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isMarked ? const Color(0xFF1E6F5C) : Colors.white;
    final foreground = isMarked ? Colors.white : const Color(0xFF17201D);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isMarked ? null : onTap,
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: color,
            border: Border.all(
              color: canMark
                  ? const Color(0xFFE6A700)
                  : const Color(0xFFB8C2B4),
              width: canMark ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              if (!isMarked)
                const BoxShadow(
                  color: Color(0x14000000),
                  blurRadius: 8,
                  offset: Offset(0, 2),
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
    return Row(
      children: [
        Expanded(
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
          ),
        ),
        const SizedBox(width: 10),
        IconButton.filledTonal(
          onPressed: onNewGame,
          tooltip: 'New game',
          icon: const Icon(Icons.refresh),
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
        Text(
          'Recent draws',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        if (latestNumbers.isEmpty)
          const Text('No numbers drawn yet.')
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: latestNumbers.map((number) {
              return Chip(
                label: Text(_formatBingoNumber(number)),
                visualDensity: VisualDensity.compact,
              );
            }).toList(),
          ),
      ],
    );
  }
}

String _formatBingoNumber(int number) {
  final letter = switch (number) {
    >= 1 && <= 15 => 'B',
    >= 16 && <= 30 => 'I',
    >= 31 && <= 45 => 'N',
    >= 46 && <= 60 => 'G',
    _ => 'O',
  };
  return '$letter-$number';
}
