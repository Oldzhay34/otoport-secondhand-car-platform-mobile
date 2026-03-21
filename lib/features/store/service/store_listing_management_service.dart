import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:otoport_mobile/core/constants/api_constants.dart';
import 'package:otoport_mobile/core/storage/token_storage.dart';
import 'package:otoport_mobile/features/auth/models/refresh_request.dart';
import 'package:otoport_mobile/features/store/model/old_listing_card_dto.dart';
import 'package:otoport_mobile/features/store/model/simple_ok_response.dart';
import 'package:otoport_mobile/features/store/model/store_car_update_request.dart';
import 'package:otoport_mobile/features/store/model/store_listing_edit_dto.dart';

class StoreListingManagementService {
  late final Dio _dio;
  final TokenStorage _tokenStorage = TokenStorage();

  StoreListingManagementService() {
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

          debugPrint('STORE MGMT REQUEST => ${options.method} ${options.path}');
          debugPrint('STORE MGMT AUTH => ${options.headers['Authorization']}');

          handler.next(options);
        },
        onResponse: (response, handler) {
          debugPrint(
            'STORE MGMT RESPONSE <= ${response.requestOptions.path} '
                '[${response.statusCode}] ${response.data}',
          );
          handler.next(response);
        },
        onError: (error, handler) async {
          debugPrint(
            'STORE MGMT ERROR <= ${error.requestOptions.path} '
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
              debugPrint('STORE MGMT REFRESH ERROR => $e');
              await _tokenStorage.clearAll();
              return handler.next(error);
            }
          }

          handler.next(error);
        },
      ),
    );
  }

  Future<StoreListingEditDto> getForEdit(int listingId) async {
    final response = await _dio.get('/api/store/listings/$listingId');

    return StoreListingEditDto.fromJson(
      Map<String, dynamic>.from(response.data),
    );
  }

  Future<StoreListingEditDto> update(
      int listingId,
      StoreCarUpdateRequest request,
      ) async {
    final response = await _dio.put(
      '/api/store/listings/$listingId',
      data: request.toJson(),
    );

    return StoreListingEditDto.fromJson(
      Map<String, dynamic>.from(response.data),
    );
  }

  Future<bool> delete(int listingId) async {
    final response = await _dio.delete('/api/store/listings/$listingId');

    final parsed = SimpleOkResponse.fromJson(
      Map<String, dynamic>.from(response.data),
    );

    return parsed.ok;
  }

  Future<List<OldListingCardDto>> getOldListings() async {
    final response = await _dio.get('/api/store/listings/old');

    final raw = response.data;
    if (raw is! List) return [];

    return raw
        .map((e) => OldListingCardDto.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<bool> restore(int listingId) async {
    final response = await _dio.post('/api/store/listings/$listingId/restore');

    final parsed = SimpleOkResponse.fromJson(
      Map<String, dynamic>.from(response.data),
    );

    return parsed.ok;
  }
}