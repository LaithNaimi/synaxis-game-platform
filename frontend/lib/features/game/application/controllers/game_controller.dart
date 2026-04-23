import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/websocket_client.dart';
import '../../../../core/network/ws_destinations.dart';
import '../state/game_state.dart';

class GameController extends Notifier<GameState> {
  @override
  GameState build() => const GameState();

  WebSocketClient? _ws;
  String _roomCode = '';
  String _playerId = '';
  String _playerToken = '';

  void initRound({
    required WebSocketClient ws,
    required String roomCode,
    required String playerId,
    required String playerToken,
    required int roundNumber,
    required int totalRounds,
    required String maskedWord,
    required int roundDurationSeconds,
  }) {
    _ws = ws;
    _roomCode = roomCode;
    _playerId = playerId;
    _playerToken = playerToken;

    state = GameState(
      roundNumber: roundNumber,
      totalRounds: totalRounds,
      maskedWord: maskedWord,
      roundDurationSeconds: roundDurationSeconds,
      roundStartedAt: DateTime.now(),
    );
  }

  void guessLetter(String letter) {
    if (state.inputBlocked) return;
    if (state.guessedLetters.contains(letter.toLowerCase())) return;
    if (_ws == null || !_ws!.connected) return;

    _ws!.sendJson(
      destination: WsDestinations.guessLetterCommand(),
      body: {
        'roomCode': _roomCode,
        'playerId': _playerId,
        'playerToken': _playerToken,
        'letter': letter.toLowerCase(),
      },
    );
  }

  // ── Event handlers called by LobbyController ──

  void onPlayerRoundState(Map<String, dynamic> json) {
    final guessed = _parseCharSet(json['guessedLetters']);
    final correct = _parseCharSet(json['correctLetters']);
    final wrong = _parseCharSet(json['wrongLetters']);

    state = state.copyWith(
      maskedWord: json['maskedWord'] as String? ?? state.maskedWord,
      guessedLetters: guessed,
      correctLetters: correct,
      wrongLetters: wrong,
      solved: json['solved'] as bool? ?? state.solved,
      currentScore: json['currentScore'] as int? ?? state.currentScore,
      scoreDelta: json['scoreDelta'] as int? ?? 0,
      currentHealth: json['currentHealth'] as int? ?? state.currentHealth,
      healthDelta: json['healthDelta'] as int? ?? 0,
      penaltyScoreDelta: json['penaltyScoreDelta'] as int? ?? 0,
      stunned: json['stunned'] as bool? ?? state.stunned,
    );
  }

  void onLetterGuessResult(Map<String, dynamic> json) {
    state = state.copyWith(
      scoreDelta: json['scoreDelta'] as int? ?? 0,
    );
  }

  void onPlayerStunned(Map<String, dynamic> json) {
    final until = json['stunnedUntil'] as String?;
    state = state.copyWith(
      stunned: true,
      stunnedUntil: () => until != null ? DateTime.parse(until) : null,
    );
  }

  void onPlayerRecovered(Map<String, dynamic> json) {
    state = state.copyWith(
      stunned: false,
      stunnedUntil: () => null,
      currentHealth: json['restoredHealth'] as int? ?? state.currentHealth,
    );
  }

  void onPlayerSolvedWord() {
    state = state.copyWith(solved: true);
  }

  void onSuddenDeathStarted(Map<String, dynamic> json) {
    final at = json['suddenDeathAt'] as String?;
    state = state.copyWith(
      suddenDeath: true,
      suddenDeathAt: () => at != null ? DateTime.parse(at) : null,
    );
  }

  void onSuddenDeathEnded() {
    state = state.copyWith(
      suddenDeathEnded: true,
      roundEnded: true,
    );
  }

  void onRoundTimeout() {
    state = state.copyWith(
      roundTimedOut: true,
      roundEnded: true,
    );
  }

  void onLearningReveal(Map<String, dynamic> json) {
    final payload = json['payload'] as Map<String, dynamic>;
    state = state.copyWith(
      roundEnded: true,
      learningReveal: () => LearningRevealData.fromJson(payload),
    );
  }

  void onRoundLeaderboard(Map<String, dynamic> json) {
    final payload = json['payload'] as Map<String, dynamic>;
    state = state.copyWith(
      roundLeaderboard: () => RoundLeaderboardData.fromJson(payload),
    );
  }

  void onMatchFinished() {
    state = state.copyWith(matchFinished: true);
  }

  void onFinalLeaderboard(Map<String, dynamic> json) {
    final payload = json['payload'] as Map<String, dynamic>;
    state = state.copyWith(
      matchFinished: true,
      finalLeaderboard: () => RoundLeaderboardData.fromJson(payload),
    );
  }

  void resetForNextRound() {
    state = const GameState();
  }

  Set<String> _parseCharSet(dynamic value) {
    if (value is List) {
      return value.map((e) => e.toString().toLowerCase()).toSet();
    }
    return {};
  }
}
