class ForgotPasswordRequest {
  final String email;
  final String hp;
  final int clientTs;

  ForgotPasswordRequest({
    required this.email,
    required this.hp,
    required this.clientTs,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'hp': hp,
      'clientTs': clientTs,
    };
  }
}