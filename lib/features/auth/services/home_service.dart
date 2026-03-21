import 'package:dio/dio.dart';
import 'package:otoport_mobile/core/constants/api_constants.dart';

import '../models/home_store_filters_response.dart';
import '../models/home_store_model.dart';

class HomeService {
  final Dio _dio = Dio(
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

  Future<List<HomeStoreModel>> getStores({
    int limit = 50,
    String? city,
    String? district,
    String? buildingId,
    String? floor,
  }) async {
    final response = await _dio.get(
      '/api/home/stores',
      queryParameters: {
        'limit': limit,
        if (city != null && city.isNotEmpty) 'city': city,
        if (district != null && district.isNotEmpty) 'district': district,
        if (buildingId != null && buildingId.isNotEmpty)
          'buildingId': buildingId,
        if (floor != null && floor.isNotEmpty) 'floor': floor,
      },
    );

    final data = Map<String, dynamic>.from(response.data);
    final rawList = data['stores'] ?? data['items'] ?? [];

    if (rawList is! List) return [];

    return rawList
        .map((e) => HomeStoreModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<HomeStoreFiltersResponse> getStoreFilters({
    String? city,
    String? district,
    String? buildingId,
  }) async {
    final response = await _dio.get(
      '/api/home/store-filters',
      queryParameters: {
        if (city != null && city.isNotEmpty) 'city': city,
        if (district != null && district.isNotEmpty) 'district': district,
        if (buildingId != null && buildingId.isNotEmpty)
          'buildingId': buildingId,
      },
    );

    return HomeStoreFiltersResponse.fromJson(
      Map<String, dynamic>.from(response.data),
    );
  }

  Future<void> guestHit() async {
    await _dio.get('/api/home/guest-hit');
  }
}