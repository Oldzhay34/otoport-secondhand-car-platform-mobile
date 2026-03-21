class AdminHourCountDto {
  final int hour;
  final int count;

  const AdminHourCountDto({
    required this.hour,
    required this.count,
  });

  factory AdminHourCountDto.fromJson(Map<String, dynamic> json) {
    return AdminHourCountDto(
      hour: (json['hour'] ?? 0) as int? ?? 0,
      count: (json['count'] ?? 0) as int? ?? 0,
    );
  }
}

class AdminHourlyTrafficDto {
  final List<AdminHourCountDto> hours;

  const AdminHourlyTrafficDto({
    required this.hours,
  });

  factory AdminHourlyTrafficDto.fromJson(Map<String, dynamic> json) {
    final rawList = (json['hours'] as List?) ?? const [];

    return AdminHourlyTrafficDto(
      hours: rawList
          .map(
            (e) => AdminHourCountDto.fromJson(
          Map<String, dynamic>.from(e as Map),
        ),
      )
          .toList(),
    );
  }
}