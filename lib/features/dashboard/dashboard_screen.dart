// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:finance_manage/features/dashboard/add_edit_recurring_screen.dart';
import 'package:finance_manage/features/transactions/add_transaction_screen.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/transaction.dart';
import '../../data/providers/template_provider.dart';
import '../../data/providers/transaction_provider.dart';
import '../../widgets/empty_state.dart';
import '../budget/add_edit_budget_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isBalanceVisible = true;

  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final totalBalance = transactionProvider.balance;
    final recentTransactions = transactionProvider.transactions
        .take(5)
        .toList();

    final now = DateTime.now();
    final monthTransactions = transactionProvider.getTransactionsByMonth(now);
    final monthIncome = monthTransactions
        .where((tx) => tx.isIncome)
        .fold(0.0, (sum, tx) => sum + tx.amount);
    final monthExpense = monthTransactions
        .where((tx) => !tx.isIncome)
        .fold(0.0, (sum, tx) => sum + tx.amount);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tổng quan',
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
        child: transactionProvider.transactions.isEmpty
            ? const EmptyState(
                icon: Icons.account_balance_wallet_outlined,
                title: 'Chào mừng bạn!',
                subtitle: 'Hãy bắt đầu bằng cách thêm giao dịch đầu tiên.',
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBalanceCard(context, totalBalance, _isBalanceVisible),
                    const SizedBox(height: AppConstants.defaultPadding),
                    _buildActionButtons(context),
                    const SizedBox(height: AppConstants.largePadding),
                    Row(
                      children: [
                        Expanded(
                          child: _buildSummaryCard(
                            context,
                            'Thu nhập tháng',
                            monthIncome,
                            const Color(0xFF10B981),
                            Icons.trending_up_rounded,
                          ),
                        ),
                        const SizedBox(width: AppConstants.smallPadding),
                        Expanded(
                          child: _buildSummaryCard(
                            context,
                            'Chi tiêu tháng',
                            monthExpense,
                            const Color(0xFFEF4444),
                            Icons.trending_down_rounded,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.largePadding),
                    Text(
                      'Giao dịch gần đây',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: AppConstants.defaultPadding),
                    _buildRecentTransactions(context, recentTransactions),
                    const SizedBox(height: 80), // Padding for FAB
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildBalanceCard(
    BuildContext context,
    double balance,
    bool isVisible,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF6366F1), // Primary purple from theme
              const Color(0xFF3B82F6), // Primary blue from theme
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Decorative patterns
            Positioned(
              top: -50,
              right: -50,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
            ),
            Positioned(
              bottom: -60,
              left: -30,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                    width: 2,
                  ),
                ),
              ),
            ),
            // Main content
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Số dư hiện tại',
                        style: GoogleFonts.inter(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 16,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          isVisible ? Icons.visibility_off : Icons.visibility,
                          color: Colors.white.withOpacity(0.8),
                        ),
                        onPressed: () {
                          setState(() {
                            _isBalanceVisible = !_isBalanceVisible;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isVisible ? Formatters.formatCurrency(balance) : '••••••••',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    String title,
    double amount,
    Color color,
    IconData icon,
  ) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                Icon(icon, color: color, size: 20),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              Formatters.formatCurrency(amount),
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildActionButton(
          context,
          icon: Icons.add_card_rounded,
          label: 'Thêm GD',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
          ),
        ),
        _buildActionButton(
          context,
          icon: Icons.edit_note_rounded,
          label: 'Ngân sách',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddEditBudgetScreen()),
          ),
        ),
        _buildActionButton(
          context,
          icon: Icons.more_horiz_rounded,
          label: 'Thêm',
          onTap: () {
            _showMoreActions(context);
          },
        ),
      ],
    );
  }

  Widget _buildRecentTransactions(
    BuildContext context,
    List<Transaction> transactions,
  ) {
    return Card(
      // Remove the outer card and build a list of items directly
      // to give a more integrated feel.
      // elevation: 2,
      // shadowColor: Colors.black.withOpacity(0.1),
      // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          final tx = transactions[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor:
                  (tx.isIncome
                          ? const Color(0xFF10B981)
                          : const Color(0xFFEF4444))
                      .withOpacity(0.1),
              child: Icon(
                tx.isIncome
                    ? Icons.trending_up_rounded
                    : Icons.trending_down_rounded,
                color: tx.isIncome
                    ? const Color(0xFF10B981)
                    : const Color(0xFFEF4444),
                size: 20,
              ),
            ),
            title: Text(
              tx.title,
              style: GoogleFonts.inter(fontWeight: FontWeight.w500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(Formatters.formatDateForDisplay(tx.date)),
            trailing: Text(
              Formatters.formatCurrencyWithSign(tx.amount, tx.isIncome),
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                color: tx.isIncome
                    ? const Color(0xFF10B981)
                    : const Color(0xFFEF4444),
              ),
            ),
          );
        },
        separatorBuilder: (context, index) =>
            const Divider(height: 1, indent: 72),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: colorScheme.primary.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Icon(icon, color: colorScheme.primary, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  void _showMoreActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.copy_rounded),
                title: const Text('Thêm từ Mẫu'),
                subtitle: const Text('Tạo giao dịch nhanh từ các mẫu có sẵn'),
                onTap: () {
                  Navigator.of(ctx).pop(); // Close the first bottom sheet
                  _showTemplatesBottomSheet(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.repeat_rounded),
                title: const Text('Thêm giao dịch định kỳ'),
                subtitle: const Text('Thiết lập các khoản thu/chi lặp lại'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const AddEditRecurringScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.swap_horiz_rounded),
                title: const Text('Chuyển tiền'),
                subtitle: const Text('Ghi lại việc chuyển tiền giữa các ví'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Tính năng "Chuyển tiền" đang phát triển'),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showTemplatesBottomSheet(BuildContext context) {
    final templateProvider = context.read<TemplateProvider>();
    final templates = templateProvider.templates;

    if (templates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Không có mẫu nào. Hãy vào Cài đặt > Quản lý Mẫu để tạo.',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Chọn một mẫu để tạo giao dịch',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: templates.length,
                itemBuilder: (listCtx, index) {
                  final template = templates[index];
                  return ListTile(
                    leading: Icon(
                      template.isIncome
                          ? Icons.trending_up
                          : Icons.trending_down,
                      color: template.isIncome ? Colors.green : Colors.red,
                    ),
                    title: Text(template.title),
                    subtitle: Text(
                      '${template.category} - ${Formatters.formatCurrency(template.amount)}',
                    ),
                    onTap: () {
                      Navigator.of(ctx).pop(); // Close the template list
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              AddTransactionScreen(template: template),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
