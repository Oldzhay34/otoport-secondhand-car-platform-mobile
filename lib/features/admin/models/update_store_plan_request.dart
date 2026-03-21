class UpdateStorePlanRequest {
  final String plan;

  const UpdateStorePlanRequest({
    required this.plan,
  });

  Map<String, dynamic> toJson() {
    return {
      'plan': plan,
    };
  }
}