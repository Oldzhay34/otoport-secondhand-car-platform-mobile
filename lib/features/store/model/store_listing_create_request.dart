import 'package:otoport_mobile/features/store/model/expert_report_dto.dart';

class StoreListingCreateRequest {
  final String title;
  final String? description;
  final double price;
  final String currency;
  final bool negotiable;
  final String city;
  final String? district;
  final String brand;
  final String model;
  final String? variant;
  final String? engine;
  final String? carPackage;
  final String transmission;
  final String fuelType;
  final String bodyType;
  final int year;
  final int kilometer;
  final String? color;
  final int? engineVolumeCc;
  final int? enginePowerHp;
  final ExpertReportDto? expertReport;

  StoreListingCreateRequest({
    required this.title,
    required this.description,
    required this.price,
    required this.currency,
    required this.negotiable,
    required this.city,
    required this.district,
    required this.brand,
    required this.model,
    required this.variant,
    required this.engine,
    required this.carPackage,
    required this.transmission,
    required this.fuelType,
    required this.bodyType,
    required this.year,
    required this.kilometer,
    required this.color,
    required this.engineVolumeCc,
    required this.enginePowerHp,
    required this.expertReport,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'price': price,
      'currency': currency,
      'negotiable': negotiable,
      'city': city,
      'district': district,
      'brand': brand,
      'model': model,
      'variant': variant,
      'engine': engine,
      'carPackage': carPackage,
      'transmission': transmission,
      'fuelType': fuelType,
      'bodyType': bodyType,
      'year': year,
      'kilometer': kilometer,
      'color': color,
      'engineVolumeCc': engineVolumeCc,
      'enginePowerHp': enginePowerHp,
      'expertReport': expertReport?.toJson(),
    };
  }
}