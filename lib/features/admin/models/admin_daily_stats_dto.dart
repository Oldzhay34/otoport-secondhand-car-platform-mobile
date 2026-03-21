class AdminDailyVisitStatsDto {
  final int total;
  final int guest;
  final int client;
  final int store;

  const AdminDailyVisitStatsDto({
    required this.total,
    required this.guest,
    required this.client,
    required this.store,
  });

  factory AdminDailyVisitStatsDto.fromJson(Map<String, dynamic> json) {
    return AdminDailyVisitStatsDto(
      total: (json['total'] ?? 0) as int? ?? 0,
      guest: (json['guest'] ?? 0) as int? ?? 0,
      client: (json['client'] ?? 0) as int? ?? 0,
      store: (json['store'] ?? 0) as int? ?? 0,
    );
  }
}