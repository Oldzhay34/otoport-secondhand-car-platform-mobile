import 'expert_item_model.dart';

class ExpertReportModel {
  final int id;
  final int? carId;
  final String? companyName;
  final String? reportDate;
  final String? reportNo;
  final String? result;
  final String? notes;
  final List<ExpertItemModel> items;

  ExpertReportModel({
    required this.id,
    required this.carId,
    required this.companyName,
    required this.reportDate,
    required this.reportNo,
    required this.result,
    required this.notes,
    required this.items,
  });

  factory ExpertReportModel.fromJson(Map<String, dynamic> json) {
    final rawItems = (json['items'] as List?) ?? const [];

    return ExpertReportModel(
      id: (json['id'] ?? 0) as int,
      carId: (json['carId'] as num?)?.toInt(),
      companyName: json['companyName']?.toString(),
      reportDate: json['reportDate']?.toString(),
      reportNo: json['reportNo']?.toString(),
      result: json['result']?.toString(),
      notes: json['notes']?.toString(),
      items: rawItems
          .map((e) => ExpertItemModel.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}