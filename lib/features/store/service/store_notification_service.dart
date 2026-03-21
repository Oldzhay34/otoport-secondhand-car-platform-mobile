import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:otoport_mobile/core/constants/api_constants.dart';
import 'package:otoport_mobile/core/storage/token_storage.dart';
import 'package:otoport_mobile/features/auth/models/refresh_request.dart';
import 'package:otoport_mobile/features/store/model/store_notification_dto.dart';
import 'package:otoport_mobile/features/store/model/store_notification_list_response.dart';
import 'package:otoport_mobile/features/store/model/unread_count_response.dart';

class StoreNotificationService {
  late final Dio _dio;
  final TokenStorage _tokenStorage = TokenStorage();

  StoreNotificationService() {
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

          debugPrint('STORE NOTIF REQUEST => ${options.method} ${options.path}');
          debugPrint('STORE NOTIF AUTH => ${options.headers['Authorization']}');

          handler.next(options);
        },
        onResponse: (response, handler) {
          debugPrint(
            'STORE NOTIF RESPONSE <= ${response.requestOptions.path} '
                '[${response.statusCode}] ${response.data}',
          );
          handler.next(response);
        },
        onError: (error, handler) async {
          debugPrint(
            'STORE NOTIF ERROR <= ${error.requestOptions.path} '
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
              debugPrint('STORE NOTIF REFRESH ERROR => $e');
              await _tokenStorage.clearAll();
              return handler.next(error);
            }
          }

          handler.next(error);
        },
      ),
    );
  }

  Future<List<StoreNotificationDto>> getNotifications({
    bool? unreadOnly,
  }) async {
    final response = await _dio.get(
      '/api/store/notifications',
      queryParameters: {
        if (unreadOnly != null) 'unreadOnly': unreadOnly,
      },
    );

    final parsed = StoreNotificationListResponse.fromJson(
      Map<String, dynamic>.from(response.data),
    );

    return parsed.items;
  }

  Future<int> getUnreadCount() async {
    final response = await _dio.get('/api/store/notifications/unread-count');

    final parsed = UnreadCountResponse.fromJson(
      Map<String, dynamic>.from(response.data),
    );

    return parsed.count;
  }

  Future<void> markRead(int notificationId) async {
    await _dio.patch('/api/store/notifications/$notificationId/read');
  }

  Future<void> markAllRead() async {
    await _dio.patch('/api/store/notifications/read-all');
  }
}