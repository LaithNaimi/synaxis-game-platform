/// Domain / transport errors — mapped in [ErrorMapper].
class AppException implements Exception {
  const AppException(this.message);
  final String message;

  @override
  String toString() => message;
}
