class LoginResponse {
  final bool ok;
  final String role;
  final int id;
  final String accessToken;
  final String refreshToken;

  LoginResponse({
    required this.ok,
    required this.role,
    required this.id,
    required this.accessToken,
    required this.refreshToken,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      ok: json['ok'] ?? false,
      role: json['role'] ?? '',
      id: json['id'] ?? 0,
      accessToken: json['accessToken'] ?? '',
      refreshToken: json['refreshToken'] ?? '',
    );
  }
}