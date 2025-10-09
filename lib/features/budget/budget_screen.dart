// ignore_for_file: deprecated_member_use

import 'package:finance_manage/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/formatters.dart';
import '../../data/providers/budget_provider.dart';
import '../../data/providers/transaction_provider.dart';
import '../../widgets/empty_state.dart';
import 'add_edit_budget_screen.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  DateTime _selectedMonth = DateTime.now();

  Future<void> _selectMonth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDatePickerMode: DatePickerMode.year,
    );
    if (picked != null && mounted) {
      setState(() {
        _selectedMonth = DateTime(picked.year, picked.month);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ngân sách',
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
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.calendar_month, color: Colors.white),
              onPressed: _selectMonth,
            ),
          ),
        ],
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
        child: Consumer2<BudgetProvider, TransactionProvider>(
          builder: (context, budgetProvider, transactionProvider, child) {
            final monthBudgets = budgetProvider.budgets
                .where(
                  (b) =>
                      b.month.year == _selectedMonth.year &&
                      b.month.month == _selectedMonth.month,
                )
                .toList();

            if (monthBudgets.isEmpty) {
              return EmptyState(
                icon: Icons.account_balance_wallet_outlined,
                title: 'Chưa có ngân sách',
                subtitle: 'Hãy tạo ngân sách đầu tiên để quản lý chi tiêu.',
                action: ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const AddEditBudgetScreen(),
                    ),
                  ),
                  icon: const Icon(Icons.add),
                  label: const Text('Tạo ngân sách'),
                ),
              );
            }

            final totalBudgetForMonth = monthBudgets.fold<double>(
              0.0,
              (sum, budget) => sum + budget.amount,
            );

            final allMonthTransactions = transactionProvider
                .getTransactionsByMonth(_selectedMonth);

            double totalSpentForMonth = 0;
            for (final budget in monthBudgets) {
              final spentForCategory = allMonthTransactions
                  .where(
                    (tx) =>
                        !tx.isIncome &&
                        tx.category.toLowerCase() ==
                            budget.category.toLowerCase(),
                  )
                  .fold(0.0, (sum, item) => sum + item.amount);
              totalSpentForMonth += spentForCategory;
            }

            final totalRemainingForMonth =
                totalBudgetForMonth - totalSpentForMonth;
            final overallProgress = (totalBudgetForMonth > 0)
                ? (totalSpentForMonth / totalBudgetForMonth)
                      .clamp(0.0, 1.0)
                      .toDouble()
                : 0.0;

            return ListView.builder(
              padding: const EdgeInsets.only(
                left: AppConstants.defaultPadding,
                right: AppConstants.defaultPadding,
                top: AppConstants.defaultPadding,
                bottom: 80, // Thêm khoảng đệm dưới cùng
              ),
              itemCount: monthBudgets.length + 1, // +1 for the summary card
              itemBuilder: (context, index) {
                if (index == 0) {
                  // Build the summary card
                  return _buildOverallSummaryCard(
                    context,
                    _selectedMonth,
                    totalBudgetForMonth,
                    totalSpentForMonth,
                    totalRemainingForMonth,
                    overallProgress,
                  );
                }

                // Build individual budget items
                final budget = monthBudgets[index - 1];
                final spent = transactionProvider.transactions
                    .where(
                      (tx) =>
                          !tx.isIncome &&
                          tx.category.toLowerCase() ==
                              budget.category.toLowerCase() &&
                          tx.date.year == budget.month.year &&
                          tx.date.month == budget.month.month,
                    )
                    .fold(0.0, (sum, item) => sum + item.amount);

                final remaining = budget.amount - spent;
                final progress = (spent / budget.amount)
                    .clamp(0.0, 1.0)
                    .toDouble();

                return Card(
                  margin: const EdgeInsets.only(
                    bottom: AppConstants.defaultPadding,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppConstants.defaultPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  budget.category,
                                  style: GoogleFonts.inter(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Tháng ${Formatters.formatMonthYear(budget.month)}',
                                  style: GoogleFonts.inter(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      AddEditBudgetScreen(budget: budget),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppConstants.largePadding),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Đã chi: ${Formatters.formatCurrency(spent)}'),
                            Text(
                              'Còn lại: ${Formatters.formatCurrency(remaining)}',
                            ),
                          ],
                        ),
                        const SizedBox(height: AppConstants.smallPadding),
                        LinearProgressIndicator(
                          value: progress,
                          minHeight: 10,
                          borderRadius: BorderRadius.circular(5),
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary.withAlpha(50),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            progress > 0.8
                                ? Colors.red
                                : Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: AppConstants.smallPadding),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            'Tổng ngân sách: ${Formatters.formatCurrency(budget.amount)}',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w500,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildOverallSummaryCard(
    BuildContext context,
    DateTime month,
    double totalBudget,
    double totalSpent,
    double totalRemaining,
    double progress,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.largePadding),
      elevation: 4,
      shadowColor: colorScheme.primary.withOpacity(0.2),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tổng quan tháng ${Formatters.formatMonthYear(month)}',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: AppConstants.largePadding),
            _buildSummaryRow(
              'Tổng ngân sách:',
              Formatters.formatCurrency(totalBudget),
              colorScheme.onSurface,
            ),
            const SizedBox(height: AppConstants.smallPadding),
            _buildSummaryRow(
              'Đã chi tiêu:',
              Formatters.formatCurrency(totalSpent),
              AppTheme.errorRed,
            ),
            const SizedBox(height: AppConstants.smallPadding),
            _buildSummaryRow(
              'Còn lại:',
              Formatters.formatCurrency(totalRemaining),
              AppTheme.successGreen,
            ),
            const SizedBox(height: AppConstants.largePadding),
            LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              borderRadius: BorderRadius.circular(6),
              backgroundColor: colorScheme.primary.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                progress > 0.8 ? AppTheme.errorRed : colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
