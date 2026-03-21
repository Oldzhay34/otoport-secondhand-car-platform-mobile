class AdminNotificationCreateRequest {
  final int? storeId;
  final String? type;
  final String title;
  final String? message;
  final String? payloadJson;

  const AdminNotificationCreateRequest({
    required this.storeId,
    required this.type,
    required this.title,
    required this.message,
    required this.payloadJson,
  });

  Map<String, dynamic> toJson() {
    return {
      if (storeId != null) 'storeId': storeId,
      if (type != null && type!.trim().isNotEmpty) 'type': type!.trim(),
      'title': title,
      'message': message,
      'payloadJson': payloadJson,
    };
  }
}