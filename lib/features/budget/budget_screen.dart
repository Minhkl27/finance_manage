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
            final budgets = budgetProvider.budgets;

            if (budgets.isEmpty) {
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

            return ListView.builder(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              itemCount: budgets.length,
              itemBuilder: (context, index) {
                final budget = budgets[index];
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
}
