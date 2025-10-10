enum RecurrenceFrequency { daily, weekly, monthly }

extension RecurrenceFrequencyExtension on RecurrenceFrequency {
  String get displayName {
    switch (this) {
      case RecurrenceFrequency.daily:
        return 'Hàng ngày';
      case RecurrenceFrequency.weekly:
        return 'Hàng tuần';
      case RecurrenceFrequency.monthly:
        return 'Hàng tháng';
    }
  }
}

// Helper to get enum from string
RecurrenceFrequency recurrenceFrequencyFromString(String value) =>
    RecurrenceFrequency.values.firstWhere((e) => e.toString() == value);
