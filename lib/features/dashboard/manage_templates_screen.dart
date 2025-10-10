import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../data/providers/template_provider.dart';
import '../../../../widgets/empty_state.dart';
import 'add_edit_template_screen.dart';

class ManageTemplatesScreen extends StatelessWidget {
  const ManageTemplatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Quản lý Mẫu',
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
      body: Consumer<TemplateProvider>(
        builder: (context, templateProvider, child) {
          final templates = templateProvider.templates;
          if (templates.isEmpty) {
            return const EmptyState(
              icon: Icons.copy_all_outlined,
              title: 'Chưa có mẫu nào',
              subtitle: 'Tạo mẫu để thêm giao dịch nhanh hơn.',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 80, top: 8),
            itemCount: templates.length,
            itemBuilder: (ctx, index) {
              final template = templates[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: ListTile(
                  leading: Icon(
                    template.isIncome ? Icons.trending_up : Icons.trending_down,
                    color: template.isIncome ? Colors.green : Colors.red,
                  ),
                  title: Text(template.title),
                  subtitle: Text(
                    '${template.category} - ${Formatters.formatCurrency(template.amount)}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () {
                      // Show confirmation dialog before deleting
                      showDialog(
                        context: context,
                        builder: (dCtx) => AlertDialog(
                          title: const Text('Xác nhận xóa'),
                          content: Text(
                            'Bạn có chắc muốn xóa mẫu "${template.title}"?',
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
                                templateProvider.deleteTemplate(template.id);
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
                      builder: (_) => AddEditTemplateScreen(template: template),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AddEditTemplateScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
