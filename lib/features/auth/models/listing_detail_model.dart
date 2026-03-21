import 'car_detail_model.dart';
import 'expert_report_model.dart';
import 'listing_image_model.dart';
import 'store_card_model.dart';

class ListingDetailModel {
  final int id;
  final String? title;
  final String? description;

  final num? price;
  final String? currency;
  final bool negotiable;

  final String? city;
  final String? district;

  final String? status;
  final int? viewCount;
  final int? favoriteCount;

  final String? createdAt;
  final String? publishedAt;

  final StoreCardModel? store;
  final CarDetailModel? car;
  final List<String> features;
  final List<ListingImageModel> images;
  final ExpertReportModel? expertReport;

  final bool? favoritedByMe;

  ListingDetailModel({
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
    required this.features,
    required this.images,
    required this.expertReport,
    required this.favoritedByMe,
  });

  factory ListingDetailModel.fromJson(Map<String, dynamic> json) {
    final rawFeatures = (json['features'] as List?) ?? const [];
    final rawImages = (json['images'] as List?) ?? const [];

    return ListingDetailModel(
      id: (json['id'] ?? 0) as int,
      title: json['title']?.toString(),
      description: json['description']?.toString(),
      price: json['price'] as num?,
      currency: json['currency']?.toString(),
      negotiable: json['negotiable'] == true,
      city: json['city']?.toString(),
      district: json['district']?.toString(),
      status: json['status']?.toString(),
      viewCount: (json['viewCount'] as num?)?.toInt(),
      favoriteCount: (json['favoriteCount'] as num?)?.toInt(),
      createdAt: json['createdAt']?.toString(),
      publishedAt: json['publishedAt']?.toString(),
      store: json['store'] != null
          ? StoreCardModel.fromJson(Map<String, dynamic>.from(json['store']))
          : null,
      car: json['car'] != null
          ? CarDetailModel.fromJson(Map<String, dynamic>.from(json['car']))
          : null,
      features: rawFeatures.map((e) => e.toString()).toList(),
      images: rawImages
          .map((e) => ListingImageModel.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      expertReport: json['expertReport'] != null
          ? ExpertReportModel.fromJson(
        Map<String, dynamic>.from(json['expertReport']),
      )
          : null,
      favoritedByMe: json['favoritedByMe'] as bool?,
    );
  }
}