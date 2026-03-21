import 'package:dio/dio.dart';
import 'package:otoport_mobile/core/constants/api_constants.dart';
import '../models/similar_listing_model.dart';

class SimilarListingService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  Future<List<SimilarListingModel>> getSimilar(
      int listingId, {
        int limit = 8,
      }) async {
    final response = await _dio.get(
      '/api/listings/$listingId/similar',
      queryParameters: {
        'limit': limit,
      },
    );

    final List data = response.data;

    return data
        .map(
          (e) => SimilarListingModel.fromJson(
        Map<String, dynamic>.from(e),
      ),
    )
        .toList();
  }
}