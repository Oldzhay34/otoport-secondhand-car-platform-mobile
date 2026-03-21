import 'package:dio/dio.dart';
import 'package:otoport_mobile/core/constants/api_constants.dart';
import 'package:otoport_mobile/core/storage/token_storage.dart';
import 'package:otoport_mobile/features/auth/models/refresh_request.dart';


import '../models/client_notification_model.dart';
import '../models/mark_read_request.dart';

class ClientNotificationService {
  late final Dio _dio;
  final TokenStorage _tokenStorage = TokenStorage();

  ClientNotificationService() {
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
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401 &&
              error.requestOptions.path != '/api/auth/refresh-mobile') {
            try {
              final refreshToken = await _tokenStorage.getRefreshToken();
              if (refreshToken == null || refreshToken.isEmpty) {
                await _tokenStorage.clearAll();
                return handler.next(error);
              }

              final refreshResponse = await _dio.post(
                '/api/auth/refresh-mobile',
                data: RefreshRequest(refreshToken: refreshToken).toJson(),
              );

              final data = Map<String, dynamic>.from(refreshResponse.data);
              final newAccessToken = data['accessToken']?.toString();
              final newRefreshToken = data['refreshToken']?.toString();

              if (newAccessToken == null || newRefreshToken == null) {
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

              final response = await _dio.fetch(retryRequest);
              return handler.resolve(response);
            } catch (_) {
              await _tokenStorage.clearAll();
              return handler.next(error);
            }
          }

          handler.next(error);
        },
      ),
    );
  }

  Future<List<ClientNotificationModel>> getNotifications({
    bool onlyUnread = false,
  }) async {
    final response = await _dio.get(
      '/api/client/notifications',
      queryParameters: {
        'onlyUnread': onlyUnread,
      },
    );

    final data = response.data;
    if (data is! List) return [];

    return data
        .map(
          (e) => ClientNotificationModel.fromJson(
        Map<String, dynamic>.from(e),
      ),
    )
        .toList();
  }

  Future<int> getUnreadCount() async {
    final response = await _dio.get('/api/client/notifications/unread-count');
    return int.tryParse(response.data.toString()) ?? 0;
  }

  Future<void> markRead({
    required int notificationId,
    required bool isRead,
  }) async {
    await _dio.patch(
      '/api/client/notifications/$notificationId',
      data: MarkReadRequest(isRead: isRead).toJson(),
    );
  }

  Future<void> markAllRead() async {
    await _dio.post('/api/client/notifications/mark-all-read');
  }
}