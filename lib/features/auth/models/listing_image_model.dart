class ListingImageModel {
  final int id;
  final String? imagePath;
  final int? sortOrder;
  final bool cover;

  ListingImageModel({
    required this.id,
    required this.imagePath,
    required this.sortOrder,
    required this.cover,
  });

  factory ListingImageModel.fromJson(Map<String, dynamic> json) {
    return ListingImageModel(
      id: (json['id'] ?? 0) as int,
      imagePath: json['imagePath']?.toString(),
      sortOrder: json['sortOrder'] as int?,
      cover: json['cover'] == true,
    );
  }
}