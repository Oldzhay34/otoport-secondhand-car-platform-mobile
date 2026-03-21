import 'package:dio/dio.dart';
import 'package:otoport_mobile/core/network/api_error_response.dart';
import 'package:otoport_mobile/core/network/api_exception.dart';

class DioErrorParser {
  static ApiException parse(Object error) {
    if (error is ApiException) {
      return error;
    }

    if (error is DioException) {
      final response = error.response;
      final statusCode = response?.statusCode;

      final retryAfterRaw =
          response?.headers.value('retry-after') ??
              response?.headers.value('Retry-After');

      final rateLimitRemaining =
          response?.headers.value('x-rate-limit-remaining') ??
              response?.headers.value('X-Rate-Limit-Remaining');

      int? retryAfterSeconds;
      if (retryAfterRaw != null) {
        retryAfterSeconds = int.tryParse(retryAfterRaw.trim());
      }

      final data = response?.data;

      if (data is Map) {
        try {
          final apiError = ApiErrorResponse.fromJson(
            Map<String, dynamic>.from(data),
          );

          final fieldMessages = apiError.fieldErrors
              .map((e) {
            final field = (e.field ?? '').trim();
            final msg = (e.message ?? '').trim();

            if (field.isNotEmpty && msg.isNotEmpty) {
              return '$field: $msg';
            }
            return msg.isNotEmpty ? msg : field;
          })
              .where((e) => e.trim().isNotEmpty)
              .toList();

          return ApiException(
            statusCode: apiError.status ?? statusCode,
            error: apiError.error,
            path: apiError.path,
            message: apiError.toDisplayMessage(),
            fieldErrors: fieldMessages,
            retryAfterSeconds: retryAfterSeconds,
            rateLimitRemaining: rateLimitRemaining,
          );
        } catch (_) {}
      }

      if (data is String && data.trim().isNotEmpty) {
        return ApiException(
          statusCode: statusCode,
          message: data.trim(),
          retryAfterSeconds: retryAfterSeconds,
          rateLimitRemaining: rateLimitRemaining,
        );
      }

      if (error.type == DioExceptionType.connectionTimeout) {
        return ApiException(
          statusCode: statusCode,
          message: 'Bağlantı zaman aşımına uğradı.',
          retryAfterSeconds: retryAfterSeconds,
          rateLimitRemaining: rateLimitRemaining,
        );
      }

      if (error.type == DioExceptionType.receiveTimeout) {
        return ApiException(
          statusCode: statusCode,
          message: 'Sunucudan yanıt alınamadı.',
          retryAfterSeconds: retryAfterSeconds,
          rateLimitRemaining: rateLimitRemaining,
        );
      }

      if (error.type == DioExceptionType.connectionError) {
        return ApiException(
          statusCode: statusCode,
          message: 'Sunucuya bağlanılamadı.',
          retryAfterSeconds: retryAfterSeconds,
          rateLimitRemaining: rateLimitRemaining,
        );
      }

      if (statusCode == 401) {
        return ApiException(
          statusCode: 401,
          message: 'Giriş yapmalısın.',
          retryAfterSeconds: retryAfterSeconds,
          rateLimitRemaining: rateLimitRemaining,
        );
      }

      if (statusCode == 403) {
        return ApiException(
          statusCode: 403,
          message: 'Bu işlem için yetkin yok.',
          retryAfterSeconds: retryAfterSeconds,
          rateLimitRemaining: rateLimitRemaining,
        );
      }

      if (statusCode == 404) {
        return ApiException(
          statusCode: 404,
          message: 'İstenen kaynak bulunamadı.',
          retryAfterSeconds: retryAfterSeconds,
          rateLimitRemaining: rateLimitRemaining,
        );
      }

      if (statusCode == 429) {
        return ApiException(
          statusCode: 429,
          message: retryAfterSeconds != null
              ? 'Çok fazla istek gönderildi. $retryAfterSeconds saniye sonra tekrar dene.'
              : 'Çok fazla istek gönderildi. Lütfen daha sonra tekrar dene.',
          retryAfterSeconds: retryAfterSeconds,
          rateLimitRemaining: rateLimitRemaining,
        );
      }

      return ApiException(
        statusCode: statusCode,
        message: 'İstek sırasında bir hata oluştu.',
        retryAfterSeconds: retryAfterSeconds,
        rateLimitRemaining: rateLimitRemaining,
      );
    }

    return ApiException(
      message: error.toString(),
    );
  }
}