class StoreListingCreatedDto {
  final int? id;
  final String title;
  final double? price;
  final String currency;
  final String city;
  final String district;
  final String coverImageUrl;

  StoreListingCreatedDto({
    required this.id,
    required this.title,
    required this.price,
    required this.currency,
    required this.city,
    required this.district,
    required this.coverImageUrl,
  });

  factory StoreListingCreatedDto.fromJson(Map<String, dynamic> json) {
    return StoreListingCreatedDto(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id'] ?? ''}'),
      title: (json['title'] ?? '').toString(),
      price: _toDouble(json['price']),
      currency: (json['currency'] ?? '').toString(),
      city: (json['city'] ?? '').toString(),
      district: (json['district'] ?? '').toString(),
      coverImageUrl: (json['coverImageUrl'] ?? '').toString(),
    );
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }
}