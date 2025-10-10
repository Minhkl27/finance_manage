import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/budget.dart';
import '../../data/providers/budget_provider.dart';

class AddEditBudgetScreen extends StatefulWidget {
  final Budget? budget;

  const AddEditBudgetScreen({super.key, this.budget});

  @override
  State<AddEditBudgetScreen> createState() => _AddEditBudgetScreenState();
}

class _AddEditBudgetScreenState extends State<AddEditBudgetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otherCategoryController = TextEditingController();
  final _amountController = TextEditingController();
  String? _currentCategorySelection;
  DateTime _selectedMonth = DateTime.now();

  static const List<String> _defaultCategories = [
    'Ăn uống',
    'Đi lại',
    'Mua sắm',
    'Xăng xe',
  ];

  bool get _isEditing => widget.budget != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final category = widget.budget!.category;
      if (_defaultCategories.contains(category)) {
        _currentCategorySelection = category;
      } else if (category.isNotEmpty) {
        _currentCategorySelection = 'Khác';
        _otherCategoryController.text = category;
      }
      _amountController.text = widget.budget!.amount.toStringAsFixed(0);
      _selectedMonth = widget.budget!.month;
    }
  }

  @override
  void dispose() {
    _otherCategoryController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _selectMonth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDatePickerMode: DatePickerMode.year,
    );
    if (picked != null) {
      setState(() {
        _selectedMonth = DateTime(picked.year, picked.month);
      });
    }
  }

  void _saveBudget() {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();
    String category = _currentCategorySelection ?? '';
    if (_currentCategorySelection == 'Khác') {
      category = _otherCategoryController.text.trim();
    }

    final amount = double.tryParse(_amountController.text);

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập số tiền hợp lệ'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (category.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn hoặc nhập danh mục'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final budget = Budget(
      id: _isEditing ? widget.budget!.id : DateTime.now().toString(),
      category: category,
      amount: amount,
      month: _selectedMonth,
    );

    final provider = context.read<BudgetProvider>();
    if (_isEditing) {
      provider.updateBudget(widget.budget!.id, budget);
    } else {
      provider.addBudget(budget);
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Sửa ngân sách' : 'Tạo ngân sách',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6366F1), Color(0xFF3B82F6), Color(0xFF10B981)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          children: [
            DropdownButtonFormField<String>(
              initialValue: _currentCategorySelection,
              decoration: const InputDecoration(
                labelText: 'Danh mục',
                prefixIcon: Icon(Icons.category_outlined),
              ),
              hint: const Text('Chọn danh mục'),
              items: [
                ..._defaultCategories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }),
                const DropdownMenuItem<String>(
                  value: 'Khác',
                  child: Text('Khác (tự nhập)'),
                ),
              ],
              onChanged: (String? newValue) {
                setState(() {
                  _currentCategorySelection = newValue;
                });
              },
              validator: (value) =>
                  value == null ? 'Vui lòng chọn danh mục' : null,
            ),
            if (_currentCategorySelection == 'Khác') ...[
              const SizedBox(height: AppConstants.defaultPadding),
              TextFormField(
                controller: _otherCategoryController,
                decoration: const InputDecoration(
                  labelText: 'Tên danh mục khác',
                  hintText: 'Ví dụ: Giải trí, Du lịch...',
                  prefixIcon: Icon(Icons.edit),
                ),
                validator: (value) {
                  if (_currentCategorySelection == 'Khác' &&
                      (value == null || value.trim().isEmpty)) {
                    return 'Vui lòng nhập tên danh mục';
                  }
                  return null;
                },
              ),
            ],
            const SizedBox(height: AppConstants.defaultPadding),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Số tiền ngân sách',
                prefixIcon: Icon(Icons.attach_money),
                suffixText: AppConstants.currency,
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập số tiền';
                }
                if (double.tryParse(value) == null ||
                    double.parse(value) <= 0) {
                  return 'Vui lòng nhập số tiền hợp lệ';
                }
                return null;
              },
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            InkWell(
              onTap: _selectMonth,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Tháng áp dụng',
                  prefixIcon: Icon(Icons.calendar_month),
                ),
                child: Text(Formatters.formatMonthYear(_selectedMonth)),
              ),
            ),
            const SizedBox(height: AppConstants.largePadding * 2),
            ElevatedButton.icon(
              onPressed: _saveBudget,
              icon: Icon(_isEditing ? Icons.save_as : Icons.add_task),
              label: Text(_isEditing ? 'Cập nhật ngân sách' : 'Tạo ngân sách'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: AppConstants.defaultPadding,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
