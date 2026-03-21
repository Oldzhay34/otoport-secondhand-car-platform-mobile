class UnreadCountResponse {
  final int count;

  UnreadCountResponse({
    required this.count,
  });

  factory UnreadCountResponse.fromJson(Map<String, dynamic> json) {
    return UnreadCountResponse(
      count: _toInt(json['count']) ?? 0,
    );
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }
}