class StoreSummaryDto {
  final int? id;
  final String storeName;
  final String city;
  final String district;
  final String phone;
  final String logoUrl;

  StoreSummaryDto({
    required this.id,
    required this.storeName,
    required this.city,
    required this.district,
    required this.phone,
    required this.logoUrl,
  });

  factory StoreSummaryDto.fromJson(Map<String, dynamic> json) {
    return StoreSummaryDto(
      id: _toInt(json['id']),
      storeName: (json['storeName'] ?? '').toString(),
      city: (json['city'] ?? '').toString(),
      district: (json['district'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      logoUrl: (json['logoUrl'] ?? '').toString(),
    );
  }

  String get locationText {
    final parts = <String>[];
    if (city.trim().isNotEmpty) parts.add(city.trim());
    if (district.trim().isNotEmpty) parts.add(district.trim());
    return parts.join(' • ');
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }
}