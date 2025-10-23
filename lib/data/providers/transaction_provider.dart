import 'package:flutter/foundation.dart';
import '../models/transaction.dart';
import '../../core/services/notification_service.dart';
import '../../core/services/storage_service.dart';
import 'budget_provider.dart';

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

  // Kiểm tra số dư và gửi thông báo nếu cần
  Future<void> _checkBalanceAndNotify(double oldBalance) async {
    const threshold = 300000;
    final newBalance =
        balance; // `balance` là một getter, nó sẽ được tính toán lại

    // Chỉ gửi thông báo khi số dư VỪA MỚI giảm xuống dưới ngưỡng
    if (oldBalance >= threshold && newBalance < threshold) {
      await NotificationService().showNotification(
        'Cảnh báo số dư thấp',
        'Số dư hiện tại còn dưới 300.000! Hãy chi tiêu tiết kiệm hơn.',
      );
    }
  }

  // Kiểm tra ngân sách và gửi thông báo nếu cần
  Future<void> checkBudgetsAndNotify(
    BudgetProvider budgetProvider, {
    Transaction? oldTransaction, // Giao dịch cũ (khi sửa/xóa)
    Transaction? newTransaction, // Giao dịch mới (khi thêm/sửa)
  }) async {
    // Chỉ kiểm tra ngân sách cho các giao dịch chi tiêu
    if ((newTransaction?.isIncome ?? true) &&
        (oldTransaction?.isIncome ?? true)) {
      return;
    }

    final now = DateTime.now();
    final monthBudgets = budgetProvider.budgets
        .where((b) => b.month.year == now.year && b.month.month == now.month)
        .toList();

    if (monthBudgets.isEmpty) return;

    const threshold = 200000;

    for (final budget in monthBudgets) {
      // Tính toán số tiền đã chi cho danh mục này
      final currentSpent = _transactions
          .where(
            (tx) =>
                !tx.isIncome &&
                tx.category.toLowerCase() == budget.category.toLowerCase() &&
                tx.date.year == now.year &&
                tx.date.month == now.month,
          )
          .fold(0.0, (sum, item) => sum + item.amount);

      // Ước tính số tiền đã chi TRƯỚC khi có thay đổi này
      double previousSpent = currentSpent;
      if (newTransaction != null &&
          !newTransaction.isIncome &&
          newTransaction.category.toLowerCase() ==
              budget.category.toLowerCase()) {
        previousSpent -= newTransaction.amount; // Trừ đi giao dịch mới thêm
      }
      if (oldTransaction != null &&
          !oldTransaction.isIncome &&
          oldTransaction.category.toLowerCase() ==
              budget.category.toLowerCase()) {
        previousSpent +=
            oldTransaction.amount; // Cộng lại giao dịch cũ đã xóa/sửa
      }

      final previousRemaining = budget.amount - previousSpent;
      final currentRemaining = budget.amount - currentSpent;

      // Chỉ gửi thông báo khi số tiền còn lại VỪA MỚI giảm xuống dưới ngưỡng
      if (previousRemaining >= threshold && currentRemaining < threshold) {
        await NotificationService().showNotification(
          'Cảnh báo ngân sách',
          'Ngân sách cho "${budget.category}" sắp hết! Chỉ còn dưới 200.000.',
        );
      }
    }
  }

  // Add transaction
  Future<void> addTransaction(
    Transaction transaction, {
    required bool fromRecurring,
  }) async {
    final oldBalance = balance;
    _transactions.add(transaction);
    // Sắp xếp lại danh sách để giao dịch mới nhất lên đầu
    _transactions.sort((a, b) => b.date.compareTo(a.date));
    notifyListeners();
    await _saveTransactions();
    await _checkBalanceAndNotify(oldBalance);
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
    if (index == -1) return;

    final oldBalance = balance;

    _transactions[index] = updatedTransaction;
    _transactions.sort((a, b) => b.date.compareTo(a.date));
    notifyListeners();

    await _checkBalanceAndNotify(oldBalance);
    // Việc kiểm tra ngân sách sẽ được gọi từ UI
    await _saveTransactions();
  }

  // Delete transaction
  Future<void> deleteTransaction(String id) async {
    final index = _transactions.indexWhere((tx) => tx.id == id);
    if (index == -1) return;

    final oldBalance = balance;
    _transactions.removeWhere((tx) => tx.id == id);
    notifyListeners();
    await _saveTransactions();
    await _checkBalanceAndNotify(oldBalance);
    // Việc kiểm tra ngân sách sẽ được gọi từ UI
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
