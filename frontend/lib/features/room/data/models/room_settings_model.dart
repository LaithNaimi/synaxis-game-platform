class RoomSettingsModel {
  const RoomSettingsModel({
    required this.cefrLevel,
    required this.maxPlayers,
    required this.totalRounds,
    required this.roundDurationSeconds,
  });

  final String cefrLevel;
  final int maxPlayers;
  final int totalRounds;
  final int roundDurationSeconds;

  factory RoomSettingsModel.fromJson(Map<String, dynamic> json) {
    return RoomSettingsModel(
      cefrLevel: json['cefrLevel'] as String,
      maxPlayers: json['maxPlayers'] as int,
      totalRounds: json['totalRounds'] as int,
      roundDurationSeconds: json['roundDurationSeconds'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'cefrLevel': cefrLevel,
        'maxPlayers': maxPlayers,
        'totalRounds': totalRounds,
        'roundDurationSeconds': roundDurationSeconds,
      };
}
