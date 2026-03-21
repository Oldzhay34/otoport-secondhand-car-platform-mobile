import 'package:dio/dio.dart';
import 'package:otoport_mobile/core/constants/api_constants.dart';
import 'package:otoport_mobile/features/auth/models/listing_card_model.dart';

class FilterListingStoreService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  Future<List<ListingCardModel>> getAllListings({
    bool all = true,
    String? priceSort,
    String? yearSort,
    String? kmSort,
  }) async {
    final response = await _dio.get(
      '/api/listings',
      queryParameters: {
        'all': all,
        if (priceSort != null && priceSort.trim().isNotEmpty) 'priceSort': priceSort.trim(),
        if (yearSort != null && yearSort.trim().isNotEmpty) 'yearSort': yearSort.trim(),
        if (kmSort != null && kmSort.trim().isNotEmpty) 'kmSort': kmSort.trim(),
      },
    );

    final data = response.data;
    if (data is! List) return [];

    return data
        .map((e) => ListingCardModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<List<int>> rankStores({
    required List<int> storeIds,
    required String seedKey,
  }) async {
    if (storeIds.isEmpty) return [];

    final response = await _dio.post(
      '/api/home/stores/rank',
      data: {
        'storeIds': storeIds,
        'seedKey': seedKey,
      },
    );

    final data = response.data;
    if (data is! List) return storeIds;

    return data
        .map((e) => int.tryParse(e.toString()) ?? 0)
        .where((e) => e > 0)
        .toList();
  }
}