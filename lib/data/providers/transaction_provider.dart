import 'package:flutter/foundation.dart';
import '../models/transaction.dart';
import '../../core/services/storage_service.dart';

class TransactionProvider with ChangeNotifier {
  List<Transaction> _transactions = [];
  bool _isLoading = false;

  List<Transaction> get transactions => List.unmodifiable(_transactions);
  bool get isLoading => _isLoading;

  // Tính tổng thu nhập
  double get totalIncome {
    return _transactions
        .where((tx) => tx.isIncome)
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  // Tính tổng chi tiêu
  double get totalExpense {
    return _transactions
        .where((tx) => !tx.isIncome)
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  // Tính số dư
  double get balance {
    return totalIncome - totalExpense;
  }

  // Load transactions from storage
  Future<void> loadTransactions() async {
    _isLoading = true;
    notifyListeners();

    try {
      final storageService = await StorageService.getInstance();
      _transactions = await storageService.loadTransactions();
    } catch (e) {
      debugPrint('Error loading transactions: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Save transactions to storage
  Future<void> _saveTransactions() async {
    try {
      final storageService = await StorageService.getInstance();
      await storageService.saveTransactions(_transactions);
    } catch (e) {
      debugPrint('Error saving transactions: $e');
    }
  }

  // Add transaction
  Future<void> addTransaction(Transaction transaction) async {
    _transactions.add(transaction);
    notifyListeners();
    await _saveTransactions();
  }

  // Add transaction only if an entry with the same ID doesn't exist
  Future<void> addTransactionIfNotExists(Transaction transaction) async {
    if (!_transactions.any((tx) => tx.id == transaction.id)) {
      _transactions.add(transaction);
      // Sort by date after adding to keep list consistent
      _transactions.sort((a, b) => b.date.compareTo(a.date));
      await _saveTransactions();
    }
  }

  // Update transaction
  Future<void> updateTransaction(
    String id,
    Transaction updatedTransaction,
  ) async {
    final index = _transactions.indexWhere((tx) => tx.id == id);
    if (index != -1) {
      _transactions[index] = updatedTransaction;
      notifyListeners();
      await _saveTransactions();
    }
  }

  // Delete transaction
  Future<void> deleteTransaction(String id) async {
    _transactions.removeWhere((tx) => tx.id == id);
    notifyListeners();
    await _saveTransactions();
  }

  // Get transactions by date range
  List<Transaction> getTransactionsByDateRange(DateTime start, DateTime end) {
    return _transactions.where((tx) {
      return tx.date.isAfter(start.subtract(const Duration(days: 1))) &&
          tx.date.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  // Get transactions by month
  List<Transaction> getTransactionsByMonth(DateTime month) {
    return _transactions.where((tx) {
      return tx.date.year == month.year && tx.date.month == month.month;
    }).toList();
  }

  // Clear all transactions
  Future<void> clearAllData() async {
    _transactions.clear();
    notifyListeners();
    await _saveTransactions();
  }
}
