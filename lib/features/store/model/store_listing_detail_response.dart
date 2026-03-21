import 'car_summary_dto.dart';
import 'listing_image_dto.dart';
import 'store_summary_dto.dart';

class StoreListingDetailResponse {
  final int? id;
  final String title;
  final String description;
  final double? price;
  final String currency;
  final bool negotiable;
  final String city;
  final String district;
  final String status;
  final int viewCount;
  final int favoriteCount;
  final DateTime? createdAt;
  final DateTime? publishedAt;
  final StoreSummaryDto? store;
  final CarSummaryDto? car;
  final List<ListingImageDto> images;

  StoreListingDetailResponse({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.currency,
    required this.negotiable,
    required this.city,
    required this.district,
    required this.status,
    required this.viewCount,
    required this.favoriteCount,
    required this.createdAt,
    required this.publishedAt,
    required this.store,
    required this.car,
    required this.images,
  });

  factory StoreListingDetailResponse.fromJson(Map<String, dynamic> json) {
    final rawImages = json['images'];

    return StoreListingDetailResponse(
      id: _toInt(json['id']),
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      price: _toDouble(json['price']),
      currency: (json['currency'] ?? 'TRY').toString(),
      negotiable: json['negotiable'] == true,
      city: (json['city'] ?? '').toString(),
      district: (json['district'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      viewCount: _toInt(json['viewCount']) ?? 0,
      favoriteCount: _toInt(json['favoriteCount']) ?? 0,
      createdAt: _toDateTime(json['createdAt']),
      publishedAt: _toDateTime(json['publishedAt']),
      store: json['store'] is Map<String, dynamic>
          ? StoreSummaryDto.fromJson(Map<String, dynamic>.from(json['store']))
          : null,
      car: json['car'] is Map<String, dynamic>
          ? CarSummaryDto.fromJson(Map<String, dynamic>.from(json['car']))
          : null,
      images: rawImages is List
          ? rawImages
          .map((e) => ListingImageDto.fromJson(Map<String, dynamic>.from(e)))
          .toList()
          : [],
    );
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString());
  }

  static DateTime? _toDateTime(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}