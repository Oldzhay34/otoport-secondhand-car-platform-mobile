class AddExpenseRequest {
  final String type;
  final String expenseDate;
  final double amount;
  final bool vatIncluded;
  final String? note;

  AddExpenseRequest({
    required this.type,
    required this.expenseDate,
    required this.amount,
    required this.vatIncluded,
    required this.note,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'expenseDate': expenseDate,
      'amount': amount,
      'vatIncluded': vatIncluded,
      'note': note,
    };
  }
}