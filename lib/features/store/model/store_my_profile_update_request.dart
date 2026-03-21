class StoreMyProfileUpdateRequest {
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

  StoreMyProfileUpdateRequest({
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
  });

  Map<String, dynamic> toJson() {
    return {
      'storeName': storeName,
      'authorizedPerson': authorizedPerson,
      'taxNo': taxNo,
      'website': website,
      'city': city,
      'district': district,
      'addressLine': addressLine,
      'floor': floor,
      'shopNo': shopNo,
      'directionNote': directionNote,
      'phone': phone,
    };
  }
}