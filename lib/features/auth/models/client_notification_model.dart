class ClientNotificationModel {
  final int? id;
  final String title;
  final String message;
  final String? createdAt;
  final bool isRead;
  final int? listingId;

  ClientNotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.createdAt,
    required this.isRead,
    required this.listingId,
  });

  factory ClientNotificationModel.fromJson(Map<String, dynamic> json) {
    return ClientNotificationModel(
      id: _toInt(json['id']),
      title: (json['title'] ?? 'Bildirim').toString(),
      message: (json['message'] ?? '').toString(),
      createdAt: json['createdAt']?.toString(),
      isRead: json['isRead'] == true || json['read'] == true,
      listingId: _toInt(json['listingId']),
    );
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }
}