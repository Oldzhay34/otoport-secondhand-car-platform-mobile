class StorePublicModel {
  final int id;
  final String? storeName;
  final bool verified;

  final String? city;
  final String? district;
  final String? addressLine;

  final String? phone;
  final String? website;

  final int? floor;
  final String? shopNo;
  final String? directionNote;

  final String? logoUrl;

  StorePublicModel({
    required this.id,
    required this.storeName,
    required this.verified,
    required this.city,
    required this.district,
    required this.addressLine,
    required this.phone,
    required this.website,
    required this.floor,
    required this.shopNo,
    required this.directionNote,
    required this.logoUrl,
  });

  factory StorePublicModel.fromJson(Map<String, dynamic> json) {
    return StorePublicModel(
      id: (json['id'] ?? 0) as int,
      storeName: json['storeName']?.toString(),
      verified: json['verified'] == true,
      city: json['city']?.toString(),
      district: json['district']?.toString(),
      addressLine: json['addressLine']?.toString(),
      phone: json['phone']?.toString(),
      website: json['website']?.toString(),
      floor: json['floor'] as int?,
      shopNo: json['shopNo']?.toString(),
      directionNote: json['directionNote']?.toString(),
      logoUrl: json['logoUrl']?.toString(),
    );
  }
}