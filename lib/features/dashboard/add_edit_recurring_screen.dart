import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../data/models/recurring_transaction.dart';
import '../../data/providers/recurring_transaction_provider.dart';

class AddEditRecurringScreen extends StatefulWidget {
  final RecurringTransaction? recurring;

  const AddEditRecurringScreen({super.key, this.recurring});

  @override
  State<AddEditRecurringScreen> createState() => _AddEditRecurringScreenState();
}

class _AddEditRecurringScreenState extends State<AddEditRecurringScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _categoryController = TextEditingController();
  bool _isIncome = false;
  int _dayOfMonth = DateTime.now().day;

  bool get _isEditing => widget.recurring != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _titleController.text = widget.recurring!.title;
      _amountController.text = widget.recurring!.amount.toStringAsFixed(0);
      _categoryController.text = widget.recurring!.category;
      _isIncome = widget.recurring!.isIncome;
      _dayOfMonth = widget.recurring!.dayOfMonth;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  void _saveRecurring() {
    if (!_formKey.currentState!.validate()) return;

    final title = _titleController.text.trim();
    final amount = double.tryParse(_amountController.text);
    final category = _categoryController.text.trim();

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập số tiền hợp lệ'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final newRecurring = RecurringTransaction(
      id: _isEditing ? widget.recurring!.id : DateTime.now().toString(),
      title: title,
      amount: amount,
      category: category,
      isIncome: _isIncome,
      dayOfMonth: _dayOfMonth,
      lastGeneratedDate: _isEditing
          ? widget.recurring!.lastGeneratedDate
          : null,
    );

    final provider = context.read<RecurringTransactionProvider>();
    if (_isEditing) {
      provider.updateRecurring(widget.recurring!.id, newRecurring);
    } else {
      provider.addRecurring(newRecurring);
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Sửa Giao dịch định kỳ' : 'Tạo Giao dịch định kỳ',
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
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Tên giao dịch',
                hintText: 'Ví dụ: Tiền nhà, Lương tháng',
                prefixIcon: Icon(Icons.title),
              ),
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? 'Vui lòng nhập tên giao dịch'
                  : null,
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Số tiền',
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
            TextFormField(
              controller: _categoryController,
              decoration: const InputDecoration(
                labelText: 'Danh mục',
                hintText: 'Ví dụ: Nhà ở, Lương',
                prefixIcon: Icon(Icons.category),
              ),
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? 'Vui lòng nhập danh mục'
                  : null,
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            DropdownButtonFormField<int>(
              initialValue: _dayOfMonth,
              decoration: const InputDecoration(
                labelText: 'Ngày lặp lại hàng tháng',
                prefixIcon: Icon(Icons.calendar_today),
              ),
              items: List.generate(31, (index) => index + 1)
                  .map(
                    (day) =>
                        DropdownMenuItem(value: day, child: Text('Ngày $day')),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _dayOfMonth = value;
                  });
                }
              },
            ),
            const SizedBox(height: AppConstants.largePadding),
            const Text(
              'Loại giao dịch',
              style: TextStyle(
                fontSize: AppConstants.bodyFontSize,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: AppConstants.smallPadding),
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(
                  value: false,
                  label: Text('Chi tiêu'),
                  icon: Icon(
                    Icons.remove_circle,
                    color: AppConstants.expenseColor,
                  ),
                ),
                ButtonSegment(
                  value: true,
                  label: Text('Thu nhập'),
                  icon: Icon(Icons.add_circle, color: AppConstants.incomeColor),
                ),
              ],
              selected: {_isIncome},
              onSelectionChanged: (Set<bool> selection) {
                setState(() {
                  _isIncome = selection.first;
                });
              },
            ),
            const SizedBox(height: AppConstants.largePadding * 2),
            ElevatedButton.icon(
              onPressed: _saveRecurring,
              icon: Icon(_isEditing ? Icons.save_as : Icons.add_task),
              label: Text(_isEditing ? 'Cập nhật' : 'Tạo mới'),
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
