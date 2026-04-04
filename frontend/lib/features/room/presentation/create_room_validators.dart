import 'create_room_constants.dart';

String? validateCreateRoomPlayerName(String? value) {
  final t = value?.trim() ?? '';
  if (t.isEmpty) {
    return 'Name is required (max $kCreateRoomPlayerNameMaxLength chars)';
  }
  if (t.length > kCreateRoomPlayerNameMaxLength) {
    return 'Max $kCreateRoomPlayerNameMaxLength characters';
  }
  return null;
}

String? validateCreateRoomDropdown<T>(T? value) {
  if (value == null) return 'Please select an option';
  return null;
}

String? validateCreateRoomMaxPlayers(String? value) {
  return _requiredIntInRange(
    value,
    min: 2,
    max: 8,
    rangeMessage: 'Must be between 2 and 8',
  );
}

String? validateCreateRoomTotalRounds(String? value) {
  return _requiredIntInRange(
    value,
    min: 1,
    max: kCreateRoomMaxTotalRounds,
    rangeMessage: 'Must be between 1 and $kCreateRoomMaxTotalRounds',
  );
}

String? validateCreateRoomRoundDurationSec(String? value) {
  return _requiredIntInRange(
    value,
    min: 15,
    max: 180,
    rangeMessage: 'Must be between 15 and 180 seconds',
  );
}

String? _requiredIntInRange(
  String? value, {
  required int min,
  required int max,
  required String rangeMessage,
}) {
  final t = value?.trim() ?? '';
  if (t.isEmpty) return 'Required';
  final n = int.tryParse(t);
  if (n == null) return 'Enter a whole number';
  if (n < min || n > max) return rangeMessage;
  return null;
}
