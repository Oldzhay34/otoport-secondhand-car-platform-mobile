import 'client_profile_model.dart';

class ClientProfileGetResponse {
  final bool authenticated;
  final ClientProfileModel? profile;

  ClientProfileGetResponse({
    required this.authenticated,
    required this.profile,
  });

  factory ClientProfileGetResponse.fromJson(Map<String, dynamic> json) {
    return ClientProfileGetResponse(
      authenticated: json['authenticated'] == true,
      profile: json['profile'] != null
          ? ClientProfileModel.fromJson(
        Map<String, dynamic>.from(json['profile']),
      )
          : null,
    );
  }
}