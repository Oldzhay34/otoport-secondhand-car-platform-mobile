class StoreCardModel {
  final int id;
  final String? storeName;
  final String? city;
  final String? district;
  final bool verified;
  final int? floor;
  final String? shopNo;
  final String? directionNote;
  final String? logoUrl;
  final String? phone;

  StoreCardModel({
    required this.id,
    required this.storeName,
    required this.city,
    required this.district,
    required this.verified,
    required this.floor,
    required this.shopNo,
    required this.directionNote,
    required this.logoUrl,
    required this.phone,
  });

  factory StoreCardModel.fromJson(Map<String, dynamic> json) {
    return StoreCardModel(
      id: (json['id'] ?? 0) as int,
      storeName: json['storeName']?.toString(),
      city: json['city']?.toString(),
      district: json['district']?.toString(),
      verified: json['verified'] == true,
      floor: json['floor'] as int?,
      shopNo: json['shopNo']?.toString(),
      directionNote: json['directionNote']?.toString(),
      logoUrl: json['logoUrl']?.toString(),
      phone: json['phone']?.toString(),
    );
  }
}