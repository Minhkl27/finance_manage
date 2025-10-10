import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction.dart' as t;
import 'transaction_provider.dart';
import '../models/recurring_transaction.dart';
import '../models/recurrence_frequency.dart';

class RecurringTransactionProvider with ChangeNotifier {
  static const _recurringKey = 'recurring_transactions';
  List<RecurringTransaction> _recurring = [];

  List<RecurringTransaction> get recurringTransactions => [..._recurring];

  Future<void> loadRecurringTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final dataString = prefs.getString(_recurringKey);
    if (dataString != null) {
      final List<dynamic> decoded = json.decode(dataString);
      _recurring = decoded
          .map((item) => RecurringTransaction.fromJson(item))
          .toList();
      notifyListeners();
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final dataString = json.encode(_recurring.map((r) => r.toJson()).toList());
    await prefs.setString(_recurringKey, dataString);
  }

  Future<void> addRecurring(RecurringTransaction recurring) async {
    _recurring.add(recurring);
    await _save();
    notifyListeners();
  }

  Future<void> updateRecurring(
    String id,
    RecurringTransaction newRecurring,
  ) async {
    final index = _recurring.indexWhere((r) => r.id == id);
    if (index != -1) {
      _recurring[index] = newRecurring;
      await _save();
      notifyListeners();
    }
  }

  Future<void> deleteRecurring(String id) async {
    _recurring.removeWhere((r) => r.id == id);
    await _save();
    notifyListeners();
  }

  Future<void> clearAllData() async {
    _recurring = [];
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_recurringKey);
    notifyListeners();
  }

  /// Checks all recurring transactions and generates new standard transactions if they are due.
  Future<void> generateDueTransactions(
    TransactionProvider transactionProvider,
  ) async {
    final now = DateTime.now();
    bool hasChanges = false;

    for (int i = 0; i < _recurring.length; i++) {
      var recurring = _recurring[i];

      // Skip if ended
      if (recurring.endDate != null && now.isAfter(recurring.endDate!)) {
        continue;
      }

      DateTime nextGenDate = recurring.lastGeneratedDate ?? recurring.startDate;

      // If start date is in the future, skip
      if (nextGenDate.isAfter(now)) continue;

      while (nextGenDate.isBefore(now) || nextGenDate.isAtSameMomentAs(now)) {
        // Check if this date is after the start date and before the end date
        if ((nextGenDate.isAfter(recurring.startDate) ||
                nextGenDate.isAtSameMomentAs(recurring.startDate)) &&
            (recurring.endDate == null ||
                nextGenDate.isBefore(recurring.endDate!))) {
          // Generate transaction
          final newTransaction = t.Transaction(
            id: 'recurring_${recurring.id}_${nextGenDate.toIso8601String()}',
            title: recurring.title,
            amount: recurring.amount,
            date: nextGenDate,
            isIncome: recurring.isIncome,
            category: recurring.category,
          );

          // Use a method in TransactionProvider to add if not exists
          await transactionProvider.addTransactionIfNotExists(newTransaction);
          hasChanges = true;
        }

        // Update last generated date and calculate next one
        recurring = RecurringTransaction(
          id: recurring.id,
          title: recurring.title,
          amount: recurring.amount,
          category: recurring.category,
          isIncome: recurring.isIncome,
          frequency: recurring.frequency,
          startDate: recurring.startDate,
          endDate: recurring.endDate,
          lastGeneratedDate: nextGenDate,
        );

        if (recurring.frequency == RecurrenceFrequency.daily) {
          nextGenDate = nextGenDate.add(const Duration(days: 1));
        } else if (recurring.frequency == RecurrenceFrequency.weekly) {
          nextGenDate = nextGenDate.add(const Duration(days: 7));
        } else if (recurring.frequency == RecurrenceFrequency.monthly) {
          nextGenDate = DateTime(
            nextGenDate.year,
            nextGenDate.month + 1,
            nextGenDate.day,
          );
        }
      }
      _recurring[i] = recurring; // Update the item in the list
    }

    if (hasChanges) {
      await _save();
      notifyListeners();
    }
  }
}
