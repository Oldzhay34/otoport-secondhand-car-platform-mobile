import 'store_listing_row_dto.dart';

class StoreHomeDto {
  final int? storeId;
  final String storeName;
  final String city;
  final String district;
  final bool verified;
  final List<StoreListingRowDto> listings;

  final bool subscriptionExpired;
  final DateTime? subscriptionEndsAt;
  final int listingLimit;
  final int activeListingCount;
  final bool canCreateListing;

  StoreHomeDto({
    required this.storeId,
    required this.storeName,
    required this.city,
    required this.district,
    required this.verified,
    required this.listings,
    required this.subscriptionExpired,
    required this.subscriptionEndsAt,
    required this.listingLimit,
    required this.activeListingCount,
    required this.canCreateListing,
  });

  factory StoreHomeDto.fromJson(Map<String, dynamic> json) {
    final rawListings = json['listings'];

    return StoreHomeDto(
      storeId: _toInt(json['storeId'] ?? json['id']),
      storeName: (json['storeName'] ?? 'Mağaza').toString(),
      city: (json['city'] ?? '').toString(),
      district: (json['district'] ?? '').toString(),
      verified: json['verified'] == true,
      listings: rawListings is List
          ? rawListings
          .map((e) => StoreListingRowDto.fromJson(Map<String, dynamic>.from(e)))
          .toList()
          : [],
      subscriptionExpired: json['subscriptionExpired'] == true,
      subscriptionEndsAt: _toDateTime(json['subscriptionEndsAt']),
      listingLimit: _toInt(json['listingLimit']) ?? 0,
      activeListingCount: _toInt(json['activeListingCount']) ?? 0,
      canCreateListing: json['canCreateListing'] == true,
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

  static DateTime? _toDateTime(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}