import 'dart:math';

const int bingoBoardSize = 5;
const int bingoFreeSpaceIndex = 12;

class BingoCell {
  const BingoCell({required this.label, required this.isFreeSpace});

  final int? label;
  final bool isFreeSpace;
}

class BingoGame {
  BingoGame({Random? random}) : _random = random ?? Random() {
    reset();
  }

  final Random _random;

  late List<BingoCell> card;
  late Set<int> markedIndexes;
  late List<int> drawPool;
  late List<int> drawnNumbers;
  bool hasBingo = false;

  int? get currentNumber => drawnNumbers.isEmpty ? null : drawnNumbers.last;

  bool get canDraw => drawPool.isNotEmpty && !hasBingo;

  void reset() {
    card = _generateCard();
    markedIndexes = {bingoFreeSpaceIndex};
    drawPool = List<int>.generate(75, (index) => index + 1)..shuffle(_random);
    drawnNumbers = [];
    hasBingo = false;
  }

  int? drawNumber() {
    if (!canDraw) {
      return null;
    }

    final number = drawPool.removeLast();
    drawnNumbers.add(number);

    for (var index = 0; index < card.length; index++) {
      if (card[index].label == number) {
        markedIndexes.add(index);
      }
    }

    hasBingo = _checkBingo();
    return number;
  }

  List<BingoCell> _generateCard() {
    final columns = [
      _randomColumn(1, 15),
      _randomColumn(16, 30),
      _randomColumn(31, 45),
      _randomColumn(46, 60),
      _randomColumn(61, 75),
    ];

    final cells = <BingoCell>[];
    for (var row = 0; row < bingoBoardSize; row++) {
      for (var column = 0; column < bingoBoardSize; column++) {
        final index = row * bingoBoardSize + column;
        cells.add(
          BingoCell(
            label: index == bingoFreeSpaceIndex ? null : columns[column][row],
            isFreeSpace: index == bingoFreeSpaceIndex,
          ),
        );
      }
    }

    return cells;
  }

  List<int> _randomColumn(int min, int max) {
    final values = List<int>.generate(max - min + 1, (index) => min + index)
      ..shuffle(_random);
    return values.take(bingoBoardSize).toList();
  }

  bool _checkBingo() {
    for (var row = 0; row < bingoBoardSize; row++) {
      final rowIndexes = List<int>.generate(
        bingoBoardSize,
        (column) => row * bingoBoardSize + column,
      );
      if (rowIndexes.every(markedIndexes.contains)) {
        return true;
      }
    }

    for (var column = 0; column < bingoBoardSize; column++) {
      final columnIndexes = List<int>.generate(
        bingoBoardSize,
        (row) => row * bingoBoardSize + column,
      );
      if (columnIndexes.every(markedIndexes.contains)) {
        return true;
      }
    }

    const diagonals = [
      [0, 6, 12, 18, 24],
      [4, 8, 12, 16, 20],
    ];

    return diagonals.any((indexes) => indexes.every(markedIndexes.contains));
  }
}
