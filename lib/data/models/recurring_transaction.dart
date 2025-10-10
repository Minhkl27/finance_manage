import 'package:flutter/foundation.dart';
import 'recurrence_frequency.dart';

@immutable
class RecurringTransaction {
  final String id;
  final String title;
  final double amount;
  final String category;
  final bool isIncome;
  final RecurrenceFrequency frequency;
  final DateTime startDate;
  final DateTime? endDate;
  final DateTime?
  lastGeneratedDate; // Tracks the last time a transaction was made

  const RecurringTransaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.isIncome,
    required this.frequency,
    required this.startDate,
    this.endDate,
    this.lastGeneratedDate,
  });

  factory RecurringTransaction.fromJson(Map<String, dynamic> json) {
    return RecurringTransaction(
      id: json['id'] as String,
      title: json['title'] as String,
      amount: (json['amount'] as num).toDouble(),
      category: json['category'] as String,
      isIncome: json['isIncome'] as bool,
      frequency: recurrenceFrequencyFromString(json['frequency']),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'] as String)
          : null,
      lastGeneratedDate: json['lastGeneratedDate'] != null
          ? DateTime.parse(json['lastGeneratedDate'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'category': category,
      'isIncome': isIncome,
      'frequency': frequency.toString(),
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'lastGeneratedDate': lastGeneratedDate?.toIso8601String(),
    };
  }
}
