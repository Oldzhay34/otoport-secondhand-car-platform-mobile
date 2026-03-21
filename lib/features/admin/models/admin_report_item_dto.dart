class AdminReportItemDto {
  final int? id;
  final int? storeId;
  final int? inquiryId;
  final int? messageId;
  final String reporterType;
  final int? reporterId;
  final String reason;
  final String details;
  final String status;
  final DateTime? createdAt;
  final DateTime? resolvedAt;
  final String messageText;
  final String senderType;
  final DateTime? messageSentAt;

  const AdminReportItemDto({
    required this.id,
    required this.storeId,
    required this.inquiryId,
    required this.messageId,
    required this.reporterType,
    required this.reporterId,
    required this.reason,
    required this.details,
    required this.status,
    required this.createdAt,
    required this.resolvedAt,
    required this.messageText,
    required this.senderType,
    required this.messageSentAt,
  });

  factory AdminReportItemDto.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic raw) {
      final value = raw?.toString();
      if (value == null || value.trim().isEmpty) return null;
      return DateTime.tryParse(value)?.toLocal();
    }

    return AdminReportItemDto(
      id: (json['id'] as num?)?.toInt(),
      storeId: (json['storeId'] as num?)?.toInt(),
      inquiryId: (json['inquiryId'] as num?)?.toInt(),
      messageId: (json['messageId'] as num?)?.toInt(),
      reporterType: ((json['reporterType'] ?? json['reportReporterType']) ?? '')
          .toString(),
      reporterId: (json['reporterId'] as num?)?.toInt(),
      reason: (json['reason'] ?? '').toString(),
      details: (json['details'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      createdAt: parseDate(json['createdAt']),
      resolvedAt: parseDate(json['resolvedAt']),
      messageText: (json['messageText'] ?? '').toString(),
      senderType: (json['senderType'] ?? '').toString(),
      messageSentAt: parseDate(json['messageSentAt']),
    );
  }
}