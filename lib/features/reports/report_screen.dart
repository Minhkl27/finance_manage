// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/providers/transaction_provider.dart';
import '../../widgets/empty_state.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/formatters.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Báo cáo',
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
        child: Consumer<TransactionProvider>(
          builder: (context, transactionProvider, child) {
            final monthTransactions = transactionProvider
                .getTransactionsByMonth(_selectedMonth);

            if (monthTransactions.isEmpty) {
              return EmptyState(
                icon: Icons.bar_chart,
                title: 'Không có dữ liệu',
                subtitle:
                    'Không có giao dịch nào trong tháng ${Formatters.formatMonthYear(_selectedMonth)}',
              );
            }

            final monthIncome = monthTransactions
                .where((tx) => tx.isIncome)
                .fold(0.0, (sum, tx) => sum + tx.amount);

            final monthExpense = monthTransactions
                .where((tx) => !tx.isIncome)
                .fold(0.0, (sum, tx) => sum + tx.amount);

            // Group expenses by category
            final Map<String, double> categoryExpenses = {};
            for (var tx in monthTransactions.where((tx) => !tx.isIncome)) {
              final category = tx.category.trim().isEmpty
                  ? 'Khác'
                  : tx.category;
              categoryExpenses.update(
                category,
                (value) => value + tx.amount,
                ifAbsent: () => tx.amount,
              );
            }
            final sortedCategoryExpenses = categoryExpenses.entries.toList()
              ..sort((a, b) => b.value.compareTo(a.value));

            // Group incomes by category
            final Map<String, double> categoryIncomes = {};
            for (var tx in monthTransactions.where((tx) => tx.isIncome)) {
              final category = tx.category.trim().isEmpty
                  ? 'Khác'
                  : tx.category;
              categoryIncomes.update(
                category,
                (value) => value + tx.amount,
                ifAbsent: () => tx.amount,
              );
            }
            final sortedCategoryIncomes = categoryIncomes.entries.toList()
              ..sort((a, b) => b.value.compareTo(a.value));

            return SingleChildScrollView(
              padding: EdgeInsets.only(
                left: AppConstants.defaultPadding,
                right: AppConstants.defaultPadding,
                top: AppConstants.defaultPadding,
                bottom:
                    AppConstants.defaultPadding +
                    80, // Extra padding for bottom nav
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Month selector
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          colorScheme.primary.withValues(alpha: 0.1),
                          colorScheme.secondary.withValues(alpha: 0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: colorScheme.primary.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.calendar_month,
                          color: colorScheme.primary,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        'Tháng ${Formatters.formatMonthYear(_selectedMonth)}',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      trailing: Icon(
                        Icons.keyboard_arrow_down,
                        color: colorScheme.primary,
                      ),
                      onTap: _selectMonth,
                    ),
                  ),

                  const SizedBox(height: AppConstants.defaultPadding),

                  // Summary cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildSummaryCard(
                          'Thu nhập',
                          monthIncome,
                          const Color(0xFF10B981), // Success green
                          Icons.trending_up,
                        ),
                      ),
                      const SizedBox(width: AppConstants.smallPadding),
                      Expanded(
                        child: _buildSummaryCard(
                          'Chi tiêu',
                          monthExpense,
                          const Color(0xFFEF4444), // Error red
                          Icons.trending_down,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppConstants.defaultPadding),

                  _buildSummaryCard(
                    'Số dư',
                    monthIncome - monthExpense,
                    const Color(0xFF3B82F6), // Primary blue
                    Icons.account_balance,
                  ),

                  const SizedBox(height: AppConstants.defaultPadding),

                  // Pie Chart Section
                  Text(
                    'Phân tích thu chi',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),

                  const SizedBox(height: AppConstants.defaultPadding),

                  // Pie Chart Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(
                        AppConstants.defaultPadding,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            height: 160,
                            child: Row(
                              children: [
                                // Pie Chart
                                Expanded(
                                  flex: 5,
                                  child: _buildPieChart(
                                    monthIncome,
                                    monthExpense,
                                  ),
                                ),
                                const SizedBox(width: 20),
                                // Legend
                                Expanded(
                                  flex: 4,
                                  child: _buildChartLegend(
                                    monthIncome,
                                    monthExpense,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: AppConstants.defaultPadding),

                  // Expense categories breakdown
                  if (sortedCategoryExpenses.isNotEmpty)
                    _buildCategoryBreakdownSection(
                      context: context,
                      title: 'Danh mục chi tiêu',
                      categoryData: sortedCategoryExpenses,
                      totalAmount: monthExpense,
                      color: const Color(0xFFEF4444), // Error red
                    ),

                  // Income categories breakdown
                  if (sortedCategoryIncomes.isNotEmpty)
                    _buildCategoryBreakdownSection(
                      context: context,
                      title: 'Danh mục thu nhập',
                      categoryData: sortedCategoryIncomes,
                      totalAmount: monthIncome,
                      color: const Color(0xFF10B981), // Success green
                    ),

                  // Transaction count
                  Text(
                    'Thống kê giao dịch',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),

                  const SizedBox(height: AppConstants.defaultPadding),

                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(
                        AppConstants.defaultPadding,
                      ),
                      child: Column(
                        children: [
                          _buildStatRow(
                            'Tổng số giao dịch',
                            '${monthTransactions.length}',
                          ),
                          const Divider(),
                          _buildStatRow(
                            'Giao dịch thu nhập',
                            '${monthTransactions.where((tx) => tx.isIncome).length}',
                          ),
                          const Divider(),
                          _buildStatRow(
                            'Giao dịch chi tiêu',
                            '${monthTransactions.where((tx) => !tx.isIncome).length}',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCategoryBreakdownSection({
    required BuildContext context,
    required String title,
    required List<MapEntry<String, double>> categoryData,
    required double totalAmount,
    required Color color,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: AppConstants.defaultPadding),
        Card(
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: categoryData.length,
            itemBuilder: (context, index) {
              final entry = categoryData[index];
              final percentage = totalAmount > 0
                  ? (entry.value / totalAmount)
                  : 0.0;
              return _buildCategoryItem(
                context,
                entry.key,
                entry.value,
                percentage,
                color,
              );
            },
            separatorBuilder: (context, index) => const Divider(height: 1),
          ),
        ),
        const SizedBox(height: AppConstants.largePadding),
      ],
    );
  }

  Widget _buildCategoryItem(
    BuildContext context,
    String category,
    double amount,
    double percentage,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
        vertical: AppConstants.smallPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                category,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              Text(
                Formatters.formatCurrency(amount),
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: percentage,
            backgroundColor: color.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    double amount,
    Color color,
    IconData icon,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.1), color.withValues(alpha: 0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: AppConstants.smallPadding),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: AppConstants.captionFontSize,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              Formatters.formatCurrency(amount),
              style: GoogleFonts.inter(
                fontSize: AppConstants.bodyFontSize,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildPieChart(double income, double expense) {
    final total = income - expense;
    if (total == 0) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pie_chart_outline,
              size: 80,
              color: Colors.grey.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 8),
            Text(
              'Không có dữ liệu',
              style: TextStyle(
                color: Colors.grey.withValues(alpha: 0.7),
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    final incomePercentage = income / total;
    final expensePercentage = expense / total;

    return CustomPaint(
      painter: PieChartPainter(
        incomePercentage: incomePercentage,
        expensePercentage: expensePercentage,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Tổng',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              Formatters.formatCurrency(total),
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartLegend(double income, double expense) {
    final total = income + expense;
    final incomePercentage = total > 0
        ? (income / total * 100).toDouble()
        : 0.0;
    final expensePercentage = total > 0
        ? (expense / total * 100).toDouble()
        : 0.0;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildLegendItem(
          'Thu nhập',
          const Color(0xFF10B981), // Success green
          incomePercentage,
          Formatters.formatCurrency(income),
        ),
        const SizedBox(height: 6),
        _buildLegendItem(
          'Chi tiêu',
          const Color(0xFFEF4444), // Error red
          expensePercentage,
          Formatters.formatCurrency(expense),
        ),
      ],
    );
  }

  Widget _buildLegendItem(
    String label,
    Color color,
    double percentage,
    String amount,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 1),
                Wrap(
                  children: [
                    Text(
                      '${percentage.toStringAsFixed(1)}%',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        amount,
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PieChartPainter extends CustomPainter {
  final double incomePercentage;
  final double expensePercentage;

  PieChartPainter({
    required this.incomePercentage,
    required this.expensePercentage,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    // Calculate radius more conservatively to prevent overflow
    final availableRadius =
        (size.width < size.height ? size.width : size.height) / 2;
    final radius = availableRadius - 30; // Increased margin for better spacing

    // Income arc
    final incomePaint = Paint()
      ..color =
          const Color(0xFF10B981) // Success green
      ..style = PaintingStyle.fill;

    final incomeSweepAngle = incomePercentage * 2 * 3.14159;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.14159 / 2, // Start from top
      incomeSweepAngle,
      true,
      incomePaint,
    );

    // Expense arc
    final expensePaint = Paint()
      ..color =
          const Color(0xFFEF4444) // Error red
      ..style = PaintingStyle.fill;

    final expenseSweepAngle = expensePercentage * 2 * 3.14159;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.14159 / 2 + incomeSweepAngle,
      expenseSweepAngle,
      true,
      expensePaint,
    );

    // Center circle
    final centerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius * 0.6, centerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is PieChartPainter &&
        (oldDelegate.incomePercentage != incomePercentage ||
            oldDelegate.expensePercentage != expensePercentage);
  }
}
