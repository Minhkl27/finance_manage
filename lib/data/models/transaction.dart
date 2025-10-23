class Transaction {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final bool isIncome; // true: thu nhập, false: chi tiêu
  final String category; // Danh mục giao dịch

  // Getter for backward compatibility
  String get description => title;

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.isIncome,
    this.category = '',
    required String notes, // Default to empty string
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'isIncome': isIncome,
      'category': category,
    };
  }

  // Create from JSON
  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      title: json['title'],
      amount: json['amount'].toDouble(),
      date: DateTime.parse(json['date']),
      isIncome: json['isIncome'],
      category: json['category'] ?? '',
      notes: '', // Handle null values
    );
  }

  // Copy with method for updates
  Transaction copyWith({
    String? id,
    String? title,
    double? amount,
    DateTime? date,
    bool? isIncome,
    String? category,
  }) {
    return Transaction(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      isIncome: isIncome ?? this.isIncome,
      category: category ?? this.category,
      notes: '',
    );
  }
}
