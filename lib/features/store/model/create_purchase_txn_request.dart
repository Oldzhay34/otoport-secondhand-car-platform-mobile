class CreatePurchaseTxnRequest {
  final int carId;
  final int? listingId;
  final String purchaseDate;
  final double purchasePrice;
  final bool purchaseVatIncluded;
  final String vatMode;

  CreatePurchaseTxnRequest({
    required this.carId,
    required this.listingId,
    required this.purchaseDate,
    required this.purchasePrice,
    required this.purchaseVatIncluded,
    required this.vatMode,
  });

  Map<String, dynamic> toJson() {
    return {
      'carId': carId,
      'listingId': listingId,
      'purchaseDate': purchaseDate,
      'purchasePrice': purchasePrice,
      'purchaseVatIncluded': purchaseVatIncluded,
      'vatMode': vatMode,
    };
  }
}