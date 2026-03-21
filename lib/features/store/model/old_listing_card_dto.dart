class OldListingCardDto {
  final int? id;
  final String title;
  final double? price;
  final String currency;
  final String city;
  final int? year;
  final int? kilometer;
  final String coverImageUrl;
  final DateTime? deletedAt;

  OldListingCardDto({
    required this.id,
    required this.title,
    required this.price,
    required this.currency,
    required this.city,
    required this.year,
    required this.kilometer,
    required this.coverImageUrl,
    required this.deletedAt,
  });

  factory OldListingCardDto.fromJson(Map<String, dynamic> json) {
    return OldListingCardDto(
      id: _toInt(json['id']),
      title: (json['title'] ?? '').toString(),
      price: _toDouble(json['price']),
      currency: (json['currency'] ?? 'TRY').toString(),
      city: (json['city'] ?? '').toString(),
      year: _toInt(json['year']),
      kilometer: _toInt(json['kilometer']),
      coverImageUrl: (json['coverImageUrl'] ?? '').toString(),
      deletedAt: _toDateTime(json['deletedAt']),
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