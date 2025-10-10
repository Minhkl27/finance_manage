// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/providers/budget_provider.dart';
import '../../data/providers/transaction_provider.dart';
import '../../data/providers/template_provider.dart';
import '../../data/providers/recurring_transaction_provider.dart';
import '../../core/constants/app_constants.dart';
import '../dashboard/manage_templates_screen.dart';
import '../dashboard/manage_recurring_screen.dart';
import 'user_guide_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  void _showClearDataDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa tất cả dữ liệu'),
        content: const Text(
          'Bạn có chắc chắn muốn xóa tất cả dữ liệu (giao dịch và ngân sách)? Hành động này không thể hoàn tác.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              // Capture Navigator and ScaffoldMessenger before the async gap.
              final navigator = Navigator.of(ctx);
              final scaffoldMessenger = ScaffoldMessenger.of(context);

              // Sử dụng await để đợi hàm xóa dữ liệu hoàn tất
              await context.read<TransactionProvider>().clearAllData();
              await context.read<BudgetProvider>().clearAllData();
              await context.read<TemplateProvider>().clearAllData();
              await context.read<RecurringTransactionProvider>().clearAllData();

              // Now use the captured instances.
              navigator.pop();
              scaffoldMessenger.showSnackBar(
                const SnackBar(
                  content: Text('Đã xóa tất cả dữ liệu'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: AppConstants.appName,
      applicationVersion: AppConstants.appVersion,
      applicationIcon: const Icon(
        Icons.account_balance_wallet,
        size: 48,
        color: AppConstants.primaryColor,
      ),
      children: [
        const Text('Ứng dụng quản lý chi tiêu cá nhân đơn giản và hiệu quả.'),
        const SizedBox(height: 16),
        const Text('Tính năng:'),
        const Text('• Theo dõi thu nhập và chi tiêu'),
        const Text('• Xem báo cáo tài chính'),
        const Text('• Giao diện thân thiện'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Cài đặt',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF6366F1), // Primary purple
                const Color(0xFF3B82F6), // Primary blue
                const Color(0xFF10B981), // Success green
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        margin: EdgeInsets.only(bottom: 70),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary.withAlpha(20),
              Theme.of(context).colorScheme.surface,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.0, 0.4],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.only(
            left: AppConstants.defaultPadding,
            right: AppConstants.defaultPadding,
            top: AppConstants.defaultPadding,
            bottom: 80, // Thêm khoảng đệm dưới cùng
          ),
          children: [
            // App section
            const Text(
              'Ứng dụng',
              style: TextStyle(
                fontSize: AppConstants.headingFontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.smallPadding),

            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: const Text('Về ứng dụng'),
                    subtitle: Text('Phiên bản ${AppConstants.appVersion}'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _showAboutDialog,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.star_outline),
                    title: const Text('Đánh giá ứng dụng'),
                    subtitle: const Text('Hãy để lại đánh giá cho chúng tôi'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Tính năng đang phát triển'),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppConstants.largePadding),

            // Data section
            const Text(
              'Dữ liệu',
              style: TextStyle(
                fontSize: AppConstants.headingFontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.smallPadding),

            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.copy_all_outlined),
                    title: const Text('Quản lý Mẫu giao dịch'),
                    subtitle: const Text('Thêm, sửa, xóa các mẫu có sẵn'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const ManageTemplatesScreen(),
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.repeat_rounded),
                    title: const Text('Quản lý Giao dịch định kỳ'),
                    subtitle: const Text('Thiết lập các khoản thu/chi tự động'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const ManageRecurringScreen(),
                      ),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.backup_outlined),
                    title: const Text('Sao lưu dữ liệu'),
                    subtitle: const Text('Xuất dữ liệu ra file'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Tính năng đang phát triển'),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.restore_outlined),
                    title: const Text('Khôi phục dữ liệu'),
                    subtitle: const Text('Nhập dữ liệu từ file'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Tính năng đang phát triển'),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(
                      Icons.delete_forever,
                      color: Colors.red,
                    ),
                    title: const Text('Xóa tất cả dữ liệu'),
                    subtitle: const Text('Xóa vĩnh viễn tất cả giao dịch'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _showClearDataDialog,
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppConstants.largePadding),

            // Support section
            const Text(
              'Hỗ trợ',
              style: TextStyle(
                fontSize: AppConstants.headingFontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.smallPadding),

            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.help_outline),
                    title: const Text('Hướng dẫn sử dụng'),
                    subtitle: const Text('Tìm hiểu cách sử dụng ứng dụng'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const UserGuideScreen(),
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.question_answer_outlined),
                    title: const Text('FAQs'),
                    subtitle: const Text('Câu hỏi thường gặp'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Tính năng đang phát triển'),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.contact_mail_outlined),
                    title: const Text('Liên hệ'),
                    subtitle: const Text('Liên hệ với chúng tôi'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Tính năng đang phát triển'),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.description_outlined),
                    title: const Text('Điều khoản dịch vụ'),
                    subtitle: const Text(
                      'Đọc điều khoản dịch vụ của chúng tôi',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Tính năng đang phát triển'),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.privacy_tip_outlined),
                    title: const Text('Chính sách bảo mật'),
                    subtitle: const Text(
                      'Đọc chính sách bảo mật của chúng tôi',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Tính năng đang phát triển'),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.feedback_outlined),
                    title: const Text('Góp ý'),
                    subtitle: const Text('Gửi phản hồi cho nhà phát triển'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Tính năng đang phát triển'),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
