import 'expert_report_dto.dart';

class StoreCarUpdateRequest {
  final String? title;
  final String? description;
  final double? price;
  final String? currency;
  final bool? negotiable;
  final String? city;
  final String? district;
  final int? year;
  final int? kilometer;
  final String? color;
  final int? engineVolumeCc;
  final int? enginePowerHp;
  final ExpertReportDto? expertReport;

  StoreCarUpdateRequest({
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

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'price': price,
      'currency': currency,
      'negotiable': negotiable,
      'city': city,
      'district': district,
      'year': year,
      'kilometer': kilometer,
      'color': color,
      'engineVolumeCc': engineVolumeCc,
      'enginePowerHp': enginePowerHp,
      'expertReport': expertReport?.toJson(),
    };
  }
}