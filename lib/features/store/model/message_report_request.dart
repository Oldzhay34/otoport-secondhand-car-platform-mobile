class MessageReportRequest {
  final String reason;
  final String? details;

  MessageReportRequest({
    required this.reason,
    required this.details,
  });

  Map<String, dynamic> toJson() {
    return {
      'reason': reason,
      'details': details,
    };
  }
}