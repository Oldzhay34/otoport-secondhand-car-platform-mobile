class StoreListingCardModel {
  final int id;
  final String? title;
  final num? price;
  final int? year;
  final String? brand;
  final String? model;
  final String? engine;
  final String? pack;
  final String? imageUrl;

  StoreListingCardModel({
    required this.id,
    required this.title,
    required this.price,
    required this.year,
    required this.brand,
    required this.model,
    required this.engine,
    required this.pack,
    required this.imageUrl,
  });

  factory StoreListingCardModel.fromJson(Map<String, dynamic> json) {
    return StoreListingCardModel(
      id: (json['id'] ?? 0) as int,
      title: json['title']?.toString(),
      price: json['price'] as num?,
      year: json['year'] as int?,
      brand: json['brand']?.toString(),
      model: json['model']?.toString(),
      engine: json['engine']?.toString(),
      pack: json['pack']?.toString(),
      imageUrl: json['imageUrl']?.toString(),
    );
  }
}