class MostViewedListingModel {
  final int? id;
  final String title;
  final double? price;
  final String? currency;
  final bool negotiable;
  final String? city;
  final String? district;
  final int? viewCount;
  final int? favoriteCount;
  final DateTime? publishedAt;
  final String? coverImageUrl;
  final String? brand;
  final String? model;
  final String? engine;
  final int? year;
  final int? kilometer;
  final String? pack;
  final String? storeName;
  final String? detailUrl;

  const MostViewedListingModel({
    required this.id,
    required this.title,
    required this.price,
    required this.currency,
    required this.negotiable,
    required this.city,
    required this.district,
    required this.viewCount,
    required this.favoriteCount,
    required this.publishedAt,
    required this.coverImageUrl,
    required this.brand,
    required this.model,
    required this.engine,
    required this.year,
    required this.kilometer,
    required this.pack,
    required this.storeName,
    required this.detailUrl,
  });

  factory MostViewedListingModel.fromJson(Map<String, dynamic> json) {
    return MostViewedListingModel(
      id: _toInt(json['id']),
      title: (json['title'] ?? 'İlan').toString(),
      price: _toDouble(json['price']),
      currency: json['currency']?.toString(),
      negotiable: _toBool(json['negotiable']),
      city: json['city']?.toString(),
      district: json['district']?.toString(),
      viewCount: _toInt(json['viewCount']),
      favoriteCount: _toInt(json['favoriteCount']),
      publishedAt: _toDateTime(json['publishedAt']),
      coverImageUrl: json['coverImageUrl']?.toString(),
      brand: json['brand']?.toString(),
      model: json['model']?.toString(),
      engine: json['engine']?.toString(),
      year: _toInt(json['year']),
      kilometer: _toInt(json['kilometer']),
      pack: json['pack']?.toString(),
      storeName: json['storeName']?.toString(),
      detailUrl: json['detailUrl']?.toString(),
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

  static bool _toBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    final s = value.toString().toLowerCase().trim();
    return s == 'true' || s == '1';
  }

  static DateTime? _toDateTime(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}