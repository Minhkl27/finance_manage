import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/transaction.dart';
import '../../data/models/transaction_template.dart';
import '../../data/providers/notification_provider.dart';
import '../../data/providers/budget_provider.dart';
import '../../data/providers/transaction_provider.dart';
import '../../core/constants/app_constants.dart';

class AddTransactionScreen extends StatefulWidget {
  final Transaction? transaction; // For editing existing transaction
  final TransactionTemplate? template; // For creating from template

  const AddTransactionScreen({super.key, this.transaction, this.template})
    : assert(
        transaction == null || template == null,
        'Cannot provide both a transaction and a template.',
      );

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _otherCategoryController = TextEditingController();
  bool _isIncome = false;
  DateTime _selectedDate = DateTime.now();
  String? _currentCategorySelection;

  static const List<String> _defaultCategories = [
    'Ăn uống',
    'Đi lại',
    'Mua sắm',
    'Xăng xe',
    'Lương',
  ];

  bool get _isEditing => widget.transaction != null;
  bool get _isFromTemplate => widget.template != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _titleController.text = widget.transaction!.title;
      _amountController.text = widget.transaction!.amount.toString();
      _isIncome = widget.transaction!.isIncome;
      _selectedDate = widget.transaction!.date;
      final category = widget.transaction!.category;
      if (_defaultCategories.contains(category) || category == 'Khác') {
        _currentCategorySelection = category;
      } else if (category.isNotEmpty) {
        _currentCategorySelection = 'Khác';
        _otherCategoryController.text = category;
      }
    } else if (_isFromTemplate) {
      _titleController.text = widget.template!.title;
      _amountController.text = widget.template!.amount.toString();
      _isIncome = widget.template!.isIncome;
      final category = widget.template!.category;
      // For simplicity, we'll treat template categories as 'Other' for now
      _currentCategorySelection = 'Khác';
      _otherCategoryController.text = category;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _otherCategoryController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveTransaction() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    _formKey.currentState!.save(); // Save the form fields

    final title = _titleController.text.trim();
    final amount = double.tryParse(_amountController.text);
    String category = _currentCategorySelection ?? '';
    if (_currentCategorySelection == 'Khác') {
      category = _otherCategoryController.text.trim();
    }

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập số tiền hợp lệ!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (category.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn hoặc nhập danh mục!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final transaction = Transaction(
      id: _isEditing ? widget.transaction!.id : DateTime.now().toString(),
      title: title,
      amount: amount,
      date: _selectedDate,
      isIncome: _isIncome,
      category: category,
      notes: '',
    );

    final transactionProvider = context.read<TransactionProvider>();
    final notificationProvider = context.read<NotificationProvider>();
    final budgetProvider = context.read<BudgetProvider>();
    // Capture Navigator and ScaffoldMessenger before the async gap.
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final isEditing = _isEditing; // Also capture boolean value

    if (isEditing) {
      final oldTransaction = widget.transaction;
      await transactionProvider.updateTransaction(
        widget.transaction!.id,
        transaction,
        notificationProvider,
      );
      // Kiểm tra ngân sách sau khi cập nhật
      await transactionProvider.checkBudgetsAndNotify(
        budgetProvider,
        notificationProvider,
        oldTransaction: oldTransaction,
        newTransaction: transaction,
      );
    } else {
      await transactionProvider.addTransaction(
        transaction,
        fromRecurring: false,
        notificationProvider: notificationProvider,
      );
      // Kiểm tra ngân sách sau khi thêm
      await transactionProvider.checkBudgetsAndNotify(
        budgetProvider,
        notificationProvider,
        newTransaction: transaction,
      );
    }

    navigator.pop();
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text(
          isEditing ? 'Giao dịch đã được cập nhật!' : 'Giao dịch đã được thêm!',
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Sửa giao dịch' : 'Thêm giao dịch',
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
            child: TextButton(
              onPressed: _saveTransaction,
              child: Text(
                _isEditing ? 'Cập nhật' : 'Lưu',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title field
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Mô tả giao dịch',
                  hintText: 'Ví dụ: Mua sắm, Lương tháng...',
                  prefixIcon: Icon(Icons.description),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập mô tả giao dịch';
                  }
                  return null;
                },
              ),

              const SizedBox(height: AppConstants.defaultPadding),

              // Amount field
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Số tiền',
                  hintText: '0',
                  prefixIcon: Icon(Icons.attach_money),
                  suffixText: AppConstants.currency,
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập số tiền';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Vui lòng nhập số tiền hợp lệ';
                  }
                  return null;
                },
              ),

              const SizedBox(height: AppConstants.defaultPadding),

              // Category dropdown
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
                    hintText: 'Ví dụ: Giải trí, Học phí...',
                    prefixIcon: Icon(Icons.edit),
                  ),
                  validator: (value) {
                    if (_currentCategorySelection == 'Khác') {
                      if (value == null || value.trim().isEmpty) {
                        return 'Vui lòng nhập tên danh mục';
                      }
                    }
                    return null;
                  },
                ),
              ],

              const SizedBox(height: AppConstants.defaultPadding),

              // Date picker
              InkWell(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Ngày giao dịch',
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                  ),
                ),
              ),

              const SizedBox(height: AppConstants.largePadding),

              // Transaction type selector
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
                    icon: Icon(
                      Icons.add_circle,
                      color: AppConstants.incomeColor,
                    ),
                  ),
                ],
                selected: {_isIncome},
                onSelectionChanged: (Set<bool> selection) {
                  setState(() {
                    _isIncome = selection.first;
                  });
                },
              ),

              const Spacer(),

              // Save button
              ElevatedButton(
                onPressed: _saveTransaction,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppConstants.defaultPadding,
                  ),
                ),
                child: Text(
                  _isEditing ? 'Cập nhật giao dịch' : 'Thêm giao dịch',
                  style: const TextStyle(fontSize: AppConstants.bodyFontSize),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
