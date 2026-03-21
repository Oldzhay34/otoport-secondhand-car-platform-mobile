import 'most_viewed_listing_model.dart';

class MostViewedResponseModel {
  final int count;
  final List<MostViewedListingModel> items;

  const MostViewedResponseModel({
    required this.count,
    required this.items,
  });

  factory MostViewedResponseModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];

    return MostViewedResponseModel(
      count: _toInt(json['count']) ?? 0,
      items: rawItems is List
          ? rawItems
          .map(
            (e) => MostViewedListingModel.fromJson(
          Map<String, dynamic>.from(e),
        ),
      )
          .toList()
          : const [],
    );
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }
}