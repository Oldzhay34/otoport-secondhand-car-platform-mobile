class FavoriteCardModel {
  final int? listingId;
  final String title;
  final String? city;
  final int? year;
  final int? kilometer;
  final String? brand;
  final String? model;
  final String? engine;
  final String? storeName;
  final String? imagePath;
  final double? price;
  final String? currency;
  final int? viewCount;
  final int? favoriteCount;

  FavoriteCardModel({
    required this.listingId,
    required this.title,
    required this.city,
    required this.year,
    required this.kilometer,
    required this.brand,
    required this.model,
    required this.engine,
    required this.storeName,
    required this.imagePath,
    required this.price,
    required this.currency,
    required this.viewCount,
    required this.favoriteCount,
  });

  factory FavoriteCardModel.fromJson(Map<String, dynamic> json) {
    return FavoriteCardModel(
      listingId: _toInt(json['listingId']),
      title: (json['title'] ?? 'İlan').toString(),
      city: json['city']?.toString(),
      year: _toInt(json['year']),
      kilometer: _toInt(json['kilometer']),
      brand: json['brand']?.toString(),
      model: json['model']?.toString(),
      engine: json['engine']?.toString(),
      storeName: json['storeName']?.toString(),
      imagePath: (json['imagePath'] ?? json['coverImageUrl'])?.toString(),
      price: _toDouble(json['price']),
      currency: json['currency']?.toString(),
      viewCount: _toInt(json['viewCount']),
      favoriteCount: _toInt(json['favoriteCount']),
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