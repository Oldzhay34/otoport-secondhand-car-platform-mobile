class AdminStoreListingActivityDto {
  final int? storeId;
  final String storeName;
  final int creates;
  final int deletes;
  final int updates;

  const AdminStoreListingActivityDto({
    required this.storeId,
    required this.storeName,
    required this.creates,
    required this.deletes,
    required this.updates,
  });

  int get totalActions => creates + deletes + updates;

  factory AdminStoreListingActivityDto.fromJson(Map<String, dynamic> json) {
    return AdminStoreListingActivityDto(
      storeId: (json['storeId'] as num?)?.toInt(),
      storeName: (json['storeName'] ?? '').toString(),
      creates: (json['creates'] as num?)?.toInt() ?? 0,
      deletes: (json['deletes'] as num?)?.toInt() ?? 0,
      updates: (json['updates'] as num?)?.toInt() ?? 0,
    );
  }
}