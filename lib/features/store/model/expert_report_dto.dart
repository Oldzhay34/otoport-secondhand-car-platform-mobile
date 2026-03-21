import 'expert_item_dto.dart';

class ExpertReportDto {
  final int? id;
  final int? carId;
  final String? companyName;
  final String? reportDate;
  final String? reportNo;
  final String? result;
  final String? notes;
  final List<ExpertItemDto> items;

  ExpertReportDto({
    required this.id,
    required this.carId,
    required this.companyName,
    required this.reportDate,
    required this.reportNo,
    required this.result,
    required this.notes,
    required this.items,
  });

  factory ExpertReportDto.fromJson(Map<String, dynamic> json) {
    final rawItems = (json['items'] as List?) ?? const [];

    return ExpertReportDto(
      id: _toInt(json['id']),
      carId: _toInt(json['carId']),
      companyName: json['companyName']?.toString(),
      reportDate: json['reportDate']?.toString(),
      reportNo: json['reportNo']?.toString(),
      result: json['result']?.toString(),
      notes: json['notes']?.toString(),
      items: rawItems
          .map((e) => ExpertItemDto.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'companyName': companyName,
      'reportDate': reportDate,
      'reportNo': reportNo,
      'result': result,
      'notes': notes,
      'items': items.map((e) => e.toJson()).toList(),
    };
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }
}