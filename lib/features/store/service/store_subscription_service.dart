import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:otoport_mobile/core/constants/api_constants.dart';
import 'package:otoport_mobile/core/storage/token_storage.dart';
import 'package:otoport_mobile/features/auth/models/refresh_request.dart';
import 'package:otoport_mobile/features/store/model/purchase_plan_request.dart';
import 'package:otoport_mobile/features/store/model/subscription_checkout_info_response.dart';
import 'package:otoport_mobile/features/store/model/subscription_response.dart';
import '../model/subscription_model.dart';

class StoreSubscriptionService {
  late final Dio _dio;
  final TokenStorage _tokenStorage = TokenStorage();

  StoreSubscriptionService() {
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

          debugPrint(
            'SUBSCRIPTION REQUEST => ${options.method} ${options.path}',
          );
          debugPrint(
            'SUBSCRIPTION AUTH => ${options.headers['Authorization']}',
          );

          handler.next(options);
        },
        onResponse: (response, handler) {
          debugPrint(
            'SUBSCRIPTION RESPONSE <= ${response.requestOptions.path} '
                '[${response.statusCode}] ${response.data}',
          );
          handler.next(response);
        },
        onError: (error, handler) async {
          debugPrint(
            'SUBSCRIPTION ERROR <= ${error.requestOptions.path} '
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
              debugPrint('SUBSCRIPTION REFRESH ERROR => $e');
              await _tokenStorage.clearAll();
              return handler.next(error);
            }
          }

          handler.next(error);
        },
      ),
    );
  }

  Future<List<SubscriptionPlanType>> getPlans() async {
    final response = await _dio.get('/api/subscriptions/plans');

    final data = response.data;
    if (data is List) {
      return data
          .map((e) => SubscriptionPlanType.fromString(e?.toString()))
          .toList();
    }

    return SubscriptionPlanType.values;
  }

  Future<SubscriptionResponse> me() async {
    final response = await _dio.get('/api/subscriptions/me');
    return SubscriptionResponse.fromJson(
      Map<String, dynamic>.from(response.data),
    );
  }

  Future<SubscriptionCheckoutInfoResponse> getCheckoutInfo() async {
    final response = await _dio.get('/api/subscriptions/checkout-info');
    return SubscriptionCheckoutInfoResponse.fromJson(
      Map<String, dynamic>.from(response.data),
    );
  }

  Future<SubscriptionResponse> purchasePlan(SubscriptionPlanType plan) async {
    final response = await _dio.post(
      '/api/subscriptions/purchase',
      data: PurchasePlanRequest(plan: plan.apiValue).toJson(),
    );

    return SubscriptionResponse.fromJson(
      Map<String, dynamic>.from(response.data),
    );
  }
}