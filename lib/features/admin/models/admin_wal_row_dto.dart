class AdminWalRowDto {
  final int? id;
  final DateTime? createdAt;
  final String actorType;
  final int? actorId;
  final String method;
  final String path;
  final String queryString;
  final int? status;
  final String ipAddress;
  final String userAgent;
  final String requestBody;
  final String responseBody;
  final String prevHash;
  final String hash;

  const AdminWalRowDto({
    required this.id,
    required this.createdAt,
    required this.actorType,
    required this.actorId,
    required this.method,
    required this.path,
    required this.queryString,
    required this.status,
    required this.ipAddress,
    required this.userAgent,
    required this.requestBody,
    required this.responseBody,
    required this.prevHash,
    required this.hash,
  });

  factory AdminWalRowDto.fromJson(Map<String, dynamic> json) {
    DateTime? parsedCreatedAt;
    final createdAtRaw = json['createdAt']?.toString();
    if (createdAtRaw != null && createdAtRaw.trim().isNotEmpty) {
      parsedCreatedAt = DateTime.tryParse(createdAtRaw)?.toLocal();
    }

    return AdminWalRowDto(
      id: (json['id'] as num?)?.toInt(),
      createdAt: parsedCreatedAt,
      actorType: (json['actorType'] ?? '').toString(),
      actorId: (json['actorId'] as num?)?.toInt(),
      method: (json['method'] ?? '').toString(),
      path: (json['path'] ?? '').toString(),
      queryString: (json['queryString'] ?? '').toString(),
      status: (json['status'] as num?)?.toInt(),
      ipAddress: (json['ipAddress'] ?? '').toString(),
      userAgent: (json['userAgent'] ?? '').toString(),
      requestBody: (json['requestBody'] ?? '').toString(),
      responseBody: (json['responseBody'] ?? '').toString(),
      prevHash: (json['prevHash'] ?? '').toString(),
      hash: (json['hash'] ?? '').toString(),
    );
  }
}