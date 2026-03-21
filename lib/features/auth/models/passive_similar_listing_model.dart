class PassiveSimilarListingModel {
  final int? listingId;
  final String title;
  final double? price;
  final String? currency;
  final String? city;
  final String? coverImageUrl;
  final int? year;
  final String? brandName;
  final String? modelName;
  final int? kilometer;

  PassiveSimilarListingModel({
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

  factory PassiveSimilarListingModel.fromJson(Map<String, dynamic> json) {
    return PassiveSimilarListingModel(
      listingId: _toInt(json['listingId']),
      title: (json['title'] ?? 'İlan').toString(),
      price: _toDouble(json['price']),
      currency: json['currency']?.toString(),
      city: json['city']?.toString(),
      coverImageUrl: json['coverImageUrl']?.toString(),
      year: _toInt(json['year']),
      brandName: json['brandName']?.toString(),
      modelName: json['modelName']?.toString(),
      kilometer: _toInt(json['kilometer']),
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
}