import 'store_notification_dto.dart';

class StoreNotificationListResponse {
  final List<StoreNotificationDto> items;

  StoreNotificationListResponse({
    required this.items,
  });

  factory StoreNotificationListResponse.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];

    return StoreNotificationListResponse(
      items: rawItems is List
          ? rawItems
          .map(
            (e) => StoreNotificationDto.fromJson(
          Map<String, dynamic>.from(e),
        ),
      )
          .toList()
          : [],
    );
  }
}