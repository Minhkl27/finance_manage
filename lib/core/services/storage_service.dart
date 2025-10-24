import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/transaction.dart';
import '../../data/models/budget.dart';
import '../../data/models/app_notification.dart';
import '../constants/app_constants.dart';

class StorageService {
  static StorageService? _instance;
  static SharedPreferences? _prefs;

  StorageService._();

  static Future<StorageService> getInstance() async {
    _instance ??= StorageService._();
    _prefs ??= await SharedPreferences.getInstance();
    return _instance!;
  }

  // Save transactions
  Future<bool> saveTransactions(List<Transaction> transactions) async {
    try {
      final jsonList = transactions.map((tx) => tx.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      return await _prefs!.setString(AppConstants.transactionsKey, jsonString);
    } catch (e) {
      return false;
    }
  }

  // Load transactions
  Future<List<Transaction>> loadTransactions() async {
    try {
      final jsonString = _prefs!.getString(AppConstants.transactionsKey);
      if (jsonString == null) return [];

      final jsonList = jsonDecode(jsonString) as List;
      return jsonList.map((json) => Transaction.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  // Save budgets
  Future<bool> saveBudgets(List<Budget> budgets) async {
    try {
      final jsonList = budgets.map((b) => b.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      return await _prefs!.setString(AppConstants.budgetsKey, jsonString);
    } catch (e) {
      return false;
    }
  }

  // Load budgets
  Future<List<Budget>> loadBudgets() async {
    try {
      final jsonString = _prefs!.getString(AppConstants.budgetsKey);
      if (jsonString == null) return [];

      final jsonList = jsonDecode(jsonString) as List;
      return jsonList.map((json) => Budget.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  // Save AppNotifications
  Future<bool> saveAppNotifications(List<AppNotification> notifications) async {
    try {
      final jsonList = notifications.map((n) => n.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      return await _prefs!.setString(AppConstants.notificationsKey, jsonString);
    } catch (e) {
      return false;
    }
  }

  // Load AppNotifications
  Future<List<AppNotification>> loadAppNotifications() async {
    try {
      final jsonString = _prefs!.getString(AppConstants.notificationsKey);
      if (jsonString == null) return [];

      final jsonList = jsonDecode(jsonString) as List;
      return jsonList.map((json) => AppNotification.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  // Save theme mode
  Future<bool> saveThemeMode(String themeMode) async {
    return await _prefs!.setString(AppConstants.themeKey, themeMode);
  }

  // Load theme mode
  String? loadThemeMode() {
    return _prefs!.getString(AppConstants.themeKey);
  }

  // Save language
  Future<bool> saveLanguage(String language) async {
    return await _prefs!.setString(AppConstants.languageKey, language);
  }

  // Load language
  String? loadLanguage() {
    return _prefs!.getString(AppConstants.languageKey);
  }

  // Clear all data
  Future<bool> clearAll() async {
    return await _prefs!.clear();
  }
}
