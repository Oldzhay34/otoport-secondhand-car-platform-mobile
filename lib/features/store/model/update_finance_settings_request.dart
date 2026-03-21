class UpdateFinanceSettingsRequest {
  final double annualInflationRate;
  final double annualOpportunityRate;

  UpdateFinanceSettingsRequest({
    required this.annualInflationRate,
    required this.annualOpportunityRate,
  });

  Map<String, dynamic> toJson() {
    return {
      'annualInflationRate': annualInflationRate,
      'annualOpportunityRate': annualOpportunityRate,
    };
  }
}