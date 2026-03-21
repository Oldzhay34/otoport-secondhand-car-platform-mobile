import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:otoport_mobile/core/constants/api_constants.dart';
import 'package:otoport_mobile/core/storage/token_storage.dart';
import 'package:otoport_mobile/features/auth/models/refresh_request.dart';
import '../models/inquiry_thread_model.dart';
import '../models/inquiry_upsert_request.dart';

class InquiryService {
  late final Dio _dio;
  final TokenStorage _tokenStorage = TokenStorage();

  InquiryService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _tokenStorage.getAccessToken();

          options.headers.remove('Authorization');

          if (token != null && token.trim().isNotEmpty) {
            options.headers['Authorization'] = 'Bearer ${token.trim()}';
          }

          debugPrint('REQUEST => ${options.method} ${options.path}');
          debugPrint('AUTH HEADER => ${options.headers['Authorization']}');

          handler.next(options);
        },
        onResponse: (response, handler) {
          debugPrint(
            'RESPONSE <= ${response.requestOptions.path} '
                '[${response.statusCode}] ${response.data}',
          );
          handler.next(response);
        },
        onError: (error, handler) async {
          debugPrint(
            'ERROR <= ${error.requestOptions.path} '
                '[${error.response?.statusCode}] ${error.response?.data}',
          );

          final requestPath = error.requestOptions.path;
          final shouldSkipRefresh = requestPath == '/api/auth/refresh-mobile';

          if (error.response?.statusCode == 401 && !shouldSkipRefresh) {
            try {
              final refreshToken = await _tokenStorage.getRefreshToken();

              if (refreshToken == null || refreshToken.trim().isEmpty) {
                await _tokenStorage.clearAll();
                return handler.next(error);
              }

              final refreshResponse = await _dio.post(
                '/api/auth/refresh-mobile',
                data: RefreshRequest(
                  refreshToken: refreshToken.trim(),
                ).toJson(),
                options: Options(
                  headers: {
                    'Authorization': null,
                  },
                ),
              );

              final data = Map<String, dynamic>.from(refreshResponse.data);

              final newAccessToken =
              (data['accessToken'] ?? '').toString().trim();
              final newRefreshToken =
              (data['refreshToken'] ?? '').toString().trim();

              if (newAccessToken.isEmpty || newRefreshToken.isEmpty) {
                await _tokenStorage.clearAll();
                return handler.next(error);
              }

              final role = await _tokenStorage.getRole() ?? '';
              final userId = await _tokenStorage.getUserId() ?? '';

              await _tokenStorage.saveTokens(
                accessToken: newAccessToken,
                refreshToken: newRefreshToken,
                role: role,
                userId: userId,
              );

              final retryRequest = error.requestOptions;
              retryRequest.headers['Authorization'] =
              'Bearer $newAccessToken';

              final clonedResponse = await _dio.fetch(retryRequest);
              return handler.resolve(clonedResponse);
            } catch (e) {
              debugPrint('INQUIRY REFRESH ERROR => $e');
              await _tokenStorage.clearAll();
              return handler.next(error);
            }
          }

          handler.next(error);
        },
      ),
    );
  }

  Future<InquiryThreadModel> getThreadByListing(int listingId) async {
    final response = await _dio.get(
      '/api/client/inquiries/thread',
      queryParameters: {
        'listingId': listingId,
      },
    );

    return InquiryThreadModel.fromJson(
      Map<String, dynamic>.from(response.data),
    );
  }

  Future<InquiryThreadModel> upsertInquiry(InquiryUpsertRequest request) async {
    final response = await _dio.post(
      '/api/client/inquiries/upsert',
      data: request.toJson(),
    );

    return InquiryThreadModel.fromJson(
      Map<String, dynamic>.from(response.data),
    );
  }
}