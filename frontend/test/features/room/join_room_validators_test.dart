import 'package:flutter_test/flutter_test.dart';

import 'package:synaxis/features/room/presentation/join_room_validators.dart';

void main() {
  group('validateJoinRoomCode', () {
    test('empty', () {
      expect(validateJoinRoomCode(''), isNotNull);
      expect(validateJoinRoomCode('   '), isNotNull);
    });

    test('wrong length', () {
      expect(validateJoinRoomCode('ABC12'), isNotNull);
      expect(validateJoinRoomCode('ABCDEFG'), isNotNull);
    });

    test('invalid chars', () {
      expect(validateJoinRoomCode('ABC-12'), isNotNull);
    });

    test('valid', () {
      expect(validateJoinRoomCode('Ab12Cd'), isNull);
      expect(validateJoinRoomCode('  ab12cd  '), isNull);
    });
  });
}
