class ListingCardModel {
  final int? id;
  final int? storeId;
  final String? storeName;
  final String title;
  final double? price;
  final String? currency;
  final String? city;
  final String? district;
  final int? year;
  final int? kilometer;
  final int? viewCount;
  final int? favoriteCount;
  final String? brand;
  final String? model;
  final String? engine;
  final String? bodyType;
  final String? fuelType;
  final String? transmission;
  final String? coverImageUrl;

  ListingCardModel({
    required this.id,
    required this.storeId,
    required this.storeName,
    required this.title,
    required this.price,
    required this.currency,
    required this.city,
    required this.district,
    required this.year,
    required this.kilometer,
    required this.viewCount,
    required this.favoriteCount,
    required this.brand,
    required this.model,
    required this.engine,
    required this.bodyType,
    required this.fuelType,
    required this.transmission,
    required this.coverImageUrl,
  });

  factory ListingCardModel.fromJson(Map<String, dynamic> json) {
    return ListingCardModel(
      id: _toInt(json['id']),
      storeId: _toInt(json['storeId']),
      storeName: json['storeName']?.toString(),
      title: (json['title'] ?? 'İlan').toString(),
      price: _toDouble(json['price']),
      currency: json['currency']?.toString(),
      city: json['city']?.toString(),
      district: json['district']?.toString(),
      year: _toInt(json['year']),
      kilometer: _toInt(json['kilometer']),
      viewCount: _toInt(json['viewCount']),
      favoriteCount: _toInt(json['favoriteCount']),
      brand: json['brand']?.toString(),
      model: json['model']?.toString(),
      engine: json['engine']?.toString(),
      bodyType: json['bodyType']?.toString(),
      fuelType: json['fuelType']?.toString(),
      transmission: json['transmission']?.toString(),
      coverImageUrl: json['coverImageUrl']?.toString(),
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