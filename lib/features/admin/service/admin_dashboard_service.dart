import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:otoport_mobile/core/constants/api_constants.dart';
import 'package:otoport_mobile/core/storage/token_storage.dart';
import 'package:otoport_mobile/features/admin/models/admin_audit_row_dto.dart';
import 'package:otoport_mobile/features/admin/models/admin_hourly_traffic_dto.dart';
import 'package:otoport_mobile/features/admin/models/admin_realtime_traffic_dto.dart';
import 'package:otoport_mobile/features/admin/models/admin_spam_attempt_actor_dto.dart';
import 'package:otoport_mobile/features/admin/models/admin_store_listing_activity_dto.dart';
import 'package:otoport_mobile/features/auth/models/refresh_request.dart';
import '../models/admin_daily_stats_dto.dart';

class AdminDashboardService {
  late final Dio _dio;
  final TokenStorage _tokenStorage = TokenStorage();

  AdminDashboardService() {
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

          final isPublicEndpoint =
              options.path == '/api/auth/login' ||
                  options.path == '/api/auth/login-mobile' ||
                  options.path == '/api/auth/register' ||
                  options.path == '/api/auth/verify-email' ||
                  options.path == '/api/auth/refresh-mobile' ||
                  options.path == '/api/auth/password/forgot' ||
                  options.path == '/api/auth/password/verify-code' ||
                  options.path == '/api/auth/password/reset';

          options.headers.remove('Authorization');

          if (!isPublicEndpoint && token != null && token.trim().isNotEmpty) {
            options.headers['Authorization'] = 'Bearer ${token.trim()}';
          }

          debugPrint('ADMIN REQUEST => ${options.method} ${options.path}');
          debugPrint('ADMIN AUTH HEADER => ${options.headers['Authorization']}');

          handler.next(options);
        },
        onResponse: (response, handler) {
          debugPrint(
            'ADMIN RESPONSE <= ${response.requestOptions.path} '
                '[${response.statusCode}] ${response.data}',
          );
          handler.next(response);
        },
        onError: (error, handler) async {
          debugPrint(
            'ADMIN ERROR <= ${error.requestOptions.path} '
                '[${error.response?.statusCode}] ${error.response?.data}',
          );

          final requestPath = error.requestOptions.path;

          final shouldSkipRefresh =
              requestPath == '/api/auth/login' ||
                  requestPath == '/api/auth/login-mobile' ||
                  requestPath == '/api/auth/register' ||
                  requestPath == '/api/auth/verify-email' ||
                  requestPath == '/api/auth/refresh-mobile' ||
                  requestPath == '/api/auth/password/forgot' ||
                  requestPath == '/api/auth/password/verify-code' ||
                  requestPath == '/api/auth/password/reset';

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
              debugPrint('ADMIN REFRESH ERROR => $e');
              await _tokenStorage.clearAll();
              return handler.next(error);
            }
          }

          handler.next(error);
        },
      ),
    );
  }

  Future<void> _ensureAdminRole() async {
    final role = (await _tokenStorage.getRole() ?? '').trim().toUpperCase();

    if (role != 'ADMIN') {
      throw Exception('Bu sayfaya erişim için ADMIN yetkisi gerekiyor.');
    }
  }

  Future<AdminDailyVisitStatsDto> getDaily({String? date}) async {
    await _ensureAdminRole();

    final response = await _dio.get(
      '/api/admin/dashboard/daily',
      queryParameters: {
        if (date != null && date.trim().isNotEmpty) 'date': date.trim(),
      },
    );

    return AdminDailyVisitStatsDto.fromJson(
      Map<String, dynamic>.from(response.data),
    );
  }

  Future<AdminHourlyTrafficDto> getHourly({String? date}) async {
    await _ensureAdminRole();

    final response = await _dio.get(
      '/api/admin/dashboard/hourly',
      queryParameters: {
        if (date != null && date.trim().isNotEmpty) 'date': date.trim(),
      },
    );

    return AdminHourlyTrafficDto.fromJson(
      Map<String, dynamic>.from(response.data),
    );
  }

  Future<List<AdminStoreListingActivityDto>> getStoreListingActivity({
    String? date,
  }) async {
    await _ensureAdminRole();

    final response = await _dio.get(
      '/api/admin/dashboard/stores/listing-activity',
      queryParameters: {
        if (date != null && date.trim().isNotEmpty) 'date': date.trim(),
      },
    );

    final rawList = (response.data as List?) ?? const [];

    return rawList
        .map(
          (e) => AdminStoreListingActivityDto.fromJson(
        Map<String, dynamic>.from(e as Map),
      ),
    )
        .toList();
  }

  Future<List<AdminAuditRowDto>> getAudit({
    String? date,
    int limit = 50,
  }) async {
    await _ensureAdminRole();

    final response = await _dio.get(
      '/api/admin/dashboard/audit',
      queryParameters: {
        if (date != null && date.trim().isNotEmpty) 'date': date.trim(),
        'limit': limit,
      },
    );

    final rawList = (response.data as List?) ?? const [];

    return rawList
        .map(
          (e) => AdminAuditRowDto.fromJson(
        Map<String, dynamic>.from(e as Map),
      ),
    )
        .toList();
  }

  Future<AdminRealtimeTrafficDto> getRealtime({
    int windowMinutes = 5,
  }) async {
    await _ensureAdminRole();

    final response = await _dio.get(
      '/api/admin/dashboard/realtime',
      queryParameters: {
        'windowMinutes': windowMinutes,
      },
    );

    return AdminRealtimeTrafficDto.fromJson(
      Map<String, dynamic>.from(response.data),
    );
  }

  Future<List<AdminSpamAttemptActorDto>> getSpamAttempts({
    String? date,
  }) async {
    await _ensureAdminRole();

    final response = await _dio.get(
      '/api/admin/dashboard/spam-attempts',
      queryParameters: {
        if (date != null && date.trim().isNotEmpty) 'date': date.trim(),
      },
    );

    final rawList = (response.data as List?) ?? const [];

    return rawList
        .map(
          (e) => AdminSpamAttemptActorDto.fromJson(
        Map<String, dynamic>.from(e as Map),
      ),
    )
        .toList();
  }
}