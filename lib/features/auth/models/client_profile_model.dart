class ClientProfileModel {
  final int id;
  final String? email;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? birthDate;
  final bool marketingConsent;

  ClientProfileModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.birthDate,
    required this.marketingConsent,
  });

  factory ClientProfileModel.fromJson(Map<String, dynamic> json) {
    return ClientProfileModel(
      id: _toInt(json['id']) ?? 0,
      email: json['email']?.toString(),
      firstName: json['firstName']?.toString(),
      lastName: json['lastName']?.toString(),
      phone: json['phone']?.toString(),
      birthDate: json['birthDate']?.toString(),
      marketingConsent: json['marketingConsent'] == true,
    );
  }

  factory ClientProfileModel.empty() {
    return ClientProfileModel(
      id: 0,
      email: null,
      firstName: null,
      lastName: null,
      phone: null,
      birthDate: null,
      marketingConsent: false,
    );
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }
}