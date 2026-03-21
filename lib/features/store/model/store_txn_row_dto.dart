class StoreTxnRowDto {
  final int? id;
  final int? carId;
  final String status;

  final DateTime? purchaseDate;
  final double? purchasePrice;

  final DateTime? saleDate;
  final double? salePrice;

  final int? stockDays;
  final double? grossProfit;
  final double? totalCarryCost;
  final double? profitAfterCarry;

  StoreTxnRowDto({
    required this.id,
    required this.carId,
    required this.status,
    required this.purchaseDate,
    required this.purchasePrice,
    required this.saleDate,
    required this.salePrice,
    required this.stockDays,
    required this.grossProfit,
    required this.totalCarryCost,
    required this.profitAfterCarry,
  });

  factory StoreTxnRowDto.fromJson(Map<String, dynamic> json) {
    return StoreTxnRowDto(
      id: _toInt(json['id']),
      carId: _toInt(json['carId']),
      status: (json['status'] ?? '').toString(),
      purchaseDate: _toDate(json['purchaseDate']),
      purchasePrice: _toDouble(json['purchasePrice']),
      saleDate: _toDate(json['saleDate']),
      salePrice: _toDouble(json['salePrice']),
      stockDays: _toInt(json['stockDays']),
      grossProfit: _toDouble(json['grossProfit']),
      totalCarryCost: _toDouble(json['totalCarryCost']),
      profitAfterCarry: _toDouble(json['profitAfterCarry']),
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

  static DateTime? _toDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}