class AdminAuditRowDto {
  final DateTime? createdAt;
  final String actorType;
  final int? actorId;
  final String action;
  final String entityType;
  final int? entityId;
  final String details;
  final String ipAddress;
  final String userAgent;

  const AdminAuditRowDto({
    required this.createdAt,
    required this.actorType,
    required this.actorId,
    required this.action,
    required this.entityType,
    required this.entityId,
    required this.details,
    required this.ipAddress,
    required this.userAgent,
  });

  factory AdminAuditRowDto.fromJson(Map<String, dynamic> json) {
    DateTime? parsedCreatedAt;
    final createdAtRaw = json['createdAt']?.toString();
    if (createdAtRaw != null && createdAtRaw.trim().isNotEmpty) {
      parsedCreatedAt = DateTime.tryParse(createdAtRaw)?.toLocal();
    }

    return AdminAuditRowDto(
      createdAt: parsedCreatedAt,
      actorType: (json['actorType'] ?? '').toString(),
      actorId: (json['actorId'] as num?)?.toInt(),
      action: (json['action'] ?? '').toString(),
      entityType: (json['entityType'] ?? '').toString(),
      entityId: (json['entityId'] as num?)?.toInt(),
      details: (json['details'] ?? '').toString(),
      ipAddress: (json['ipAddress'] ?? '').toString(),
      userAgent: (json['userAgent'] ?? '').toString(),
    );
  }
}