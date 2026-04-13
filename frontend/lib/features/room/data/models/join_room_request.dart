class JoinRoomRequest {
  const JoinRoomRequest({required this.playerName});

  final String playerName;

  Map<String, dynamic> toJson() => {'playerName': playerName};
}
