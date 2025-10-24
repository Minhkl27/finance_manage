import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../data/models/transaction_template.dart';
import '../../../../data/providers/template_provider.dart';

class AddEditTemplateScreen extends StatefulWidget {
  final TransactionTemplate? template;

  const AddEditTemplateScreen({super.key, this.template});

  @override
  State<AddEditTemplateScreen> createState() => _AddEditTemplateScreenState();
}

class _AddEditTemplateScreenState extends State<AddEditTemplateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _otherCategoryController = TextEditingController();
  String? _currentCategorySelection;
  bool _isIncome = false;

  bool get _isEditing => widget.template != null;

  static const List<String> _defaultCategories = [
    'Ăn uống',
    'Đi lại',
    'Mua sắm',
    'Xăng xe',
    'Lương',
    'Hóa đơn',
  ];

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _titleController.text = widget.template!.title;
      _amountController.text = widget.template!.amount.toStringAsFixed(0);
      final category = widget.template!.category;
      if (_defaultCategories.contains(category)) {
        _currentCategorySelection = category;
      } else if (category.isNotEmpty) {
        _currentCategorySelection = 'Khác';
        _otherCategoryController.text = category;
      }
      _isIncome = widget.template!.isIncome;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _otherCategoryController.dispose();
    super.dispose();
  }

  void _saveTemplate() {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();
    final title = _titleController.text.trim();
    final amount = double.tryParse(_amountController.text);
    String category = _currentCategorySelection ?? '';
    if (_currentCategorySelection == 'Khác') {
      category = _otherCategoryController.text.trim();
    }

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

    final newTemplate = TransactionTemplate(
      id: _isEditing ? widget.template!.id : DateTime.now().toString(),
      title: title,
      amount: amount,
      category: category,
      isIncome: _isIncome,
    );

    final provider = context.read<TemplateProvider>();
    if (_isEditing) {
      provider.updateTemplate(widget.template!.id, newTemplate);
    } else {
      provider.addTemplate(newTemplate);
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Sửa Mẫu' : 'Tạo Mẫu Mới')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Tên mẫu',
                hintText: 'Ví dụ: Cà phê sáng',
                prefixIcon: Icon(Icons.title),
              ),
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? 'Vui lòng nhập tên mẫu'
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
                  hintText: 'Ví dụ: Du lịch, Học phí...',
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
              onPressed: _saveTemplate,
              icon: Icon(_isEditing ? Icons.save_as : Icons.add_task),
              label: Text(_isEditing ? 'Cập nhật Mẫu' : 'Tạo Mẫu'),
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
