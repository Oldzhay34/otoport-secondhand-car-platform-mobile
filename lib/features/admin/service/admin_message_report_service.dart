import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:otoport_mobile/core/constants/api_constants.dart';
import 'package:otoport_mobile/core/storage/token_storage.dart';
import 'package:otoport_mobile/features/admin/models/admin_report_item_dto.dart';
import 'package:otoport_mobile/features/auth/models/refresh_request.dart';

class AdminMessageReportService {
  late final Dio _dio;
  final TokenStorage _tokenStorage = TokenStorage();

  AdminMessageReportService() {
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

          debugPrint('REPORT REQUEST => ${options.method} ${options.path}');
          handler.next(options);
        },
        onResponse: (response, handler) {
          debugPrint(
            'REPORT RESPONSE <= ${response.requestOptions.path} '
                '[${response.statusCode}] ${response.data}',
          );
          handler.next(response);
        },
        onError: (error, handler) async {
          debugPrint(
            'REPORT ERROR <= ${error.requestOptions.path} '
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

  Future<List<AdminReportItemDto>> getAll({String? status}) async {
    await _ensureAdminRole();

    final response = await _dio.get(
      '/api/admin/reports',
      queryParameters: {
        if (status != null && status.trim().isNotEmpty) 'status': status.trim(),
      },
    );

    final raw = response.data;

    final rawList = raw is List
        ? raw
        : (raw is Map<String, dynamic> && raw['items'] is List
        ? raw['items'] as List
        : const []);

    return rawList
        .map(
          (e) => AdminReportItemDto.fromJson(
        Map<String, dynamic>.from(e as Map),
      ),
    )
        .toList();
  }

  Future<void> setStatus({
    required int reportId,
    required String status,
  }) async {
    await _ensureAdminRole();

    await _dio.patch(
      '/api/admin/reports/$reportId',
      queryParameters: {
        'status': status,
      },
    );
  }
}