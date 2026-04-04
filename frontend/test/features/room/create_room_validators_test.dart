import 'package:flutter_test/flutter_test.dart';

import 'package:synaxis/features/room/presentation/create_room_constants.dart';
import 'package:synaxis/features/room/presentation/create_room_validators.dart';

void main() {
  group('validateCreateRoomPlayerName', () {
    test('empty', () {
      expect(validateCreateRoomPlayerName(''), isNotNull);
      expect(validateCreateRoomPlayerName('   '), isNotNull);
    });

    test('too long', () {
      expect(
        validateCreateRoomPlayerName(
          'a' * (kCreateRoomPlayerNameMaxLength + 1),
        ),
        isNotNull,
      );
    });

    test('valid', () {
      expect(validateCreateRoomPlayerName('Player1'), isNull);
    });
  });

  group('validateCreateRoomDropdown', () {
    test('null', () {
      expect(validateCreateRoomDropdown<String>(null), isNotNull);
    });

    test('set', () {
      expect(validateCreateRoomDropdown('A1'), isNull);
    });
  });

  group('validateCreateRoomMaxPlayers', () {
    test('range', () {
      expect(validateCreateRoomMaxPlayers('1'), isNotNull);
      expect(validateCreateRoomMaxPlayers('9'), isNotNull);
      expect(validateCreateRoomMaxPlayers('4'), isNull);
    });
  });

  group('validateCreateRoomTotalRounds', () {
    test('range', () {
      expect(validateCreateRoomTotalRounds('0'), isNotNull);
      expect(
        validateCreateRoomTotalRounds('${kCreateRoomMaxTotalRounds + 1}'),
        isNotNull,
      );
      expect(validateCreateRoomTotalRounds('5'), isNull);
    });
  });

  group('validateCreateRoomRoundDurationSec', () {
    test('range', () {
      expect(validateCreateRoomRoundDurationSec('10'), isNotNull);
      expect(validateCreateRoomRoundDurationSec('200'), isNotNull);
      expect(validateCreateRoomRoundDurationSec('60'), isNull);
    });
  });
}
