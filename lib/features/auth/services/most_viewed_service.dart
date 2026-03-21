import 'package:dio/dio.dart';
import 'package:otoport_mobile/core/constants/api_constants.dart';
import '../models/most_viewed_response_model.dart';

class MostViewedService {
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

  Future<MostViewedResponseModel> getMostViewed({int limit = 20}) async {
    final response = await _dio.get(
      '/api/public/most-viewed',
      queryParameters: {
        'limit': limit,
      },
    );

    return MostViewedResponseModel.fromJson(
      Map<String, dynamic>.from(response.data),
    );
  }
}