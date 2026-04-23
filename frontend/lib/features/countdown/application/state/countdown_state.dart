class CountdownState {
  const CountdownState({this.value = 3, this.isFinished = false});

  final int value;

  final bool isFinished;

  CountdownState copyWith({int? value, bool? isFinished}) {
    return CountdownState(
      value: value ?? this.value,
      isFinished: isFinished ?? this.isFinished,
    );
  }
}
