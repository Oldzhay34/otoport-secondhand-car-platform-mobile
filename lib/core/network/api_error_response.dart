class ApiFieldErrorModel {
  final String? field;
  final String? message;

  ApiFieldErrorModel({
    required this.field,
    required this.message,
  });

  factory ApiFieldErrorModel.fromJson(Map<String, dynamic> json) {
    return ApiFieldErrorModel(
      field: json['field']?.toString(),
      message: json['message']?.toString(),
    );
  }
}

class ApiErrorResponse {
  final int? status;
  final String? error;
  final String? message;
  final String? path;
  final List<ApiFieldErrorModel> fieldErrors;

  ApiErrorResponse({
    required this.status,
    required this.error,
    required this.message,
    required this.path,
    required this.fieldErrors,
  });

  factory ApiErrorResponse.fromJson(Map<String, dynamic> json) {
    final rawFieldErrors = (json['fieldErrors'] as List?) ?? const [];

    return ApiErrorResponse(
      status: (json['status'] as num?)?.toInt(),
      error: json['error']?.toString(),
      message: json['message']?.toString(),
      path: json['path']?.toString(),
      fieldErrors: rawFieldErrors
          .map(
            (e) => ApiFieldErrorModel.fromJson(
          Map<String, dynamic>.from(e as Map),
        ),
      )
          .toList(),
    );
  }

  String toDisplayMessage() {
    if ((message ?? '').trim().isNotEmpty) {
      return message!.trim();
    }

    if (fieldErrors.isNotEmpty) {
      return fieldErrors
          .map((e) {
        final field = (e.field ?? '').trim();
        final msg = (e.message ?? '').trim();

        if (field.isNotEmpty && msg.isNotEmpty) {
          return '$field: $msg';
        }
        return msg.isNotEmpty ? msg : field;
      })
          .where((e) => e.trim().isNotEmpty)
          .join('\n');
    }

    if ((error ?? '').trim().isNotEmpty) {
      return error!.trim();
    }

    return 'Beklenmeyen bir hata oluştu.';
  }
}