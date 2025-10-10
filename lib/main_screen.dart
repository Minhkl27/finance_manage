// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'data/providers/transaction_provider.dart';
import 'data/providers/template_provider.dart';
import 'data/providers/recurring_transaction_provider.dart';
import 'data/providers/budget_provider.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'package:provider/provider.dart';
import 'features/transactions/add_transaction_screen.dart';
import 'features/budget/add_edit_budget_screen.dart';
import 'features/reports/report_screen.dart';
import 'features/budget/budget_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/transactions/transaction_screen.dart';
import 'widgets/custom_bottom_nav_bar.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // Danh sách các màn hình tương ứng với các tab
  static const List<Widget> _widgetOptions = <Widget>[
    DashboardScreen(),
    TransactionScreen(),
    ReportScreen(),
    BudgetScreen(),
    SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadDataAndGenerateTransactions();
  }

  Future<void> _loadDataAndGenerateTransactions() async {
    // Ensure the widget is mounted before accessing context.
    if (!mounted) return;

    final transactionProvider = context.read<TransactionProvider>();
    final budgetProvider = context.read<BudgetProvider>();
    final templateProvider = context.read<TemplateProvider>();
    final recurringProvider = context.read<RecurringTransactionProvider>();

    await transactionProvider.loadTransactions();
    await budgetProvider.loadBudgets();
    await templateProvider.loadTemplates();
    await recurringProvider.loadRecurringTransactions();
    await recurringProvider.generateDueTransactions(transactionProvider);
  }

  @override
  Widget build(BuildContext context) {
    final transactionProvider = context.watch<TransactionProvider>();
    final budgetProvider = context.watch<BudgetProvider>();
    final hasTransactions = transactionProvider.transactions.isNotEmpty;
    final hasBudgets = budgetProvider.budgets.isNotEmpty;

    return Scaffold(
      // extendBody giúp nội dung hiển thị phía sau BottomNavBar,
      // tạo hiệu ứng đẹp mắt với thanh điều hướng được bo tròn.
      extendBody: true,
      body: IndexedStack(index: _selectedIndex, children: _widgetOptions),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
      floatingActionButton: _buildFloatingActionButton(
        hasTransactions: hasTransactions,
        hasBudgets: hasBudgets,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget? _buildFloatingActionButton({
    required bool hasTransactions,
    required bool hasBudgets,
  }) {
    Widget? fab;
    if (_selectedIndex == 1 && hasTransactions) {
      // Transaction Screen
      fab = FloatingActionButton(
        onPressed: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const AddTransactionScreen())),
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      );
    } else if (_selectedIndex == 3 && hasBudgets) {
      // Budget Screen
      fab = FloatingActionButton(
        onPressed: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const AddEditBudgetScreen())),
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      );
    }
    return fab;
  }
}
