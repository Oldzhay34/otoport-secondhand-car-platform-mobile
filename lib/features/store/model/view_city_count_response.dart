class ViewCityCountResponse {
  final String city;
  final int count;

  ViewCityCountResponse({
    required this.city,
    required this.count,
  });

  factory ViewCityCountResponse.fromJson(Map<String, dynamic> json) {
    return ViewCityCountResponse(
      city: (json['city'] ?? '').toString(),
      count: _toInt(json['count']) ?? 0,
    );
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }
}