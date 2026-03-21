class StoreListingRowDto {
  final int? id;
  final String title;
  final String coverImageUrl;
  final String status;
  final double? price;
  final String currency;
  final DateTime? createdAt;

  StoreListingRowDto({
    required this.id,
    required this.title,
    required this.coverImageUrl,
    required this.status,
    required this.price,
    required this.currency,
    required this.createdAt,
  });

  factory StoreListingRowDto.fromJson(Map<String, dynamic> json) {
    return StoreListingRowDto(
      id: _toInt(json['id']),
      title: (json['title'] ?? '').toString(),
      coverImageUrl: (json['coverImageUrl'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      price: _toDouble(json['price']),
      currency: (json['currency'] ?? 'TRY').toString(),
      createdAt: _toDateTime(json['createdAt']),
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