class AdminStoreOptionDto {
  final int? id;
  final String name;
  final String city;
  final String district;

  const AdminStoreOptionDto({
    required this.id,
    required this.name,
    required this.city,
    required this.district,
  });

  String get displayLabel {
    final parts = <String>[
      if (name.trim().isNotEmpty) name.trim(),
      if (city.trim().isNotEmpty) city.trim(),
      if (district.trim().isNotEmpty) district.trim(),
    ];

    return parts.isEmpty ? 'Store' : parts.join(' • ');
  }

  factory AdminStoreOptionDto.fromJson(Map<String, dynamic> json) {
    return AdminStoreOptionDto(
      id: (json['id'] as num?)?.toInt(),
      name: (json['name'] ?? '').toString(),
      city: (json['city'] ?? '').toString(),
      district: (json['district'] ?? '').toString(),
    );
  }
}