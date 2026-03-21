class AdminCreateStoreAccountRequest {
  final int buildingId;
  final String storeName;
  final String? city;
  final String? district;
  final String? phone;
  final String? shopNo;
  final int? floor;
  final String? addressLine;
  final String? website;
  final String? authorizedPerson;
  final String? taxNo;
  final bool? verified;
  final String password;

  const AdminCreateStoreAccountRequest({
    required this.buildingId,
    required this.storeName,
    required this.password,
    this.city,
    this.district,
    this.phone,
    this.shopNo,
    this.floor,
    this.addressLine,
    this.website,
    this.authorizedPerson,
    this.taxNo,
    this.verified,
  });

  Map<String, dynamic> toJson() {
    return {
      'buildingId': buildingId,
      'storeName': storeName,
      'city': city,
      'district': district,
      'phone': phone,
      'shopNo': shopNo,
      'floor': floor,
      'addressLine': addressLine,
      'website': website,
      'authorizedPerson': authorizedPerson,
      'taxNo': taxNo,
      'verified': verified,
      'password': password,
    };
  }
}