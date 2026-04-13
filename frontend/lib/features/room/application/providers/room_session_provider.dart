import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/room_session_model.dart';
import '../controllers/room_session_controller.dart';

/// The room session — `null` when not in a room.
final roomSessionControllerProvider =
    NotifierProvider<RoomSessionController, RoomSessionModel?>(
  RoomSessionController.new,
);
