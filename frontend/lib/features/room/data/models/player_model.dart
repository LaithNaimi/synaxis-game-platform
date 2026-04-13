class PlayerModel {
  const PlayerModel({
    required this.playerId,
    required this.playerName,
    required this.host,
  });

  final String playerId;
  final String playerName;
  final bool host;

  factory PlayerModel.fromJson(Map<String, dynamic> json) {
    return PlayerModel(
      playerId: json['playerId'] as String,
      playerName: json['playerName'] as String,
      host: json['host'] as bool,
    );
  }
}
