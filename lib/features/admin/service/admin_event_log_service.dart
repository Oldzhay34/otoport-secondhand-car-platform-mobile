import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:otoport_mobile/core/constants/api_constants.dart';
import 'package:otoport_mobile/core/storage/token_storage.dart';
import 'package:otoport_mobile/features/admin/models/admin_event_row_dto.dart';
import 'package:otoport_mobile/features/auth/models/refresh_request.dart';

class AdminEventLogService {
  late final Dio _dio;
  final TokenStorage _tokenStorage = TokenStorage();

  AdminEventLogService() {
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

          debugPrint('EVENT REQUEST => ${options.method} ${options.path}');
          handler.next(options);
        },
        onResponse: (response, handler) {
          debugPrint(
            'EVENT RESPONSE <= ${response.requestOptions.path} '
                '[${response.statusCode}] ${response.data}',
          );
          handler.next(response);
        },
        onError: (error, handler) async {
          debugPrint(
            'EVENT ERROR <= ${error.requestOptions.path} '
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
                  headers: {'Authorization': null},
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

  Future<void> _ensureAdminRole() async {
    final role = (await _tokenStorage.getRole() ?? '').trim().toUpperCase();
    if (role != 'ADMIN') {
      throw Exception('Bu sayfaya erişim için ADMIN yetkisi gerekiyor.');
    }
  }

  Future<List<AdminEventRowDto>> getRecent({
    int limit = 200,
    String sort = 'desc',
  }) async {
    await _ensureAdminRole();

    final response = await _dio.get(
      '/api/admin/event-logs/recent',
      queryParameters: {
        'limit': limit,
        'sort': sort,
      },
    );

    final rawList = (response.data as List?) ?? const [];
    return rawList
        .map(
          (e) => AdminEventRowDto.fromJson(
        Map<String, dynamic>.from(e as Map),
      ),
    )
        .toList();
  }

  Future<List<AdminEventRowDto>> search({
    String? type,
    String? severity,
    String? source,
    String? entityType,
    int? entityId,
    String? correlationId,
    String? q,
    int limit = 200,
    String sort = 'desc',
  }) async {
    await _ensureAdminRole();

    final response = await _dio.get(
      '/api/admin/event-logs',
      queryParameters: {
        if (type != null && type.trim().isNotEmpty) 'type': type.trim(),
        if (severity != null && severity.trim().isNotEmpty)
          'severity': severity.trim(),
        if (source != null && source.trim().isNotEmpty) 'source': source.trim(),
        if (entityType != null && entityType.trim().isNotEmpty)
          'entityType': entityType.trim(),
        if (entityId != null) 'entityId': entityId,
        if (correlationId != null && correlationId.trim().isNotEmpty)
          'correlationId': correlationId.trim(),
        if (q != null && q.trim().isNotEmpty) 'q': q.trim(),
        'limit': limit,
        'sort': sort,
      },
    );

    final rawList = (response.data as List?) ?? const [];
    return rawList
        .map(
          (e) => AdminEventRowDto.fromJson(
        Map<String, dynamic>.from(e as Map),
      ),
    )
        .toList();
  }
}