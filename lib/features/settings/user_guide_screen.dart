import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UserGuideScreen extends StatelessWidget {
  const UserGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Hướng dẫn sử dụng',
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
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: const [
          _GuideSection(
            icon: Icons.dashboard_rounded,
            title: '1. Màn hình Tổng quan',
            content:
                'Đây là nơi bạn có cái nhìn tổng thể về tình hình tài chính của mình.\n\n'
                '• Hiển thị số dư hiện tại.\n'
                '• Thống kê tổng thu nhập và chi tiêu trong tháng.\n'
                '• Liệt kê 5 giao dịch gần đây nhất.',
          ),
          _GuideSection(
            icon: Icons.receipt_long_rounded,
            title: '2. Quản lý Giao dịch',
            content:
                'Ghi chép lại mọi khoản thu chi của bạn.\n\n'
                '• Nhấn vào nút (+) ở màn hình Giao dịch để thêm một giao dịch mới (thu nhập hoặc chi tiêu).\n'
                '• Nhấn vào một giao dịch để chỉnh sửa thông tin.\n'
                '• Trượt giao dịch sang trái để xóa.\n'
                '• Sử dụng bộ lọc để xem giao dịch theo tháng hoặc theo loại (thu/chi).',
          ),
          _GuideSection(
            icon: Icons.bar_chart_rounded,
            title: '3. Xem Báo cáo',
            content:
                'Phân tích tình hình tài chính của bạn theo từng tháng.\n\n'
                '• Xem biểu đồ tròn phân tích tỷ lệ thu nhập và chi tiêu.\n'
                '• Thống kê tổng thu, tổng chi và số dư của tháng được chọn.\n'
                '• Đếm số lượng giao dịch thu/chi trong tháng.',
          ),
          _GuideSection(
            icon: Icons.account_balance_wallet_rounded,
            title: '4. Thiết lập Ngân sách',
            content:
                'Đặt ra giới hạn chi tiêu cho từng danh mục để quản lý tài chính hiệu quả hơn.\n\n'
                '• Nhấn vào nút (+) ở màn hình Ngân sách để tạo một ngân sách mới cho một danh mục cụ thể trong tháng.\n'
                '• Ứng dụng sẽ theo dõi chi tiêu của bạn so với ngân sách đã đặt và hiển thị tiến độ.',
          ),
          _GuideSection(
            icon: Icons.settings_rounded,
            title: '5. Cài đặt',
            content:
                'Tùy chỉnh và quản lý dữ liệu ứng dụng.\n\n'
                '• Xem thông tin về ứng dụng.\n'
                '• Xóa tất cả dữ liệu (giao dịch và ngân sách). Lưu ý: Hành động này không thể hoàn tác.',
          ),
        ],
      ),
    );
  }
}

class _GuideSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;

  const _GuideSection({
    required this.icon,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(
          title,
          style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              content,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
