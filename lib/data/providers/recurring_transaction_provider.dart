import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/recurring_transaction.dart';
import 'notification_provider.dart';
import '../models/transaction.dart' as tx_model;
import 'transaction_provider.dart';

class RecurringTransactionProvider with ChangeNotifier {
  List<RecurringTransaction> _recurringTransactions = [];
  static const _storageKey = 'recurringTransactions';

  List<RecurringTransaction> get recurringTransactions => [
    ..._recurringTransactions,
  ];

  Future<void> loadRecurringTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final dataString = prefs.getString(_storageKey);
    if (dataString != null) {
      final List<dynamic> data = json.decode(dataString);
      _recurringTransactions = data
          .map((item) => RecurringTransaction.fromJson(item))
          .toList();
      notifyListeners();
    }
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    final dataString = json.encode(
      _recurringTransactions.map((item) => item.toJson()).toList(),
    );
    await prefs.setString(_storageKey, dataString);
  }

  Future<void> addRecurring(RecurringTransaction recurring) async {
    _recurringTransactions.add(recurring);
    await _saveData();
    notifyListeners();
  }

  Future<void> updateRecurring(
    String id,
    RecurringTransaction newRecurring,
  ) async {
    final index = _recurringTransactions.indexWhere((item) => item.id == id);
    if (index != -1) {
      _recurringTransactions[index] = newRecurring;
      await _saveData();
      notifyListeners();
    }
  }

  Future<void> deleteRecurring(String id) async {
    _recurringTransactions.removeWhere((item) => item.id == id);
    await _saveData();
    notifyListeners();
  }

  Future<void> clearAllData() async {
    _recurringTransactions = [];
    await _saveData();
    notifyListeners();
  }

  Future<void> generateDueTransactions(
    TransactionProvider transactionProvider,
    NotificationProvider notificationProvider,
  ) async {
    final now = DateTime.now();
    bool hasGenerated = false;

    for (int i = 0; i < _recurringTransactions.length; i++) {
      final recurring = _recurringTransactions[i];

      // Kiểm tra xem hôm nay có phải là ngày cần tạo giao dịch không
      if (recurring.dayOfMonth == now.day) {
        final lastGenerated = recurring.lastGeneratedDate;

        // Kiểm tra xem giao dịch đã được tạo trong tháng này chưa
        // (so sánh năm và tháng của lần tạo cuối và hiện tại)
        if (lastGenerated == null ||
            lastGenerated.year < now.year ||
            (lastGenerated.year == now.year &&
                lastGenerated.month < now.month)) {
          // Tạo giao dịch mới
          final newTransaction = tx_model.Transaction(
            id: 'recurring-${recurring.id}-${now.toIso8601String()}',
            title: recurring.title,
            amount: recurring.amount,
            date: now,
            category: recurring.category,
            isIncome: recurring.isIncome,
            notes: 'Tạo tự động từ giao dịch định kỳ',
          );

          // Thêm giao dịch vào danh sách
          await transactionProvider.addTransaction(
            newTransaction,
            fromRecurring: true,
            notificationProvider: notificationProvider,
          );

          // Gửi thông báo đến người dùng
          await notificationProvider.addNotification(
            'Giao dịch định kỳ được tạo',
            'Giao dịch "${recurring.title}" đã được tự động thêm.',
          );

          // Cập nhật lại ngày tạo cuối cùng cho giao dịch định kỳ này
          _recurringTransactions[i] = recurring.copyWith(
            lastGeneratedDate: now,
          );
          hasGenerated = true;
        }
      }
    }

    if (hasGenerated) {
      // Nếu có bất kỳ giao dịch nào được tạo, lưu lại thay đổi và thông báo
      await _saveData();
      notifyListeners();
    }
  }
}
