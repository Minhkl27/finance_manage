import 'package:flutter/foundation.dart';

@immutable
class TransactionTemplate {
  final String id;
  final String title;
  final double amount;
  final String category;
  final bool isIncome;

  const TransactionTemplate({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.isIncome,
  });

  // fromJson
  factory TransactionTemplate.fromJson(Map<String, dynamic> json) {
    return TransactionTemplate(
      id: json['id'] as String,
      title: json['title'] as String,
      amount: (json['amount'] as num).toDouble(),
      category: json['category'] as String,
      isIncome: json['isIncome'] as bool,
    );
  }

  // toJson
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'category': category,
      'isIncome': isIncome,
    };
  }

  @override
  String toString() {
    return 'TransactionTemplate{id: $id, title: $title, amount: $amount, category: $category, isIncome: $isIncome}';
  }
}
