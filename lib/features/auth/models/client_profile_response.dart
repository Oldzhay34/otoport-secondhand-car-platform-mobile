import 'client_profile_model.dart';

class ClientProfileResponse {
  final ClientProfileModel? profile;
  final bool success;
  final String? message;

  ClientProfileResponse({
    required this.profile,
    required this.success,
    required this.message,
  });

  factory ClientProfileResponse.fromJson(Map<String, dynamic> json) {
    final rawProfile = json['profile'];

    ClientProfileModel? parsedProfile;
    if (rawProfile is Map) {
      parsedProfile = ClientProfileModel.fromJson(
        Map<String, dynamic>.from(rawProfile),
      );
    } else if (_looksLikeProfileMap(json)) {
      parsedProfile = ClientProfileModel.fromJson(json);
    } else {
      parsedProfile = null;
    }

    return ClientProfileResponse(
      profile: parsedProfile,
      success: _toBool(json['success']) ?? true,
      message: json['message']?.toString(),
    );
  }

  factory ClientProfileResponse.success({
    ClientProfileModel? profile,
    String? message,
  }) {
    return ClientProfileResponse(
      profile: profile,
      success: true,
      message: message ?? 'Profil güncellendi.',
    );
  }

  static bool _looksLikeProfileMap(Map<String, dynamic> json) {
    return json.containsKey('id') ||
        json.containsKey('email') ||
        json.containsKey('firstName') ||
        json.containsKey('lastName') ||
        json.containsKey('phone') ||
        json.containsKey('birthDate') ||
        json.containsKey('marketingConsent');
  }

  static bool? _toBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;

    final s = value.toString().trim().toLowerCase();
    if (s == 'true') return true;
    if (s == 'false') return false;
    return null;
  }
}