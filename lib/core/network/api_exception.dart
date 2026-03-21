class ApiException implements Exception {
  final int? statusCode;
  final String message;
  final String? error;
  final String? path;
  final List<String> fieldErrors;
  final int? retryAfterSeconds;
  final String? rateLimitRemaining;

  ApiException({
    required this.message,
    this.statusCode,
    this.error,
    this.path,
    this.fieldErrors = const [],
    this.retryAfterSeconds,
    this.rateLimitRemaining,
  });

  bool get isUnauthorized => statusCode == 401;
  bool get isForbidden => statusCode == 403;
  bool get isNotFound => statusCode == 404;
  bool get isConflict => statusCode == 409;
  bool get isValidation => statusCode == 400 && fieldErrors.isNotEmpty;
  bool get isRateLimit => statusCode == 429;

  @override
  String toString() {
    return message;
  }
}