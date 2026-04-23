class GameState {
  const GameState({
    this.roundNumber = 0,
    this.totalRounds = 0,
    this.maskedWord = '',
    this.guessedLetters = const {},
    this.correctLetters = const {},
    this.wrongLetters = const {},
    this.solved = false,
    this.currentScore = 0,
    this.scoreDelta = 0,
    this.currentHealth = 100,
    this.healthDelta = 0,
    this.penaltyScoreDelta = 0,
    this.stunned = false,
    this.stunnedUntil,
    this.roundDurationSeconds = 60,
    this.roundStartedAt,
    this.roundTimedOut = false,
    this.suddenDeath = false,
    this.suddenDeathAt,
    this.suddenDeathEnded = false,
    this.roundEnded = false,
    this.learningReveal,
    this.roundLeaderboard,
    this.matchFinished = false,
    this.finalLeaderboard,
  });

  final int roundNumber;
  final int totalRounds;
  final String maskedWord;
  final Set<String> guessedLetters;
  final Set<String> correctLetters;
  final Set<String> wrongLetters;
  final bool solved;
  final int currentScore;
  final int scoreDelta;
  final int currentHealth;
  final int healthDelta;
  final int penaltyScoreDelta;
  final bool stunned;
  final DateTime? stunnedUntil;
  final int roundDurationSeconds;
  final DateTime? roundStartedAt;
  final bool roundTimedOut;
  final bool suddenDeath;
  final DateTime? suddenDeathAt;
  final bool suddenDeathEnded;
  final bool roundEnded;
  final LearningRevealData? learningReveal;
  final RoundLeaderboardData? roundLeaderboard;
  final bool matchFinished;
  final RoundLeaderboardData? finalLeaderboard;

  bool get inputBlocked =>
      solved || stunned || roundTimedOut || suddenDeathEnded || roundEnded;

  GameState copyWith({
    int? roundNumber,
    int? totalRounds,
    String? maskedWord,
    Set<String>? guessedLetters,
    Set<String>? correctLetters,
    Set<String>? wrongLetters,
    bool? solved,
    int? currentScore,
    int? scoreDelta,
    int? currentHealth,
    int? healthDelta,
    int? penaltyScoreDelta,
    bool? stunned,
    DateTime? Function()? stunnedUntil,
    int? roundDurationSeconds,
    DateTime? Function()? roundStartedAt,
    bool? roundTimedOut,
    bool? suddenDeath,
    DateTime? Function()? suddenDeathAt,
    bool? suddenDeathEnded,
    bool? roundEnded,
    LearningRevealData? Function()? learningReveal,
    RoundLeaderboardData? Function()? roundLeaderboard,
    bool? matchFinished,
    RoundLeaderboardData? Function()? finalLeaderboard,
  }) {
    return GameState(
      roundNumber: roundNumber ?? this.roundNumber,
      totalRounds: totalRounds ?? this.totalRounds,
      maskedWord: maskedWord ?? this.maskedWord,
      guessedLetters: guessedLetters ?? this.guessedLetters,
      correctLetters: correctLetters ?? this.correctLetters,
      wrongLetters: wrongLetters ?? this.wrongLetters,
      solved: solved ?? this.solved,
      currentScore: currentScore ?? this.currentScore,
      scoreDelta: scoreDelta ?? this.scoreDelta,
      currentHealth: currentHealth ?? this.currentHealth,
      healthDelta: healthDelta ?? this.healthDelta,
      penaltyScoreDelta: penaltyScoreDelta ?? this.penaltyScoreDelta,
      stunned: stunned ?? this.stunned,
      stunnedUntil: stunnedUntil != null ? stunnedUntil() : this.stunnedUntil,
      roundDurationSeconds: roundDurationSeconds ?? this.roundDurationSeconds,
      roundStartedAt:
          roundStartedAt != null ? roundStartedAt() : this.roundStartedAt,
      roundTimedOut: roundTimedOut ?? this.roundTimedOut,
      suddenDeath: suddenDeath ?? this.suddenDeath,
      suddenDeathAt:
          suddenDeathAt != null ? suddenDeathAt() : this.suddenDeathAt,
      suddenDeathEnded: suddenDeathEnded ?? this.suddenDeathEnded,
      roundEnded: roundEnded ?? this.roundEnded,
      learningReveal:
          learningReveal != null ? learningReveal() : this.learningReveal,
      roundLeaderboard:
          roundLeaderboard != null ? roundLeaderboard() : this.roundLeaderboard,
      matchFinished: matchFinished ?? this.matchFinished,
      finalLeaderboard:
          finalLeaderboard != null ? finalLeaderboard() : this.finalLeaderboard,
    );
  }
}

class LearningRevealData {
  const LearningRevealData({
    required this.roundNumber,
    required this.word,
    required this.arabicMeaning,
    required this.englishDefinition,
  });

  final int roundNumber;
  final String word;
  final String arabicMeaning;
  final String englishDefinition;

  factory LearningRevealData.fromJson(Map<String, dynamic> json) {
    return LearningRevealData(
      roundNumber: json['roundNumber'] as int,
      word: json['word'] as String,
      arabicMeaning: json['arabicMeaning'] as String,
      englishDefinition: json['englishDefinition'] as String,
    );
  }
}

class LeaderboardEntry {
  const LeaderboardEntry({
    required this.playerId,
    required this.playerName,
    required this.score,
    required this.health,
    required this.totalSolveTimeMs,
    required this.rank,
  });

  final String playerId;
  final String playerName;
  final int score;
  final int health;
  final int totalSolveTimeMs;
  final int rank;

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      playerId: json['playerId'] as String,
      playerName: json['playerName'] as String,
      score: json['score'] as int,
      health: json['health'] as int,
      totalSolveTimeMs: json['totalSolveTimeMs'] as int,
      rank: json['rank'] as int,
    );
  }
}

class RoundLeaderboardData {
  const RoundLeaderboardData({
    this.roundNumber,
    required this.entries,
  });

  final int? roundNumber;
  final List<LeaderboardEntry> entries;

  factory RoundLeaderboardData.fromJson(Map<String, dynamic> json) {
    return RoundLeaderboardData(
      roundNumber: json['roundNumber'] as int?,
      entries: (json['entries'] as List<dynamic>)
          .map((e) => LeaderboardEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
