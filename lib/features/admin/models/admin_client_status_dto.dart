class AdminClientStatusDto {
  final int? id;
  final String firstName;
  final String lastName;
  final String email;
  final String status;

  const AdminClientStatusDto({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.status,
  });

  String get fullName {
    final text = '${firstName.trim()} ${lastName.trim()}'.trim();
    return text.isEmpty ? 'İsimsiz Kullanıcı' : text;
  }

  factory AdminClientStatusDto.fromJson(Map<String, dynamic> json) {
    return AdminClientStatusDto(
      id: (json['id'] as num?)?.toInt(),
      firstName: (json['firstName'] ?? '').toString(),
      lastName: (json['lastName'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
    );
  }
}