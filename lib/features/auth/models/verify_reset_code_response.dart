class VerifyResetCodeResponse {
  final String resetToken;

  VerifyResetCodeResponse({
    required this.resetToken,
  });

  factory VerifyResetCodeResponse.fromJson(Map<String, dynamic> json) {
    return VerifyResetCodeResponse(
      resetToken: (json['resetToken'] ?? '').toString(),
    );
  }
}