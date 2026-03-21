import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:otoport_mobile/core/constants/api_constants.dart';
import 'package:otoport_mobile/features/auth/models/expert_report_model.dart';

class ExpertReportService {
  late final Dio _dio;

  ExpertReportService() {
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

  Future<ExpertReportModel> getByListingId(int listingId) async {
    final response = await _dio.get('/api/listings/$listingId/expert-report');
    return ExpertReportModel.fromJson(
      Map<String, dynamic>.from(response.data),
    );
  }

  Future<ExpertReportModel> getByCarId(int carId) async {
    final response = await _dio.get('/api/cars/$carId/expert-report');
    return ExpertReportModel.fromJson(
      Map<String, dynamic>.from(response.data),
    );
  }
}