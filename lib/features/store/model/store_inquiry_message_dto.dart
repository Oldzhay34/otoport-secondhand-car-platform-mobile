class StoreInquiryMessageDto {
  final int? id;
  final String senderType;
  final String content;
  final DateTime? sentAt;

  StoreInquiryMessageDto({
    required this.id,
    required this.senderType,
    required this.content,
    required this.sentAt,
  });

  factory StoreInquiryMessageDto.fromJson(Map<String, dynamic> json) {
    return StoreInquiryMessageDto(
      id: _toInt(json['id']),
      senderType: (json['senderType'] ?? '').toString(),
      content: (json['content'] ?? '').toString(),
      sentAt: _toDateTime(json['sentAt']),
    );
  }

  bool get isStoreSender => senderType.trim().toUpperCase() == 'STORE';

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