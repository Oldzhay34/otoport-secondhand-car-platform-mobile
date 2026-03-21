import 'package:otoport_mobile/features/store/model/subscription_model.dart';


class SubscriptionResponse {
  final int? storeId;
  final SubscriptionPlanType plan;
  final bool active;
  final DateTime? startsAt;
  final DateTime? endsAt;
  final int listingLimit;
  final int featuredLimit;

  SubscriptionResponse({
    required this.storeId,
    required this.plan,
    required this.active,
    required this.startsAt,
    required this.endsAt,
    required this.listingLimit,
    required this.featuredLimit,
  });

  factory SubscriptionResponse.fromJson(Map<String, dynamic> json) {
    return SubscriptionResponse(
      storeId: json['storeId'] is int
          ? json['storeId'] as int
          : int.tryParse('${json['storeId'] ?? ''}'),
      plan: SubscriptionPlanType.fromString(json['plan']?.toString()),
      active: json['active'] == true,
      startsAt: _parseDate(json['startsAt']),
      endsAt: _parseDate(json['endsAt']),
      listingLimit: _parseInt(json['listingLimit']),
      featuredLimit: _parseInt(json['featuredLimit']),
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse('${value ?? 0}') ?? 0;
  }
}