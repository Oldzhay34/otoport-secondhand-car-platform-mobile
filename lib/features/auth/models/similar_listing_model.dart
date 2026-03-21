class SimilarListingModel {
  final int listingId;
  final String? title;
  final num? price;
  final String? currency;
  final String? city;

  final String? coverImageUrl;

  final int? year;
  final String? brandName;
  final String? modelName;
  final int? kilometer;

  SimilarListingModel({
    required this.listingId,
    required this.title,
    required this.price,
    required this.currency,
    required this.city,
    required this.coverImageUrl,
    required this.year,
    required this.brandName,
    required this.modelName,
    required this.kilometer,
  });

  factory SimilarListingModel.fromJson(Map<String, dynamic> json) {
    return SimilarListingModel(
      listingId: (json['listingId'] as num?)?.toInt() ?? 0,
      title: json['title']?.toString(),
      price: json['price'] as num?,
      currency: json['currency']?.toString(),
      city: json['city']?.toString(),
      coverImageUrl: json['coverImageUrl']?.toString(),
      year: (json['year'] as num?)?.toInt(),
      brandName: json['brandName']?.toString(),
      modelName: json['modelName']?.toString(),
      kilometer: (json['kilometer'] as num?)?.toInt(),
    );
  }
}