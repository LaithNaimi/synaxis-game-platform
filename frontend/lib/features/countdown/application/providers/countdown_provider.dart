import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/countdown_controller.dart';
import '../state/countdown_state.dart';

final countdownControllerProvider =
    NotifierProvider<CountdownController, CountdownState>(
  CountdownController.new,
);
