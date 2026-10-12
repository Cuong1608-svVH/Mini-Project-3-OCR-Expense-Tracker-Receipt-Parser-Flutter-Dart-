import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/currency_formatter.dart';
import '../providers/expense_provider.dart';
import '../services/csv_export_service.dart';

class CsvExportScreen extends StatefulWidget {
  const CsvExportScreen({super.key});

  @override
  State<CsvExportScreen> createState() => _CsvExportScreenState();
}

class _CsvExportScreenState extends State<CsvExportScreen> {
  String _selectedScope = 'current_month'; // 'current_month', 'last_month', 'all'
  bool _isExporting = false;
  CsvExportResult? _lastResult;

  Future<void> _handleExport() async {
    setState(() {
      _isExporting = true;
      _lastResult = null;
    });

    final provider = context.read<ExpenseProvider>();
    final result = await provider.exportTransactions(scope: _selectedScope);

    if (!mounted) return;
    setState(() {
      _isExporting = false;
      _lastResult = result;
    });

    if (result.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppTheme.incomeGreen,
          content: Text('Đã xuất thành công ${result.recordCount} giao dịch ra file CSV!'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppTheme.expenseRed,
          content: Text('Lỗi khi xuất file: ${result.errorMessage}'),
        ),
      );
    }
  }

  void _shareFile() {
    if (_lastResult != null && _lastResult!.isSuccess) {
      CsvExportService.shareCsvFile(_lastResult!.filePath);
    }
  }

  void _copyPath() {
    if (_lastResult != null && _lastResult!.isSuccess) {
      Clipboard.setData(ClipboardData(text: _lastResult!.filePath));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã sao chép đường dẫn file vào bộ nhớ tạm')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseProvider>();

    // Tính toán số lượng bản ghi tương ứng
    int targetCount = 0;
    double targetExpense = 0;
    double targetIncome = 0;

    final now = DateTime.now();
    for (final tx in provider.allTransactions) {
      bool match = false;
      if (_selectedScope == 'current_month') {
        match = tx.dateTime.year == now.year && tx.dateTime.month == now.month;
      } else if (_selectedScope == 'last_month') {
        final lastMonth = DateTime(now.year, now.month - 1);
        match = tx.dateTime.year == lastMonth.year && tx.dateTime.month == lastMonth.month;
      } else {
        match = true;
      }

      if (match) {
        targetCount++;
        if (tx.isExpense) {
          targetExpense += tx.amount;
        } else {
          targetIncome += tx.amount;
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Xuất dữ liệu CSV'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Banner tính năng
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlueLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.2)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.table_chart, color: AppTheme.primaryBlue, size: 36),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Xuất file Excel & CSV chuẩn',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: AppTheme.primaryBlueDark,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'File được gắn chuẩn UTF-8 BOM, đảm bảo mở trực tiếp trên Microsoft Excel tiếng Việt không bị lỗi font.',
                          style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Chọn khoảng thời gian
            const Text(
              'Chọn phạm vi giao dịch cần xuất',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 10),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.border),
              ),
              child: Column(
                children: [
                  RadioListTile<String>(
                    value: 'current_month',
                    groupValue: _selectedScope,
                    activeColor: AppTheme.primaryBlue,
                    title: const Text('Tháng này (Hiện tại)'),
                    subtitle: Text('Tháng ${now.month}/${now.year}'),
                    onChanged: (val) => setState(() => _selectedScope = val!),
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  RadioListTile<String>(
                    value: 'last_month',
                    groupValue: _selectedScope,
                    activeColor: AppTheme.primaryBlue,
                    title: const Text('Tháng trước'),
                    subtitle: Text('Tháng ${now.month == 1 ? 12 : now.month - 1}/${now.month == 1 ? now.year - 1 : now.year}'),
                    onChanged: (val) => setState(() => _selectedScope = val!),
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  RadioListTile<String>(
                    value: 'all',
                    groupValue: _selectedScope,
                    activeColor: AppTheme.primaryBlue,
                    title: const Text('Tất cả lịch sử'),
                    subtitle: const Text('Toàn bộ các giao dịch đã ghi nhận'),
                    onChanged: (val) => setState(() => _selectedScope = val!),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Tóm tắt dữ liệu sẽ xuất
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.border),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Tổng số bản ghi:',
                        style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                      ),
                      Text(
                        '$targetCount dòng',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Tổng chi tiêu:',
                        style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                      ),
                      Text(
                        '-${CurrencyFormatter.formatVnd(targetExpense)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.expenseRed,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Tổng thu nhập:',
                        style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                      ),
                      Text(
                        '+${CurrencyFormatter.formatVnd(targetIncome)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.incomeGreen,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Nút Xuất file
            ElevatedButton.icon(
              onPressed: _isExporting ? null : _handleExport,
              icon: _isExporting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Icon(Icons.download),
              label: Text(_isExporting ? 'Đang tạo file...' : 'Xuất dữ liệu ra file CSV'),
            ),
            const SizedBox(height: 20),

            // Hiển thị kết quả xuất thành công
            if (_lastResult != null && _lastResult!.isSuccess)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.incomeGreenLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.incomeGreen.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.check_circle, color: AppTheme.incomeGreen, size: 22),
                        SizedBox(width: 8),
                        Text(
                          'Xuất file thành công!',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.incomeGreen,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Đường dẫn file: ${_lastResult!.filePath}',
                      style: const TextStyle(fontSize: 11, color: AppTheme.textPrimary),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppTheme.incomeGreen),
                            ),
                            onPressed: _copyPath,
                            icon: const Icon(Icons.copy, size: 16, color: AppTheme.incomeGreen),
                            label: const Text(
                              'Sao chép link',
                              style: TextStyle(color: AppTheme.incomeGreen, fontSize: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.incomeGreen,
                            ),
                            onPressed: _shareFile,
                            icon: const Icon(Icons.share, size: 16),
                            label: const Text('Chia sẻ / Mở', style: TextStyle(fontSize: 12)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
