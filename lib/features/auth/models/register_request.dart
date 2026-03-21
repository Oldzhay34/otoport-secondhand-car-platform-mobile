class RegisterRequest {
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String? phone;
  final String? hp;
  final bool? marketingConsent;

  final bool termsAccepted;
  final bool privacyPolicyAccepted;
  final bool explicitConsentAccepted;

  RegisterRequest({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    this.phone,
    this.hp,
    this.marketingConsent,
    required this.termsAccepted,
    required this.privacyPolicyAccepted,
    required this.explicitConsentAccepted,
  });

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'password': password,
      'phone': phone,
      'hp': hp,
      'marketingConsent': marketingConsent,
      'termsAccepted': termsAccepted,
      'privacyPolicyAccepted': privacyPolicyAccepted,
      'explicitConsentAccepted': explicitConsentAccepted,
    };
  }
}