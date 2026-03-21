import 'package:otoport_mobile/features/store/model/subscription_model.dart';
import 'package:otoport_mobile/features/store/model/subscription_response.dart';

class SubscriptionCheckoutInfoResponse {
  final SubscriptionResponse? subscription;
  final String storeName;
  final String city;
  final String district;
  final String addressLine;
  final bool hasActivePaidPlan;
  final SubscriptionPlanType? activePlan;
  final DateTime? activeEndsAt;

  SubscriptionCheckoutInfoResponse({
    required this.subscription,
    required this.storeName,
    required this.city,
    required this.district,
    required this.addressLine,
    required this.hasActivePaidPlan,
    required this.activePlan,
    required this.activeEndsAt,
  });

  factory SubscriptionCheckoutInfoResponse.fromJson(
      Map<String, dynamic> json,
      ) {
    return SubscriptionCheckoutInfoResponse(
      subscription: json['subscription'] is Map<String, dynamic>
          ? SubscriptionResponse.fromJson(
        Map<String, dynamic>.from(json['subscription']),
      )
          : null,
      storeName: (json['storeName'] ?? '').toString(),
      city: (json['city'] ?? '').toString(),
      district: (json['district'] ?? '').toString(),
      addressLine: (json['addressLine'] ?? '').toString(),
      hasActivePaidPlan: json['hasActivePaidPlan'] == true,
      activePlan: json['activePlan'] == null
          ? null
          : SubscriptionPlanType.fromString(json['activePlan']?.toString()),
      activeEndsAt: _parseDate(json['activeEndsAt']),
    );
  }

  String get composedAddress {
    final lines = <String>[
      if (storeName.trim().isNotEmpty) storeName.trim(),
      [
        city.trim(),
        district.trim().isNotEmpty ? district.trim() : '',
      ].where((e) => e.isNotEmpty).join(' / '),
      if (addressLine.trim().isNotEmpty) addressLine.trim(),
    ].where((e) => e.trim().isNotEmpty).toList();

    return lines.join('\n');
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}