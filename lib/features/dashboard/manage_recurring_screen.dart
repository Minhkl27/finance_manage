import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/utils/formatters.dart';
import '../../data/providers/recurring_transaction_provider.dart';
import '../../widgets/empty_state.dart';
import 'add_edit_recurring_screen.dart';

class ManageRecurringScreen extends StatelessWidget {
  const ManageRecurringScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Giao dịch định kỳ',
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
      body: Consumer<RecurringTransactionProvider>(
        builder: (context, provider, child) {
          final recurring = provider.recurringTransactions;
          if (recurring.isEmpty) {
            return const EmptyState(
              icon: Icons.repeat_on_rounded,
              title: 'Chưa có giao dịch định kỳ',
              subtitle: 'Tự động hóa việc ghi chép các khoản thu chi cố định.',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 80, top: 8),
            itemCount: recurring.length,
            itemBuilder: (ctx, index) {
              final item = recurring[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: ListTile(
                  leading: Icon(
                    item.isIncome ? Icons.trending_up : Icons.trending_down,
                    color: item.isIncome ? Colors.green : Colors.red,
                  ),
                  title: Text(item.title),
                  subtitle: Text(
                    'Ngày ${item.dayOfMonth} hàng tháng - ${Formatters.formatCurrency(item.amount)}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (dCtx) => AlertDialog(
                          title: const Text('Xác nhận xóa'),
                          content: Text(
                            'Bạn có chắc muốn xóa "${item.title}"? Các giao dịch đã tạo sẽ không bị ảnh hưởng.',
                          ),
                          actions: [
                            TextButton(
                              child: const Text('Hủy'),
                              onPressed: () => Navigator.of(dCtx).pop(),
                            ),
                            TextButton(
                              child: const Text(
                                'Xóa',
                                style: TextStyle(color: Colors.red),
                              ),
                              onPressed: () {
                                provider.deleteRecurring(item.id);
                                Navigator.of(dCtx).pop();
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => AddEditRecurringScreen(recurring: item),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AddEditRecurringScreen()),
        ),
        label: const Text('Tạo mới'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
