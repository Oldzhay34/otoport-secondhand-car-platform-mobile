class AdminCreateStoreAccountResponse {
  final int? storeId;
  final String storeName;
  final String plan;

  const AdminCreateStoreAccountResponse({
    required this.storeId,
    required this.storeName,
    required this.plan,
  });

  factory AdminCreateStoreAccountResponse.fromJson(Map<String, dynamic> json) {
    return AdminCreateStoreAccountResponse(
      storeId: (json['storeId'] as num?)?.toInt(),
      storeName: (json['storeName'] ?? '').toString(),
      plan: (json['plan'] ?? '').toString(),
    );
  }
}