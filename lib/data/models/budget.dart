class Budget {
  final String id;
  final String category;
  final double amount;
  final DateTime month; // Represents the month and year of the budget

  Budget({
    required this.id,
    required this.category,
    required this.amount,
    required this.month,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'amount': amount,
      'month': month.toIso8601String(),
    };
  }

  // Create from JSON
  factory Budget.fromJson(Map<String, dynamic> json) {
    return Budget(
      id: json['id'],
      category: json['category'],
      amount: json['amount'].toDouble(),
      month: DateTime.parse(json['month']),
    );
  }

  Budget copyWith({
    String? id,
    String? category,
    double? amount,
    DateTime? month,
  }) {
    return Budget(
      id: id ?? this.id,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      month: month ?? this.month,
    );
  }
}
