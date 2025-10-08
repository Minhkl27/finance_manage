import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  // App strings
  String get appName => 'Quản lý Chi tiêu';
  String get dashboard => 'Tổng quan';
  String get transactions => 'Giao dịch';
  String get reports => 'Báo cáo';
  String get budget => 'Ngân sách';
  String get settings => 'Cài đặt';

  // Transaction strings
  String get addTransaction => 'Thêm giao dịch';
  String get editTransaction => 'Sửa giao dịch';
  String get income => 'Thu nhập';
  String get expense => 'Chi tiêu';
  String get amount => 'Số tiền';
  String get description => 'Mô tả';
  String get date => 'Ngày';
  String get save => 'Lưu';
  String get cancel => 'Hủy';
  String get delete => 'Xóa';

  // Balance strings
  String get currentBalance => 'Số dư hiện tại';
  String get totalIncome => 'Tổng thu nhập';
  String get totalExpense => 'Tổng chi tiêu';

  // Messages
  String get noTransactions => 'Chưa có giao dịch nào';
  String get addFirstTransaction => 'Nhấn nút + để thêm giao dịch đầu tiên';
  String get confirmDelete => 'Bạn có chắc chắn muốn xóa giao dịch này?';
  String get transactionAdded => 'Giao dịch đã được thêm!';
  String get transactionUpdated => 'Giao dịch đã được cập nhật!';
  String get pleaseEnterValidInfo => 'Vui lòng nhập đầy đủ thông tin hợp lệ!';
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['vi', 'en'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
