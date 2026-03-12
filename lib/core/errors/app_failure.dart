enum AppFailureType {
  invalidCredentials,
  noConnection,
  timeout,
  serverError,
  sessionExpired,
  validationError,
  unknown,
}

class AppFailure implements Exception {
  final AppFailureType type;
  final String message;
  final int? statusCode;
  final Object? cause;

  const AppFailure({
    required this.type,
    required this.message,
    this.statusCode,
    this.cause,
  });

  bool get isSessionExpired => type == AppFailureType.sessionExpired;

  @override
  String toString() => message;
}
