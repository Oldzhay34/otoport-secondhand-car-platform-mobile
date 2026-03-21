class ListingImageDto {
  final int? id;
  final String imagePath;
  final int? sortOrder;
  final bool cover;

  ListingImageDto({
    required this.id,
    required this.imagePath,
    required this.sortOrder,
    required this.cover,
  });

  factory ListingImageDto.fromJson(Map<String, dynamic> json) {
    return ListingImageDto(
      id: _toInt(json['id']),
      imagePath: (json['imagePath'] ?? '').toString(),
      sortOrder: _toInt(json['sortOrder']),
      cover: json['cover'] == true,
    );
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }
}