class MeResponse {
  final bool authenticated;
  final int? id;
  final String? email;
  final String? role;

  MeResponse({
    required this.authenticated,
    this.id,
    this.email,
    this.role,
  });

  factory MeResponse.fromJson(Map<String, dynamic> json) {
    return MeResponse(
      authenticated: json['authenticated'] ?? false,
      id: json['id'],
      email: json['email'],
      role: json['role'],
    );
  }
}