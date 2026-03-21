class InquiryUpsertRequest {
  final int listingId;
  final int storeId;
  final String message;

  final String? guestName;
  final String? guestEmail;
  final String? guestPhone;

  InquiryUpsertRequest({
    required this.listingId,
    required this.storeId,
    required this.message,
    this.guestName,
    this.guestEmail,
    this.guestPhone,
  });

  Map<String, dynamic> toJson() {
    return {
      'listingId': listingId,
      'storeId': storeId,
      'message': message,
      'guestName': guestName,
      'guestEmail': guestEmail,
      'guestPhone': guestPhone,
    };
  }
}