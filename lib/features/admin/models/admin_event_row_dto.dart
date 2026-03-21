class AdminEventRowDto {
  final DateTime? createdAt;
  final String type;
  final String severity;
  final String source;
  final String title;
  final String entityType;
  final int? entityId;
  final String correlationId;
  final String details;
  final String ipAddress;
  final String userAgent;

  const AdminEventRowDto({
    required this.createdAt,
    required this.type,
    required this.severity,
    required this.source,
    required this.title,
    required this.entityType,
    required this.entityId,
    required this.correlationId,
    required this.details,
    required this.ipAddress,
    required this.userAgent,
  });

  factory AdminEventRowDto.fromJson(Map<String, dynamic> json) {
    DateTime? parsedCreatedAt;
    final createdAtRaw = json['createdAt']?.toString();
    if (createdAtRaw != null && createdAtRaw.trim().isNotEmpty) {
      parsedCreatedAt = DateTime.tryParse(createdAtRaw)?.toLocal();
    }

    return AdminEventRowDto(
      createdAt: parsedCreatedAt,
      type: (json['type'] ?? '').toString(),
      severity: (json['severity'] ?? '').toString(),
      source: (json['source'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      entityType: (json['entityType'] ?? '').toString(),
      entityId: (json['entityId'] as num?)?.toInt(),
      correlationId: (json['correlationId'] ?? '').toString(),
      details: (json['details'] ?? '').toString(),
      ipAddress: (json['ipAddress'] ?? '').toString(),
      userAgent: (json['userAgent'] ?? '').toString(),
    );
  }
}