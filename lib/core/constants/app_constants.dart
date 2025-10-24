import 'package:flutter/material.dart';

class AppConstants {
  // App Information
  static const String appName = 'Quản lý Chi tiêu';
  static const String appVersion = '1.0.0';

  // Currency
  static const String currency = 'VNĐ';

  // Colors
  static const Color primaryColor = Colors.green;
  static const Color incomeColor = Colors.green;
  static const Color expenseColor = Colors.red;
  static const Color balanceColor = Colors.blue;

  // Spacing
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;

  // Border Radius
  static const double defaultBorderRadius = 12.0;
  static const double smallBorderRadius = 8.0;

  // Font Sizes
  static const double titleFontSize = 28.0;
  static const double headingFontSize = 18.0;
  static const double bodyFontSize = 16.0;
  static const double captionFontSize = 14.0;

  // Animation Duration
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);

  // Storage Keys
  static const String transactionsKey = 'transactions';
  static const String budgetsKey = 'budgets';
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language';
  static const String notificationsKey = 'notifications';
}
