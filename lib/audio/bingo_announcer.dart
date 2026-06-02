import 'package:flutter_tts/flutter_tts.dart';

import '../game/bingo_game.dart';

abstract class BingoAnnouncer {
  Future<void> announceGameStart();
  Future<void> announceNumber(int number);
  Future<void> announceBingo();
  Future<void> stop();
}

class TtsBingoAnnouncer implements BingoAnnouncer {
  TtsBingoAnnouncer({FlutterTts? tts}) : _tts = tts ?? FlutterTts();

  final FlutterTts _tts;
  bool _isConfigured = false;

  Future<void> _configure() async {
    if (_isConfigured) {
      return;
    }

    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.45);
    await _tts.setPitch(1.0);
    await _tts.setVolume(1.0);
    await _tts.awaitSpeakCompletion(true);
    _isConfigured = true;
  }

  @override
  Future<void> announceGameStart() {
    return _speak('Game started');
  }

  @override
  Future<void> announceNumber(int number) {
    final letter = bingoLetterForNumber(number);
    return _speak('$letter $number');
  }

  @override
  Future<void> announceBingo() {
    return _speak('Bingo! You win!');
  }

  @override
  Future<void> stop() async {
    await _tts.stop();
  }

  Future<void> _speak(String text) async {
    await _configure();
    await _tts.stop();
    await _tts.speak(text);
  }
}

class SilentBingoAnnouncer implements BingoAnnouncer {
  const SilentBingoAnnouncer();

  @override
  Future<void> announceBingo() async {}

  @override
  Future<void> announceGameStart() async {}

  @override
  Future<void> announceNumber(int number) async {}

  @override
  Future<void> stop() async {}
}
