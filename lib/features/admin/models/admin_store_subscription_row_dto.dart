class AdminStoreSubscriptionRowDto {
  final int? storeId;
  final String storeName;
  final String city;
  final String district;
  final String plan;
  final int? listingLimit;
  final int? featuredLimit;
  final bool isActive;

  const AdminStoreSubscriptionRowDto({
    required this.storeId,
    required this.storeName,
    required this.city,
    required this.district,
    required this.plan,
    required this.listingLimit,
    required this.featuredLimit,
    required this.isActive,
  });

  String get locationText {
    final parts = <String>[
      if (city.trim().isNotEmpty) city.trim(),
      if (district.trim().isNotEmpty) district.trim(),
    ];
    return parts.join(' • ');
  }

  factory AdminStoreSubscriptionRowDto.fromJson(Map<String, dynamic> json) {
    return AdminStoreSubscriptionRowDto(
      storeId: (json['storeId'] as num?)?.toInt(),
      storeName: (json['storeName'] ?? '').toString(),
      city: (json['city'] ?? '').toString(),
      district: (json['district'] ?? '').toString(),
      plan: (json['plan'] ?? '').toString(),
      listingLimit: (json['listingLimit'] as num?)?.toInt(),
      featuredLimit: (json['featuredLimit'] as num?)?.toInt(),
      isActive: (json['isActive'] as bool?) ?? false,
    );
  }
}