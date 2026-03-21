import 'package:dio/dio.dart';
import 'package:otoport_mobile/core/constants/api_constants.dart';
import 'package:otoport_mobile/core/storage/token_storage.dart';
import 'package:otoport_mobile/features/auth/models/refresh_request.dart';
import '../models/favorite_car_model.dart';
import '../models/passive_similar_listing_model.dart';


class FavoriteService {
  late final Dio _dio;
  final TokenStorage _tokenStorage = TokenStorage();

  FavoriteService() {
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

  Future<List<PassiveSimilarListingModel>> getSimilarListings(
      int listingId, {
        int limit = 12,
      }) async {
    final response = await _dio.get(
      '/api/passive/listings/$listingId/similar',
      queryParameters: {
        'limit': limit,
      },
    );

    final data = response.data;

    if (data is! List) return [];

    return data
        .map(
          (e) => PassiveSimilarListingModel.fromJson(
        Map<String, dynamic>.from(e),
      ),
    )
        .toList();
  }

  Future<List<FavoriteCardModel>> getMyFavorites() async {
    final response = await _dio.get('/api/client/favorites');
    final data = response.data;

    if (data is! List) return [];

    return data
        .map((e) => FavoriteCardModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<List<FavoriteCardModel>> getMyPassiveFavorites() async {
    final response = await _dio.get('/api/client/favorites/passive');
    final data = response.data;

    if (data is! List) return [];

    return data
        .map((e) => FavoriteCardModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<void> addFavorite(int listingId) async {
    await _dio.post('/api/client/favorites/$listingId');
  }

  Future<void> removeFavorite(int listingId) async {
    await _dio.delete('/api/client/favorites/$listingId');
  }
}