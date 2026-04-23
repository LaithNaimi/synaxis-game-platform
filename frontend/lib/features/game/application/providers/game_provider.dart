import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/game_controller.dart';
import '../state/game_state.dart';

final gameControllerProvider =
    NotifierProvider<GameController, GameState>(GameController.new);
