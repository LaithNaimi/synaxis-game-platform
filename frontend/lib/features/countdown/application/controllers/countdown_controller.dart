import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/countdown_state.dart';

class CountdownController extends Notifier<CountdownState> {
  Timer? _timer;

  @override
  CountdownState build() => const CountdownState();

  void start() {
    _timer?.cancel();
    state = const CountdownState(value: 3);

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final next = state.value - 1;
      if (next <= 0) {
        _timer?.cancel();
        state = state.copyWith(value: 0, isFinished: true);
      } else {
        state = state.copyWith(value: next);
      }
    });
  }

  void reset() {
    _timer?.cancel();
    state = const CountdownState();
  }
}
