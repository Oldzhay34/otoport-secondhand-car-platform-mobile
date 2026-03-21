class VehicleCatalogDto {
  final List<CatalogBrandDto> brands;

  VehicleCatalogDto({
    required this.brands,
  });

  factory VehicleCatalogDto.fromJson(Map<String, dynamic> json) {
    final rawBrands = (json['brands'] as List?) ?? const [];
    return VehicleCatalogDto(
      brands: rawBrands
          .map((e) => CatalogBrandDto.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}

class CatalogBrandDto {
  final String brand;
  final List<CatalogModelDto> models;

  CatalogBrandDto({
    required this.brand,
    required this.models,
  });

  factory CatalogBrandDto.fromJson(Map<String, dynamic> json) {
    final rawModels = (json['models'] as List?) ?? const [];
    return CatalogBrandDto(
      brand: (json['brand'] ?? '').toString(),
      models: rawModels
          .map((e) => CatalogModelDto.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}

class CatalogModelDto {
  final String model;
  final List<CatalogVariantDto> variants;
  final List<CatalogEngineDto> engines;
  final List<String> trims;

  CatalogModelDto({
    required this.model,
    required this.variants,
    required this.engines,
    required this.trims,
  });

  factory CatalogModelDto.fromJson(Map<String, dynamic> json) {
    final rawVariants = (json['variants'] as List?) ?? const [];
    final rawEngines = (json['engines'] as List?) ?? const [];
    final rawTrims = (json['trims'] as List?) ?? const [];

    return CatalogModelDto(
      model: (json['model'] ?? '').toString(),
      variants: rawVariants
          .map((e) => CatalogVariantDto.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      engines: rawEngines
          .map((e) => CatalogEngineDto.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      trims: rawTrims.map((e) => e.toString()).toList(),
    );
  }
}

class CatalogVariantDto {
  final String variant;
  final List<CatalogEngineDto> engines;
  final List<String> trims;
  final List<String> packages;

  CatalogVariantDto({
    required this.variant,
    required this.engines,
    required this.trims,
    required this.packages,
  });

  factory CatalogVariantDto.fromJson(Map<String, dynamic> json) {
    final rawEngines = (json['engines'] as List?) ?? const [];
    final rawTrims = (json['trims'] as List?) ?? const [];
    final rawPackages = (json['packages'] as List?) ?? const [];

    return CatalogVariantDto(
      variant: (json['variant'] ?? '').toString(),
      engines: rawEngines
          .map((e) => CatalogEngineDto.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      trims: rawTrims.map((e) => e.toString()).toList(),
      packages: rawPackages.map((e) => e.toString()).toList(),
    );
  }
}

class CatalogEngineDto {
  final String engine;
  final List<String> packages;

  CatalogEngineDto({
    required this.engine,
    required this.packages,
  });

  factory CatalogEngineDto.fromJson(Map<String, dynamic> json) {
    final rawPackages = (json['packages'] as List?) ?? const [];
    return CatalogEngineDto(
      engine: (json['engine'] ?? '').toString(),
      packages: rawPackages.map((e) => e.toString()).toList(),
    );
  }
}