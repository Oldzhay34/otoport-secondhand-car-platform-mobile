class StoreNotificationDto {
  final int? id;
  final String type;
  final String title;
  final String message;
  final String payloadJson;
  final bool isRead;
  final DateTime? readAt;
  final DateTime? createdAt;

  StoreNotificationDto({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.payloadJson,
    required this.isRead,
    required this.readAt,
    required this.createdAt,
  });

  factory StoreNotificationDto.fromJson(Map<String, dynamic> json) {
    return StoreNotificationDto(
      id: _toInt(json['id']),
      type: (json['type'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      message: (json['message'] ?? '').toString(),
      payloadJson: (json['payloadJson'] ?? '').toString(),
      isRead: json['isRead'] == true,
      readAt: _toDateTime(json['readAt']),
      createdAt: _toDateTime(json['createdAt']),
    );
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