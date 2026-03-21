class StoreMyProfileDto {
  final int? id;
  final String storeName;
  final String authorizedPerson;
  final String taxNo;
  final String website;
  final String city;
  final String district;
  final String addressLine;
  final String floor;
  final String shopNo;
  final String directionNote;
  final String phone;
  final bool verified;
  final int listingLimit;
  final String logoUrl;

  StoreMyProfileDto({
    required this.id,
    required this.storeName,
    required this.authorizedPerson,
    required this.taxNo,
    required this.website,
    required this.city,
    required this.district,
    required this.addressLine,
    required this.floor,
    required this.shopNo,
    required this.directionNote,
    required this.phone,
    required this.verified,
    required this.listingLimit,
    required this.logoUrl,
  });

  factory StoreMyProfileDto.fromJson(Map<String, dynamic> json) {
    return StoreMyProfileDto(
      id: json['id'],
      storeName: (json['storeName'] ?? '').toString(),
      authorizedPerson: (json['authorizedPerson'] ?? '').toString(),
      taxNo: (json['taxNo'] ?? '').toString(),
      website: (json['website'] ?? '').toString(),
      city: (json['city'] ?? '').toString(),
      district: (json['district'] ?? '').toString(),
      addressLine: (json['addressLine'] ?? '').toString(),
      floor: (json['floor'] ?? '').toString(),
      shopNo: (json['shopNo'] ?? '').toString(),
      directionNote: (json['directionNote'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      verified: json['verified'] ?? false,
      listingLimit: json['listingLimit'] ?? 0,
      logoUrl: (json['logoUrl'] ?? '').toString(),
    );
  }
}