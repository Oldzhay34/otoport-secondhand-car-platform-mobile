class InquiryMessageModel {
  final int? id;
  final String? senderType;
  final String? content;
  final String? sentAt;

  InquiryMessageModel({
    required this.id,
    required this.senderType,
    required this.content,
    required this.sentAt,
  });

  factory InquiryMessageModel.fromJson(Map<String, dynamic> json) {
    return InquiryMessageModel(
      id: (json['id'] as num?)?.toInt(),
      senderType: json['senderType']?.toString(),
      content: json['content']?.toString(),
      sentAt: json['sentAt']?.toString(),
    );
  }
}