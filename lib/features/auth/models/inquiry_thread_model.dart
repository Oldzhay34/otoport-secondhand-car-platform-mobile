import 'inquiry_message_model.dart';

class InquiryThreadModel {
  final int? inquiryId;
  final int? listingId;
  final int? storeId;

  final String? status;
  final String? createdAt;

  final String? guestName;
  final String? guestEmail;
  final String? guestPhone;

  final String? clientEmail;
  final List<InquiryMessageModel> messages;

  InquiryThreadModel({
    required this.inquiryId,
    required this.listingId,
    required this.storeId,
    required this.status,
    required this.createdAt,
    required this.guestName,
    required this.guestEmail,
    required this.guestPhone,
    required this.clientEmail,
    required this.messages,
  });

  factory InquiryThreadModel.fromJson(Map<String, dynamic> json) {
    final rawMessages = (json['messages'] as List?) ?? const [];

    return InquiryThreadModel(
      inquiryId: (json['inquiryId'] as num?)?.toInt(),
      listingId: (json['listingId'] as num?)?.toInt(),
      storeId: (json['storeId'] as num?)?.toInt(),
      status: json['status']?.toString(),
      createdAt: json['createdAt']?.toString(),
      guestName: json['guestName']?.toString(),
      guestEmail: json['guestEmail']?.toString(),
      guestPhone: json['guestPhone']?.toString(),
      clientEmail: json['clientEmail']?.toString(),
      messages: rawMessages
          .map(
            (e) => InquiryMessageModel.fromJson(
          Map<String, dynamic>.from(e as Map),
        ),
      )
          .toList(),
    );
  }
}