import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/currency_formatter.dart';
import '../core/utils/date_formatter.dart';
import '../models/category_item.dart';
import '../models/parsed_receipt.dart';
import '../models/transaction_item.dart';
import '../providers/expense_provider.dart';

class ReceiptReviewScreen extends StatefulWidget {
  final ParsedReceipt parsedReceipt;
  final String? imagePath;

  const ReceiptReviewScreen({
    super.key,
    required this.parsedReceipt,
    this.imagePath,
  });

  @override
  State<ReceiptReviewScreen> createState() => _ReceiptReviewScreenState();
}

class _ReceiptReviewScreenState extends State<ReceiptReviewScreen> {
  late TextEditingController _titleController;
  late TextEditingController _amountController;
  late TextEditingController _noteController;
  late DateTime _selectedDate;
  late String _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    final p = widget.parsedReceipt;

    _titleController = TextEditingController(text: p.merchant ?? 'Chi tiêu hóa đơn');
    _amountController = TextEditingController(
      text: p.totalAmount != null ? p.totalAmount!.toStringAsFixed(0) : '',
    );
    _noteController = TextEditingController(
      text: 'Quét tự động từ hóa đơn ${p.merchant ?? ''}',
    );
    _selectedDate = p.date ?? DateTime.now();
    _selectedCategoryId = p.suggestedCategoryId ?? 'food';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      locale: const Locale('vi', 'VN'),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _selectedDate.hour,
          _selectedDate.minute,
        );
      });
    }
  }

  void _saveTransaction() {
    final title = _titleController.text.trim();
    final amount = CurrencyFormatter.parseAmount(_amountController.text.trim());

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập tên điểm bán hoặc nội dung chi tiêu')),
      );
      return;
    }

    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng kiểm tra lại số tiền hợp lệ')),
      );
      return;
    }

    final category = CategoryItem.findById(_selectedCategoryId);

    final item = TransactionItem(
      title: title,
      amount: amount,
      isExpense: true,
      categoryId: _selectedCategoryId,
      categoryName: category.name,
      dateTime: _selectedDate,
      note: _noteController.text.trim(),
      merchant: widget.parsedReceipt.merchant,
      rawOcrText: widget.parsedReceipt.rawText,
      receiptImagePath: widget.imagePath,
    );

    context.read<ExpenseProvider>().addTransaction(item);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppTheme.incomeGreen,
        content: Text('Đã lưu giao dịch: ${CurrencyFormatter.formatVnd(amount)}'),
      ),
    );

    // Quay về màn hình chính
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final confidencePercent = (widget.parsedReceipt.confidenceScore * 100).toInt();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kiểm tra hóa đơn'),
        actions: [
          TextButton(
            onPressed: _saveTransaction,
            child: const Text(
              'Lưu',
              style: TextStyle(
                color: AppTheme.primaryBlue,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Thẻ trạng thái nhận diện AI
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: confidencePercent >= 40
                    ? AppTheme.primaryBlueLight
                    : const Color(0xFFFFF7ED),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: confidencePercent >= 40
                      ? AppTheme.primaryBlue.withOpacity(0.3)
                      : Colors.orange.withOpacity(0.4),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    confidencePercent >= 40 ? Icons.auto_awesome : Icons.info_outline,
                    color: confidencePercent >= 40 ? AppTheme.primaryBlue : Colors.orange,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          confidencePercent >= 40
                              ? 'Đã bóc tách thành công (On-device OCR)'
                              : 'Chưa nhận diện rõ chữ từ ảnh này',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: confidencePercent >= 40
                                ? AppTheme.primaryBlueDark
                                : const Color(0xFFC2410C),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          confidencePercent >= 40
                              ? 'Độ tin cậy trích xuất: $confidencePercent% • Dữ liệu xử lý offline'
                              : 'Vui lòng kiểm tra và điền số tiền/điểm bán bên dưới, hoặc chọn mẫu WinMart có sẵn để kiểm thử parser!',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Nhập số tiền nổi bật (MISA style)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Số tiền thanh toán (VND)',
                    style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Text(
                        '₫',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.expenseRed,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.expenseRed,
                          ),
                          decoration: const InputDecoration(
                            hintText: '0',
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Thẻ chi tiết form
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.border),
              ),
              child: Column(
                children: [
                  // Tên điểm bán / Cửa hàng
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Tên cửa hàng / Điểm bán',
                      prefixIcon: Icon(Icons.storefront, color: AppTheme.primaryBlue),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Chọn danh mục
                  DropdownButtonFormField<String>(
                    value: _selectedCategoryId,
                    decoration: const InputDecoration(
                      labelText: 'Hạng mục chi tiêu',
                      prefixIcon: Icon(Icons.category, color: AppTheme.primaryBlue),
                    ),
                    items: CategoryItem.defaultExpenseCategories.map((cat) {
                      return DropdownMenuItem(
                        value: cat.id,
                        child: Row(
                          children: [
                            Icon(cat.icon, color: cat.color, size: 20),
                            const SizedBox(width: 8),
                            Text(cat.name),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedCategoryId = val);
                      }
                    },
                  ),
                  const SizedBox(height: 14),

                  // Ngày giao dịch
                  InkWell(
                    onTap: _selectDate,
                    borderRadius: BorderRadius.circular(12),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Ngày giao dịch',
                        prefixIcon: Icon(Icons.calendar_today, color: AppTheme.primaryBlue),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            DateFormatter.formatMisaDayHeader(_selectedDate),
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          const Icon(Icons.arrow_drop_down, color: AppTheme.textSecondary),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Ghi chú
                  TextField(
                    controller: _noteController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Ghi chú',
                      prefixIcon: Icon(Icons.edit_note, color: AppTheme.primaryBlue),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Xem trước văn bản OCR gốc
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.border),
              ),
              child: Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  title: const Text(
                    'Xem văn bản gốc OCR đã nhận diện',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  leading: const Icon(Icons.text_snippet_outlined, color: AppTheme.textSecondary),
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceMuted,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SelectableText(
                        widget.parsedReceipt.rawText.isNotEmpty
                            ? widget.parsedReceipt.rawText
                            : 'Không có dữ liệu text.',
                        style: const TextStyle(
                          fontSize: 12,
                          fontFamily: 'monospace',
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Nút Lưu giao dịch
            ElevatedButton(
              onPressed: _saveTransaction,
              child: const Text('Lưu vào sổ giao dịch'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Hủy / Quét lại',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
