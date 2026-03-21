class StoreInquiryListItemDto {
  final int? inquiryId;
  final int? listingId;
  final String listingTitle;
  final String clientName;
  final String clientEmail;
  final String guestName;
  final String guestEmail;
  final String guestPhone;
  final String status;
  final DateTime? createdAt;
  final String lastMessage;
  final DateTime? lastSentAt;
  final int unreadCount;

  StoreInquiryListItemDto({
    required this.inquiryId,
    required this.listingId,
    required this.listingTitle,
    required this.clientName,
    required this.clientEmail,
    required this.guestName,
    required this.guestEmail,
    required this.guestPhone,
    required this.status,
    required this.createdAt,
    required this.lastMessage,
    required this.lastSentAt,
    required this.unreadCount,
  });

  factory StoreInquiryListItemDto.fromJson(Map<String, dynamic> json) {
    return StoreInquiryListItemDto(
      inquiryId: _toInt(json['inquiryId']),
      listingId: _toInt(json['listingId']),
      listingTitle: (json['listingTitle'] ?? '').toString(),
      clientName: (json['clientName'] ?? '').toString(),
      clientEmail: (json['clientEmail'] ?? '').toString(),
      guestName: (json['guestName'] ?? '').toString(),
      guestEmail: (json['guestEmail'] ?? '').toString(),
      guestPhone: (json['guestPhone'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      createdAt: _toDateTime(json['createdAt']),
      lastMessage: (json['lastMessage'] ?? '').toString(),
      lastSentAt: _toDateTime(json['lastSentAt']),
      unreadCount: _toInt(json['unreadCount']) ?? 0,
    );
  }

  String get displayName {
    if (clientName.trim().isNotEmpty) return clientName.trim();
    if (guestName.trim().isNotEmpty) return guestName.trim();
    if (clientEmail.trim().isNotEmpty) return clientEmail.trim();
    if (guestEmail.trim().isNotEmpty) return guestEmail.trim();
    return 'Müşteri';
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