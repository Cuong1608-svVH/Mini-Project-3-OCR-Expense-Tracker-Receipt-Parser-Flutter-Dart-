import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../providers/expense_provider.dart';
import 'csv_export_screen.dart';
import 'ocr_scanner_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tiện ích & Cài đặt'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Thẻ hồ sơ phong cách MISA
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primaryBlue, AppTheme.accentBlue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white24,
                  child: Icon(Icons.person, size: 32, color: Colors.white),
                ),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sổ Thu Chi MISA Clone',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'OCR Expense Tracker • Offline AI',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          const Text(
            'Tính năng mở rộng',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 10),

          // Nút Mở màn hình Xuất CSV
          Card(
            child: ListTile(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CsvExportScreen()),
                );
              },
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.incomeGreenLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.file_download, color: AppTheme.incomeGreen),
              ),
              title: const Text(
                'Xuất dữ liệu ra file CSV',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              subtitle: const Text(
                'Hỗ trợ UTF-8 BOM tiếng Việt, lọc theo tháng hoặc tất cả',
                style: TextStyle(fontSize: 12),
              ),
              trailing: const Icon(Icons.chevron_right, color: AppTheme.textMuted),
            ),
          ),
          const SizedBox(height: 8),

          // Nút Quét OCR
          Card(
            child: ListTile(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const OcrScannerScreen()),
                );
              },
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlueLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.document_scanner, color: AppTheme.primaryBlue),
              ),
              title: const Text(
                'Quét hóa đơn AI Offline',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              subtitle: const Text(
                'Bóc tách tự động điểm bán, tổng tiền và ngày giờ',
                style: TextStyle(fontSize: 12),
              ),
              trailing: const Icon(Icons.chevron_right, color: AppTheme.textMuted),
            ),
          ),
          const SizedBox(height: 20),

          const Text(
            'Quản trị dữ liệu & Hệ thống',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 10),

          // Thẻ nạp lại dữ liệu
          Card(
            child: ListTile(
              onTap: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Tải lại dữ liệu'),
                    content: const Text('Tải lại danh sách giao dịch từ cơ sở dữ liệu SQLite offline?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Hủy'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Đồng ý'),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  if (!context.mounted) return;
                  await context.read<ExpenseProvider>().loadTransactions();
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã làm mới dữ liệu từ SQLite!')),
                  );
                }
              },
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.refresh, color: AppTheme.primaryBlue),
              ),
              title: const Text(
                'Làm mới dữ liệu từ SQLite',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              subtitle: const Text('Đồng bộ trạng thái bảng cơ sở dữ liệu', style: TextStyle(fontSize: 12)),
            ),
          ),
          const SizedBox(height: 16),

          // Card thông tin công nghệ
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.border),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Thông tin kiến trúc ứng dụng',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                SizedBox(height: 10),
                Text('• On-device OCR: Google ML Kit Text Recognition (Offline)', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                SizedBox(height: 4),
                Text('• Heuristic Engine: Regex Parser bóc tách VND, cửa hàng, ngày giờ', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                SizedBox(height: 4),
                Text('• CustomPainter: Animated Pie & Bar charts tương tác cảm ứng', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                SizedBox(height: 4),
                Text('• Local Storage: SQLite (sqflite / sqflite_common_ffi)', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                SizedBox(height: 4),
                Text('• Export: CSV chuẩn UTF-8 BOM tương thích Excel', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
