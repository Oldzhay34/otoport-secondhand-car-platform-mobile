import 'store_inquiry_list_item_dto.dart';

class StoreInquiryListResponse {
  final List<StoreInquiryListItemDto> items;

  StoreInquiryListResponse({
    required this.items,
  });

  factory StoreInquiryListResponse.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];

    return StoreInquiryListResponse(
      items: rawItems is List
          ? rawItems
          .map(
            (e) => StoreInquiryListItemDto.fromJson(
          Map<String, dynamic>.from(e),
        ),
      )
          .toList()
          : [],
    );
  }
}