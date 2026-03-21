class BuildingOption {
  final String id;
  final String name;

  BuildingOption({
    required this.id,
    required this.name,
  });

  factory BuildingOption.fromJson(Map<String, dynamic> json) {
    final id =
    (json['id'] ?? json['buildingId'] ?? json['value'] ?? '').toString();
    final name = (json['name'] ??
        json['buildingName'] ??
        json['label'] ??
        json['displayName'] ??
        id)
        .toString();

    return BuildingOption(
      id: id,
      name: name,
    );
  }
}

class HomeStoreFiltersResponse {
  final List<String> cities;
  final List<String> districts;
  final List<BuildingOption> buildings;
  final List<String> floors;

  HomeStoreFiltersResponse({
    required this.cities,
    required this.districts,
    required this.buildings,
    required this.floors,
  });

  factory HomeStoreFiltersResponse.fromJson(Map<String, dynamic> json) {
    return HomeStoreFiltersResponse(
      cities: (json['cities'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      districts: (json['districts'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      buildings: (json['buildings'] as List<dynamic>? ?? [])
          .map((e) => BuildingOption.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      floors: (json['floors'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
    );
  }
}