import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/recurrence_frequency.dart';
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
  RecurrenceFrequency _frequency = RecurrenceFrequency.monthly;
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;

  bool get _isEditing => widget.recurring != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final r = widget.recurring!;
      _titleController.text = r.title;
      _amountController.text = r.amount.toString();
      _categoryController.text = r.category;
      _isIncome = r.isIncome;
      _frequency = r.frequency;
      _startDate = r.startDate;
      _endDate = r.endDate;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(bool isStartDate) async {
    final initial = isStartDate ? _startDate : (_endDate ?? DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
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
      frequency: _frequency,
      startDate: _startDate,
      endDate: _endDate,
      // lastGeneratedDate is handled by the provider
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
      appBar: AppBar(title: Text(_isEditing ? 'Sửa Định kỳ' : 'Tạo Định kỳ')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Tên giao dịch',
                hintText: 'Ví dụ: Tiền thuê nhà',
                prefixIcon: Icon(Icons.title),
              ),
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? 'Vui lòng nhập tên'
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
                hintText: 'Ví dụ: Nhà ở',
                prefixIcon: Icon(Icons.category),
              ),
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? 'Vui lòng nhập danh mục'
                  : null,
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            DropdownButtonFormField<RecurrenceFrequency>(
              initialValue: _frequency,
              decoration: const InputDecoration(
                labelText: 'Tần suất',
                prefixIcon: Icon(Icons.repeat),
              ),
              items: RecurrenceFrequency.values.map((freq) {
                return DropdownMenuItem(
                  value: freq,
                  child: Text(freq.displayName),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _frequency = value;
                  });
                }
              },
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(true),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Ngày bắt đầu',
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(Formatters.formatDate(_startDate)),
                    ),
                  ),
                ),
                const SizedBox(width: AppConstants.smallPadding),
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(false),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Ngày kết thúc (tùy chọn)',
                        prefixIcon: const Icon(Icons.calendar_today),
                        suffixIcon: _endDate != null
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () =>
                                    setState(() => _endDate = null),
                              )
                            : null,
                      ),
                      child: Text(
                        _endDate != null
                            ? Formatters.formatDate(_endDate!)
                            : 'Không có',
                      ),
                    ),
                  ),
                ),
              ],
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
              label: Text(_isEditing ? 'Cập nhật' : 'Lưu'),
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
