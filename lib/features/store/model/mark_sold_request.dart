class MarkSoldRequest {
  final String saleDate;
  final double salePrice;
  final bool saleVatIncluded;

  MarkSoldRequest({
    required this.saleDate,
    required this.salePrice,
    required this.saleVatIncluded,
  });

  Map<String, dynamic> toJson() {
    return {
      'saleDate': saleDate,
      'salePrice': salePrice,
      'saleVatIncluded': saleVatIncluded,
    };
  }
}