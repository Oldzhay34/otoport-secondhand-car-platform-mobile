class ClientProfileUpdateRequest {
  final String firstName;
  final String lastName;
  final String? phone;
  final String? birthDate;
  final bool marketingConsent;

  ClientProfileUpdateRequest({
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.birthDate,
    required this.marketingConsent,
  });

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'birthDate': birthDate,
      'marketingConsent': marketingConsent,
    };
  }
}