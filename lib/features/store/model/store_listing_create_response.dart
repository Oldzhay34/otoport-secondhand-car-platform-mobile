import 'package:otoport_mobile/features/store/model/store_listing_created_dto.dart';

class StoreListingCreateResponse {
  final bool ok;
  final StoreListingCreatedDto? listing;

  StoreListingCreateResponse({
    required this.ok,
    required this.listing,
  });

  factory StoreListingCreateResponse.fromJson(Map<String, dynamic> json) {
    return StoreListingCreateResponse(
      ok: json['ok'] == true,
      listing: json['listing'] is Map<String, dynamic>
          ? StoreListingCreatedDto.fromJson(
        Map<String, dynamic>.from(json['listing']),
      )
          : null,
    );
  }
}