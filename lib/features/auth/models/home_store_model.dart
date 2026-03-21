class HomeStoreModel {
  final int? id;
  final String name;
  final String city;
  final String district;
  final String image;
  final int? listingCount;
  final bool verified;
  final double? rating;

  HomeStoreModel({
    required this.id,
    required this.name,
    required this.city,
    required this.district,
    required this.image,
    required this.listingCount,
    required this.verified,
    required this.rating,
  });

  factory HomeStoreModel.fromJson(Map<String, dynamic> json) {
    return HomeStoreModel(
      id: _toInt(json['id']),
      name: (json['storeName'] ?? json['name'] ?? 'Mağaza').toString(),
      city: (json['city'] ?? '').toString(),
      district: (json['district'] ?? '').toString(),
      image: (json['logoUrl'] ??
          json['logoURL'] ??
          json['image'] ??
          '/imagesforapp/logo2.png')
          .toString(),
      listingCount: _toInt(
        json['listingCount'] ??
            json['adsCount'] ??
            json['carCount'] ??
            json['count'],
      ),
      verified: json['verified'] == true ||
          json['isVerified'] == true ||
          json['trusted'] == true,
      rating: _toDouble(json['rating'] ?? json['score']),
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