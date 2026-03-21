import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:otoport_mobile/core/constants/api_constants.dart';
import '../models/store_listing_card_model.dart';
import '../models/store_public_model.dart';

class StorePublicService {
  late final Dio _dio;

  StorePublicService() {
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
        onRequest: (options, handler) {
          debugPrint('REQUEST => ${options.method} ${options.path}');
          handler.next(options);
        },
        onResponse: (response, handler) {
          debugPrint(
            'RESPONSE <= ${response.requestOptions.path} '
                '[${response.statusCode}] ${response.data}',
          );
          handler.next(response);
        },
        onError: (error, handler) {
          debugPrint(
            'ERROR <= ${error.requestOptions.path} '
                '[${error.response?.statusCode}] ${error.response?.data}',
          );
          handler.next(error);
        },
      ),
    );
  }

  Future<StorePublicModel> getStore(int storeId) async {
    final response = await _dio.get('/api/stores/$storeId');
    return StorePublicModel.fromJson(
      Map<String, dynamic>.from(response.data),
    );
  }

  Future<List<StoreListingCardModel>> getStoreListings(int storeId) async {
    final response = await _dio.get('/api/stores/$storeId/listings');

    final raw = response.data as List;
    return raw
        .map((e) => StoreListingCardModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}