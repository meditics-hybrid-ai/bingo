import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:meditics_bingo/game/bingo_game.dart';

void main() {
  test('generates a valid 5x5 bingo card with a free center space', () {
    final game = BingoGame(random: Random(1));

    expect(game.card, hasLength(25));
    expect(game.card[bingoFreeSpaceIndex].isFreeSpace, isTrue);
    expect(game.card[bingoFreeSpaceIndex].label, isNull);
    expect(game.markedIndexes, contains(bingoFreeSpaceIndex));

    for (var row = 0; row < bingoBoardSize; row++) {
      expect(game.card[row * bingoBoardSize].label, inInclusiveRange(1, 15));
      expect(
        game.card[row * bingoBoardSize + 1].label,
        inInclusiveRange(16, 30),
      );
      if (row != 2) {
        expect(
          game.card[row * bingoBoardSize + 2].label,
          inInclusiveRange(31, 45),
        );
      }
      expect(
        game.card[row * bingoBoardSize + 3].label,
        inInclusiveRange(46, 60),
      );
      expect(
        game.card[row * bingoBoardSize + 4].label,
        inInclusiveRange(61, 75),
      );
    }
  });

  test('marks matching numbers as they are drawn', () {
    final game = BingoGame(random: Random(2));
    final firstCellNumber = game.card.first.label!;

    game.drawPool = [firstCellNumber];

    expect(game.drawNumber(), firstCellNumber);
    expect(game.markedIndexes, contains(0));
    expect(game.drawnNumbers, contains(firstCellNumber));
  });

  test('detects bingo after a completed row is drawn', () {
    final game = BingoGame(random: Random(3));
    final firstRowNumbers = game.card
        .take(bingoBoardSize)
        .map((cell) => cell.label!)
        .toList();

    game.drawPool = firstRowNumbers.reversed.toList();

    for (var index = 0; index < firstRowNumbers.length; index++) {
      game.drawNumber();
    }

    expect(game.hasBingo, isTrue);
    expect(game.canDraw, isFalse);
  });
}
