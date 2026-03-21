class PurchasePlanRequest {
  final String plan;

  PurchasePlanRequest({
    required this.plan,
  });

  Map<String, dynamic> toJson() {
    return {
      'plan': plan,
    };
  }
}