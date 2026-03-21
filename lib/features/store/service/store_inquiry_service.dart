import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:otoport_mobile/core/constants/api_constants.dart';
import 'package:otoport_mobile/core/storage/token_storage.dart';
import 'package:otoport_mobile/features/auth/models/refresh_request.dart';
import 'package:otoport_mobile/features/store/model/inquiry_reply_request.dart';
import 'package:otoport_mobile/features/store/model/message_report_request.dart';
import 'package:otoport_mobile/features/store/model/store_inquiry_list_item_dto.dart';
import 'package:otoport_mobile/features/store/model/store_inquiry_list_response.dart';
import 'package:otoport_mobile/features/store/model/store_inquiry_thread_response.dart';
import 'package:otoport_mobile/features/store/model/unread_count_response.dart';

class StoreInquiryService {
  late final Dio _dio;
  final TokenStorage _tokenStorage = TokenStorage();

  StoreInquiryService() {
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

          debugPrint('STORE INQUIRY REQUEST => ${options.method} ${options.path}');
          debugPrint('STORE INQUIRY AUTH => ${options.headers['Authorization']}');

          handler.next(options);
        },
        onResponse: (response, handler) {
          debugPrint(
            'STORE INQUIRY RESPONSE <= ${response.requestOptions.path} '
                '[${response.statusCode}] ${response.data}',
          );
          handler.next(response);
        },
        onError: (error, handler) async {
          debugPrint(
            'STORE INQUIRY ERROR <= ${error.requestOptions.path} '
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
              retryRequest.headers['Authorization'] = 'Bearer $newAccessToken';

              final clonedResponse = await _dio.fetch(retryRequest);
              return handler.resolve(clonedResponse);
            } catch (e) {
              debugPrint('STORE INQUIRY REFRESH ERROR => $e');
              await _tokenStorage.clearAll();
              return handler.next(error);
            }
          }

          handler.next(error);
        },
      ),
    );
  }

  Future<List<StoreInquiryListItemDto>> getInquiries({String? q}) async {
    final response = await _dio.get(
      '/api/store/inquiries',
      queryParameters: {
        if (q != null && q.trim().isNotEmpty) 'q': q.trim(),
      },
    );

    final parsed = StoreInquiryListResponse.fromJson(
      Map<String, dynamic>.from(response.data),
    );

    return parsed.items;
  }

  Future<StoreInquiryThreadResponse> getThread(int inquiryId) async {
    final response = await _dio.get('/api/store/inquiries/$inquiryId');

    return StoreInquiryThreadResponse.fromJson(
      Map<String, dynamic>.from(response.data),
    );
  }

  Future<void> reply(int inquiryId, InquiryReplyRequest request) async {
    await _dio.post(
      '/api/store/inquiries/$inquiryId/reply',
      data: request.toJson(),
    );
  }

  Future<void> markRead(int inquiryId) async {
    await _dio.patch('/api/store/inquiries/$inquiryId/read');
  }

  Future<int> getUnreadCount() async {
    final response = await _dio.get('/api/store/inquiries/unread-count');

    final parsed = UnreadCountResponse.fromJson(
      Map<String, dynamic>.from(response.data),
    );

    return parsed.count;
  }

  Future<void> reportMessage({
    required int inquiryId,
    required int messageId,
    required MessageReportRequest request,
  }) async {
    await _dio.post(
      '/api/store/inquiries/$inquiryId/messages/$messageId/report',
      data: request.toJson(),
    );
  }
}