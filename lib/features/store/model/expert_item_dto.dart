class ExpertItemDto {
  final String? part;
  final String? status;
  final String? note;

  ExpertItemDto({
    required this.part,
    required this.status,
    required this.note,
  });

  factory ExpertItemDto.fromJson(Map<String, dynamic> json) {
    return ExpertItemDto(
      part: json['part']?.toString(),
      status: json['status']?.toString(),
      note: json['note']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'part': part,
      'status': status,
      'note': note,
    };
  }
}