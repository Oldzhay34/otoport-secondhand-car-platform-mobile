class SimpleOkResponse {
  final bool ok;

  SimpleOkResponse({
    required this.ok,
  });

  factory SimpleOkResponse.fromJson(Map<String, dynamic> json) {
    return SimpleOkResponse(
      ok: json['ok'] == true,
    );
  }
}