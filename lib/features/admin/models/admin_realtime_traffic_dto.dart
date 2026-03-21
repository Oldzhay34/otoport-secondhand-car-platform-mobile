class AdminRealtimeTrafficDto {
  final int windowMinutes;
  final int total;
  final int guest;
  final int client;
  final int store;

  const AdminRealtimeTrafficDto({
    required this.windowMinutes,
    required this.total,
    required this.guest,
    required this.client,
    required this.store,
  });

  factory AdminRealtimeTrafficDto.fromJson(Map<String, dynamic> json) {
    return AdminRealtimeTrafficDto(
      windowMinutes: (json['windowMinutes'] as num?)?.toInt() ?? 0,
      total: (json['total'] as num?)?.toInt() ?? 0,
      guest: (json['guest'] as num?)?.toInt() ?? 0,
      client: (json['client'] as num?)?.toInt() ?? 0,
      store: (json['store'] as num?)?.toInt() ?? 0,
    );
  }
}