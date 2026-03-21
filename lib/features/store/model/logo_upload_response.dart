class LogoUploadResponse {
  final String logoUrl;

  LogoUploadResponse({
    required this.logoUrl,
  });

  factory LogoUploadResponse.fromJson(Map<String, dynamic> json) {
    return LogoUploadResponse(
      logoUrl: (json['logoUrl'] ?? '').toString(),
    );
  }
}