// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/providers/notification_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/providers/transaction_provider.dart';
import '../../data/providers/budget_provider.dart';
import '../../widgets/transaction_item.dart';
import '../../data/models/transaction.dart';
import '../../widgets/empty_state.dart';
import 'add_transaction_screen.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/formatters.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  String _filterType = 'all'; // all, income, expense
  DateTime? _selectedMonth;

  void _showAddTransactionScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const AddTransactionScreen()),
    );
  }

  void _editTransaction(Transaction transaction) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddTransactionScreen(transaction: transaction),
      ),
    );
  }

  void _deleteTransaction(Transaction transaction) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text(
          'Bạn có chắc chắn muốn xóa giao dịch "${transaction.title}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              final transactionProvider = context.read<TransactionProvider>();
              final notificationProvider = context.read<NotificationProvider>();
              final budgetProvider = context.read<BudgetProvider>();
              await transactionProvider.deleteTransaction(
                transaction.id,
                notificationProvider,
              );
              Navigator.of(ctx).pop();
              // Kiểm tra ngân sách sau khi xóa
              await transactionProvider.checkBudgetsAndNotify(
                budgetProvider,
                notificationProvider,
                oldTransaction: transaction,
              );
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _selectMonth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonth ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDatePickerMode: DatePickerMode.year,
    );
    if (picked != null) {
      setState(() {
        _selectedMonth = DateTime(picked.year, picked.month);
      });
    }
  }

  void _clearFilter() {
    setState(() {
      _selectedMonth = null;
      _filterType = 'all';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Giao dịch',
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
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onSelected: (value) {
                if (value == 'month') {
                  _selectMonth();
                } else if (value == 'clear') {
                  _clearFilter();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'month',
                  child: Row(
                    children: [
                      Icon(Icons.calendar_month),
                      SizedBox(width: 8),
                      Text('Lọc theo tháng'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'clear',
                  child: Row(
                    children: [
                      Icon(Icons.clear),
                      SizedBox(width: 8),
                      Text('Xóa bộ lọc'),
                    ],
                  ),
                ),
              ],
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
        child: Consumer<TransactionProvider>(
          builder: (context, transactionProvider, child) {
            var transactions = transactionProvider.transactions;

            // Apply filters
            if (_selectedMonth != null) {
              transactions = transactionProvider.getTransactionsByMonth(
                _selectedMonth!,
              );
            }

            if (_filterType == 'income') {
              transactions = transactions.where((tx) => tx.isIncome).toList();
            } else if (_filterType == 'expense') {
              transactions = transactions.where((tx) => !tx.isIncome).toList();
            }

            return Column(
              children: [
                // Filter chips
                Container(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_selectedMonth != null)
                        Chip(
                          label: Text(
                            'Tháng ${Formatters.formatMonthYear(_selectedMonth!)}',
                          ),
                          onDeleted: () =>
                              setState(() => _selectedMonth = null),
                        ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            FilterChip(
                              label: const Text('Tất cả'),
                              selected: _filterType == 'all',
                              onSelected: (selected) {
                                setState(() => _filterType = 'all');
                              },
                            ),
                            const SizedBox(width: 8),
                            FilterChip(
                              label: const Text('Thu nhập'),
                              selected: _filterType == 'income',
                              onSelected: (selected) {
                                setState(
                                  () =>
                                      _filterType = selected ? 'income' : 'all',
                                );
                              },
                            ),
                            const SizedBox(width: 8),
                            FilterChip(
                              label: const Text('Chi tiêu'),
                              selected: _filterType == 'expense',
                              onSelected: (selected) {
                                setState(
                                  () => _filterType = selected
                                      ? 'expense'
                                      : 'all',
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Transactions list
                Expanded(
                  child: transactions.isEmpty
                      ? EmptyState(
                          icon: Icons.receipt_long,
                          title: 'Không có giao dịch nào',
                          subtitle:
                              _selectedMonth != null || _filterType != 'all'
                              ? 'Không tìm thấy giao dịch với bộ lọc hiện tại'
                              : 'Nhấn nút + để thêm giao dịch đầu tiên',
                          action: ElevatedButton.icon(
                            onPressed: _showAddTransactionScreen,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                            icon: const Icon(Icons.add),
                            label: const Text('Thêm giao dịch'),
                          ),
                        )
                      : ListView.builder(
                          itemCount: transactions.length,
                          itemBuilder: (ctx, index) {
                            return TransactionItem(
                              transaction: transactions[index],
                              onTap: () =>
                                  _editTransaction(transactions[index]),
                              onDelete: () =>
                                  _deleteTransaction(transactions[index]),
                            );
                          },
                          padding: const EdgeInsets.only(
                            left: AppConstants.defaultPadding,
                            right: AppConstants.defaultPadding,
                            bottom: 140, // Thêm khoảng đệm dưới cùng
                          ),
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
