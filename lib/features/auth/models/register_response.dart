class RegisterResponse {
  final bool verificationRequired;
  final bool termsAccepted;
  final bool privacyPolicyAccepted;
  final bool explicitConsentAccepted;
  final String? email;

  RegisterResponse({
    required this.verificationRequired,
    required this.termsAccepted,
    required this.privacyPolicyAccepted,
    required this.explicitConsentAccepted,
    this.email,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      verificationRequired: json['verificationRequired'] == true,
      termsAccepted: json['termsAccepted'] == true,
      privacyPolicyAccepted: json['privacyPolicyAccepted'] == true,
      explicitConsentAccepted: json['explicitConsentAccepted'] == true,
      email: json['email']?.toString(),
    );
  }
}