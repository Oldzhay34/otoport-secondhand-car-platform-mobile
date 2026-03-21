class PnlDto {
  final int? txnId;

  final double? purchaseGross;
  final double? purchaseNet;

  final double? saleGross;
  final double? saleNet;

  final double? vatOut;
  final double? vatIn;

  final double? expensesGross;
  final double? expensesNet;

  final double? grossProfit;

  final int? stockDays;
  final double? inflationCost;
  final double? opportunityCost;
  final double? totalCarryCost;

  final double? profitAfterCarry;

  final String vatMode;
  final double? vatRateApplied;

  PnlDto({
    required this.txnId,
    required this.purchaseGross,
    required this.purchaseNet,
    required this.saleGross,
    required this.saleNet,
    required this.vatOut,
    required this.vatIn,
    required this.expensesGross,
    required this.expensesNet,
    required this.grossProfit,
    required this.stockDays,
    required this.inflationCost,
    required this.opportunityCost,
    required this.totalCarryCost,
    required this.profitAfterCarry,
    required this.vatMode,
    required this.vatRateApplied,
  });

  factory PnlDto.fromJson(Map<String, dynamic> json) {
    return PnlDto(
      txnId: _toInt(json['txnId']),
      purchaseGross: _toDouble(json['purchaseGross']),
      purchaseNet: _toDouble(json['purchaseNet']),
      saleGross: _toDouble(json['saleGross']),
      saleNet: _toDouble(json['saleNet']),
      vatOut: _toDouble(json['vatOut']),
      vatIn: _toDouble(json['vatIn']),
      expensesGross: _toDouble(json['expensesGross']),
      expensesNet: _toDouble(json['expensesNet']),
      grossProfit: _toDouble(json['grossProfit']),
      stockDays: _toInt(json['stockDays']),
      inflationCost: _toDouble(json['inflationCost']),
      opportunityCost: _toDouble(json['opportunityCost']),
      totalCarryCost: _toDouble(json['totalCarryCost']),
      profitAfterCarry: _toDouble(json['profitAfterCarry']),
      vatMode: (json['vatMode'] ?? '').toString(),
      vatRateApplied: _toDouble(json['vatRateApplied']),
    );
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString());
  }
}