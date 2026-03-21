class VerifyResetCodeRequest {
  final String email;
  final String code;
  final int clientTs;

  VerifyResetCodeRequest({
    required this.email,
    required this.code,
    required this.clientTs,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'code': code,
      'clientTs': clientTs,
    };
  }
}