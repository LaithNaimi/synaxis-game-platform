import 'create_room_validators.dart';
import 'join_room_constants.dart';

/// Same rules as create-room player name (DDS §10.4 alignment).
String? validateJoinRoomPlayerName(String? value) =>
    validateCreateRoomPlayerName(value);

/// DDS §10.4 — trim; alphanumeric; length matches backend room codes.
String? validateJoinRoomCode(String? value) {
  final t = (value?.trim() ?? '').toUpperCase();
  if (t.isEmpty) {
    return 'Room code is required';
  }
  if (t.length != kJoinRoomCodeLength) {
    return 'Enter exactly $kJoinRoomCodeLength characters';
  }
  if (!RegExp(r'^[A-Z0-9]{6}$').hasMatch(t)) {
    return 'Use letters and numbers only';
  }
  return null;
}
