import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:otoport_mobile/core/constants/api_constants.dart';
import 'package:otoport_mobile/core/storage/token_storage.dart';
import 'package:otoport_mobile/features/auth/models/refresh_request.dart';
import 'package:otoport_mobile/features/store/model/add_expense_request.dart';
import 'package:otoport_mobile/features/store/model/create_purchase_txn_request.dart';
import 'package:otoport_mobile/features/store/model/mark_sold_request.dart';
import 'package:otoport_mobile/features/store/model/pnl_dto.dart';
import 'package:otoport_mobile/features/store/model/store_txn_row_dto.dart';
import 'package:otoport_mobile/features/store/model/update_finance_settings_request.dart';

class StoreFinanceService {
  late final Dio _dio;
  final TokenStorage _tokenStorage = TokenStorage();

  StoreFinanceService() {
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
            'STORE FINANCE REQUEST => ${options.method} ${options.path}',
          );
          debugPrint(
            'STORE FINANCE AUTH => ${options.headers['Authorization']}',
          );

          handler.next(options);
        },
        onResponse: (response, handler) {
          debugPrint(
            'STORE FINANCE RESPONSE <= ${response.requestOptions.path} '
                '[${response.statusCode}] ${response.data}',
          );
          handler.next(response);
        },
        onError: (error, handler) async {
          debugPrint(
            'STORE FINANCE ERROR <= ${error.requestOptions.path} '
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
              debugPrint('STORE FINANCE REFRESH ERROR => $e');
              await _tokenStorage.clearAll();
              return handler.next(error);
            }
          }

          handler.next(error);
        },
      ),
    );
  }

  Future<List<StoreTxnRowDto>> listTransactions(String status) async {
    final response = await _dio.get(
      '/api/store/finance/transactions',
      queryParameters: {'status': status},
    );

    final raw = response.data;
    if (raw is! List) return [];

    return raw
        .map((e) => StoreTxnRowDto.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<Map<String, dynamic>> createPurchase(
      CreatePurchaseTxnRequest request,
      ) async {
    final response = await _dio.post(
      '/api/store/finance/transactions',
      data: request.toJson(),
    );

    return Map<String, dynamic>.from(response.data);
  }

  Future<Map<String, dynamic>> markSold(
      int id,
      MarkSoldRequest request,
      ) async {
    final response = await _dio.put(
      '/api/store/finance/transactions/$id/sell',
      data: request.toJson(),
    );

    return Map<String, dynamic>.from(response.data);
  }

  Future<Map<String, dynamic>> addExpense(
      int id,
      AddExpenseRequest request,
      ) async {
    final response = await _dio.post(
      '/api/store/finance/transactions/$id/expenses',
      data: request.toJson(),
    );

    return Map<String, dynamic>.from(response.data);
  }

  Future<PnlDto> getPnl(int id) async {
    final response = await _dio.get('/api/store/finance/transactions/$id/pnl');

    return PnlDto.fromJson(Map<String, dynamic>.from(response.data));
  }

  Future<Map<String, dynamic>> lock(int id) async {
    final response =
    await _dio.post('/api/store/finance/transactions/$id/lock');
    return Map<String, dynamic>.from(response.data);
  }

  Future<Map<String, dynamic>> getSettings() async {
    final response = await _dio.get('/api/store/finance/settings');
    return Map<String, dynamic>.from(response.data);
  }

  Future<Map<String, dynamic>> updateSettings(
      UpdateFinanceSettingsRequest request,
      ) async {
    final response = await _dio.put(
      '/api/store/finance/settings',
      data: request.toJson(),
    );
    return Map<String, dynamic>.from(response.data);
  }
}