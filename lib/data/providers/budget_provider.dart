import 'package:flutter/foundation.dart';
import '../models/budget.dart';
import '../../core/services/storage_service.dart';

class BudgetProvider with ChangeNotifier {
  List<Budget> _budgets = [];
  bool _isLoading = false;

  List<Budget> get budgets => List.unmodifiable(_budgets);
  bool get isLoading => _isLoading;

  // Load budgets from storage
  Future<void> loadBudgets() async {
    _isLoading = true;
    notifyListeners();

    try {
      final storageService = await StorageService.getInstance();
      _budgets = await storageService.loadBudgets();
    } catch (e) {
      debugPrint('Error loading budgets: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Save budgets to storage
  Future<void> _saveBudgets() async {
    try {
      final storageService = await StorageService.getInstance();
      await storageService.saveBudgets(_budgets);
    } catch (e) {
      debugPrint('Error saving budgets: $e');
    }
  }

  // Add budget
  Future<void> addBudget(Budget budget) async {
    _budgets.add(budget);
    notifyListeners();
    await _saveBudgets();
  }

  // Update budget
  Future<void> updateBudget(String id, Budget updatedBudget) async {
    final index = _budgets.indexWhere((b) => b.id == id);
    if (index != -1) {
      _budgets[index] = updatedBudget;
      notifyListeners();
      await _saveBudgets();
    }
  }

  // Delete budget
  Future<void> deleteBudget(String id) async {
    _budgets.removeWhere((b) => b.id == id);
    notifyListeners();
    await _saveBudgets();
  }

  // Clear all budgets
  Future<void> clearAllData() async {
    _budgets.clear();
    notifyListeners();
    await _saveBudgets();
  }
}
