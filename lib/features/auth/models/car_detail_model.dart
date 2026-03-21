class CarDetailModel {
  final int id;
  final String? brandName;
  final String? modelName;
  final String? trimName;
  final int? year;
  final int? kilometer;
  final String? transmission;
  final String? fuelType;
  final String? bodyType;
  final String? drivetrain;
  final int? engineVolumeCc;
  final int? enginePowerHp;
  final String? color;

  CarDetailModel({
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

  factory CarDetailModel.fromJson(Map<String, dynamic> json) {
    return CarDetailModel(
      id: (json['id'] ?? 0) as int,
      brandName: json['brandName']?.toString(),
      modelName: json['modelName']?.toString(),
      trimName: json['trimName']?.toString(),
      year: json['year'] as int?,
      kilometer: json['kilometer'] as int?,
      transmission: json['transmission']?.toString(),
      fuelType: json['fuelType']?.toString(),
      bodyType: json['bodyType']?.toString(),
      drivetrain: json['drivetrain']?.toString(),
      engineVolumeCc: json['engineVolumeCc'] as int?,
      enginePowerHp: json['enginePowerHp'] as int?,
      color: json['color']?.toString(),
    );
  }
}