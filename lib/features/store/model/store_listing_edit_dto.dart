import 'expert_report_dto.dart';

class StoreListingEditDto {
  final int? id;
  final int? carId;
  final String title;
  final String description;
  final double? price;
  final String currency;
  final bool negotiable;
  final String city;
  final String district;
  final int? year;
  final int? kilometer;
  final String color;
  final int? engineVolumeCc;
  final int? enginePowerHp;
  final ExpertReportDto? expertReport;

  StoreListingEditDto({
    required this.id,
    required this.carId,
    required this.title,
    required this.description,
    required this.price,
    required this.currency,
    required this.negotiable,
    required this.city,
    required this.district,
    required this.year,
    required this.kilometer,
    required this.color,
    required this.engineVolumeCc,
    required this.enginePowerHp,
    required this.expertReport,
  });

  factory StoreListingEditDto.fromJson(Map<String, dynamic> json) {
    return StoreListingEditDto(
      id: _toInt(json['id']),
      carId: _toInt(json['carId']),
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      price: _toDouble(json['price']),
      currency: (json['currency'] ?? 'TRY').toString(),
      negotiable: json['negotiable'] == true,
      city: (json['city'] ?? '').toString(),
      district: (json['district'] ?? '').toString(),
      year: _toInt(json['year']),
      kilometer: _toInt(json['kilometer']),
      color: (json['color'] ?? '').toString(),
      engineVolumeCc: _toInt(json['engineVolumeCc']),
      enginePowerHp: _toInt(json['enginePowerHp']),
      expertReport: json['expertReport'] is Map<String, dynamic>
          ? ExpertReportDto.fromJson(
        Map<String, dynamic>.from(json['expertReport']),
      )
          : null,
    );
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString());
  }
}