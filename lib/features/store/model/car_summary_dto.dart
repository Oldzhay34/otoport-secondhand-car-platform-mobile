class CarSummaryDto {
  final int? id;
  final String brandName;
  final String modelName;
  final String trimName;
  final int? year;
  final int? kilometer;
  final String transmission;
  final String fuelType;
  final String bodyType;
  final String drivetrain;
  final int? engineVolumeCc;
  final int? enginePowerHp;
  final String color;

  CarSummaryDto({
    required this.id,
    required this.brandName,
    required this.modelName,
    required this.trimName,
    required this.year,
    required this.kilometer,
    required this.transmission,
    required this.fuelType,
    required this.bodyType,
    required this.drivetrain,
    required this.engineVolumeCc,
    required this.enginePowerHp,
    required this.color,
  });

  factory CarSummaryDto.fromJson(Map<String, dynamic> json) {
    return CarSummaryDto(
      id: _toInt(json['id']),
      brandName: (json['brandName'] ?? '').toString(),
      modelName: (json['modelName'] ?? '').toString(),
      trimName: (json['trimName'] ?? '').toString(),
      year: _toInt(json['year']),
      kilometer: _toInt(json['kilometer']),
      transmission: (json['transmission'] ?? '').toString(),
      fuelType: (json['fuelType'] ?? '').toString(),
      bodyType: (json['bodyType'] ?? '').toString(),
      drivetrain: (json['drivetrain'] ?? '').toString(),
      engineVolumeCc: _toInt(json['engineVolumeCc']),
      enginePowerHp: _toInt(json['enginePowerHp']),
      color: (json['color'] ?? '').toString(),
    );
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }
}