class InquiryReplyRequest {
  final String message;

  InquiryReplyRequest({
    required this.message,
  });

  Map<String, dynamic> toJson() {
    return {
      'message': message,
    };
  }
}