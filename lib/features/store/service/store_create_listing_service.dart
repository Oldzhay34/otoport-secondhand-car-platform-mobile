import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:otoport_mobile/core/constants/api_constants.dart';
import 'package:otoport_mobile/core/storage/token_storage.dart';
import 'package:otoport_mobile/features/auth/models/refresh_request.dart';
import 'package:otoport_mobile/features/store/model/catalog_models.dart';
import 'package:otoport_mobile/features/store/model/store_listing_create_request.dart';
import 'package:otoport_mobile/features/store/model/store_listing_create_response.dart';

class StoreCreateListingService {
  late final Dio _dio;
  final TokenStorage _tokenStorage = TokenStorage();

  StoreCreateListingService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        headers: {
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

          debugPrint(
            'STORE CREATE REQUEST => ${options.method} ${options.path}',
          );
          debugPrint(
            'STORE CREATE AUTH => ${options.headers['Authorization']}',
          );

          handler.next(options);
        },
        onResponse: (response, handler) {
          debugPrint(
            'STORE CREATE RESPONSE <= ${response.requestOptions.path} '
                '[${response.statusCode}] ${response.data}',
          );
          handler.next(response);
        },
        onError: (error, handler) async {
          debugPrint(
            'STORE CREATE ERROR <= ${error.requestOptions.path} '
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
              debugPrint('STORE CREATE REFRESH ERROR => $e');
              await _tokenStorage.clearAll();
              return handler.next(error);
            }
          }

          handler.next(error);
        },
      ),
    );
  }

  Future<VehicleCatalogDto> loadCatalog(String catalogType) async {
    final normalized = _normalizeCatalogType(catalogType);

    final assetPath = switch (normalized) {
      'SUV' => 'assets/filejson/suvwithpackages.json',
      'MINIVAN' => 'assets/filejson/minivanwithpackages.json',
      _ => 'assets/filejson/AutomobileWithPackeages.json',
    };

    final raw = await rootBundle.loadString(assetPath);
    final jsonMap = jsonDecode(raw) as Map<String, dynamic>;
    return VehicleCatalogDto.fromJson(jsonMap);
  }

  Future<StoreListingCreateResponse> createListing({
    required StoreListingCreateRequest request,
    required List<File> images,
  }) async {
    final formData = FormData();

    formData.fields.add(
      MapEntry('data', jsonEncode(request.toJson())),
    );

    for (final file in images.take(10)) {
      formData.files.add(
        MapEntry(
          'images',
          await MultipartFile.fromFile(
            file.path,
            filename: file.path.split('/').last,
          ),
        ),
      );
    }

    final response = await _dio.post(
      '/api/store/listings',
      data: formData,
      options: Options(
        contentType: 'multipart/form-data',
      ),
    );

    return StoreListingCreateResponse.fromJson(
      Map<String, dynamic>.from(response.data),
    );
  }

  String _normalizeCatalogType(String value) {
    final v = value.trim().toUpperCase();
    if (v == 'SUV') return 'SUV';
    if (v == 'VAN' || v == 'MINIVAN') return 'MINIVAN';
    return 'CAR';
  }
}