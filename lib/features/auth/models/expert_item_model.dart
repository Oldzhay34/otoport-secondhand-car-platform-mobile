class ExpertItemModel {
  final String? part;
  final String? status;
  final String? note;

  ExpertItemModel({
    required this.part,
    required this.status,
    required this.note,
  });

  factory ExpertItemModel.fromJson(Map<String, dynamic> json) {
    return ExpertItemModel(
      part: json['part']?.toString(),
      status: json['status']?.toString(),
      note: json['note']?.toString(),
    );
  }
}