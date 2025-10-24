import 'package:intl/intl.dart';

class Formatters {
  // Format currency
  static String formatCurrency(double amount) {
    final formatter = NumberFormat('#,###', 'vi_VN');
    return '${formatter.format(amount)} VNĐ';
  }

  // Format currency with sign
  static String formatCurrencyWithSign(double amount, bool isIncome) {
    final sign = isIncome ? '+' : '-';
    return '$sign${formatCurrency(amount.abs())}';
  }

  // Format date
  static String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  // Format date with time
  static String formatDateTime(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  // Format date for display (e.g., "Hôm nay", "Hôm qua", etc.)
  static String formatDateForDisplay(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Hôm nay';
    } else if (dateOnly == yesterday) {
      return 'Hôm qua';
    } else {
      return formatDate(date);
    }
  }

  // Format month year
  static String formatMonthYear(DateTime date) {
    return DateFormat('MM/yyyy').format(date);
  }

  // Format time ago
  static String formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 5) {
      return 'Vừa xong';
    } else if (difference.inMinutes < 1) {
      return '${difference.inSeconds} giây trước';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} phút trước';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    }
    return formatDate(date);
  }

  // Parse currency string to double
  static double? parseCurrency(String value) {
    // Remove currency symbol and spaces
    final cleanValue = value.replaceAll(RegExp(r'[^\d,.]'), '');
    // Replace comma with dot for parsing
    final normalizedValue = cleanValue.replaceAll(',', '');
    return double.tryParse(normalizedValue);
  }
}
