import 'package:flutter/foundation.dart';

@immutable
class RecurringTransaction {
  final String id;
  final String title;
  final double amount;
  final String category;
  final bool isIncome;
  final int dayOfMonth; // Ngày trong tháng để tạo giao dịch (1-31)
  final DateTime? lastGeneratedDate; // Ngày cuối cùng giao dịch được tạo

  const RecurringTransaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.isIncome,
    required this.dayOfMonth,
    this.lastGeneratedDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'category': category,
      'isIncome': isIncome,
      'dayOfMonth': dayOfMonth,
      'lastGeneratedDate': lastGeneratedDate?.toIso8601String(),
    };
  }

  factory RecurringTransaction.fromJson(Map<String, dynamic> json) {
    return RecurringTransaction(
      id: json['id'],
      title: json['title'],
      amount: json['amount'],
      category: json['category'],
      isIncome: json['isIncome'],
      dayOfMonth: json['dayOfMonth'],
      lastGeneratedDate: json['lastGeneratedDate'] != null
          ? DateTime.parse(json['lastGeneratedDate'])
          : null,
    );
  }

  RecurringTransaction copyWith({
    String? id,
    String? title,
    double? amount,
    String? category,
    bool? isIncome,
    int? dayOfMonth,
    DateTime? lastGeneratedDate,
  }) {
    return RecurringTransaction(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      isIncome: isIncome ?? this.isIncome,
      dayOfMonth: dayOfMonth ?? this.dayOfMonth,
      lastGeneratedDate: lastGeneratedDate ?? this.lastGeneratedDate,
    );
  }
}
