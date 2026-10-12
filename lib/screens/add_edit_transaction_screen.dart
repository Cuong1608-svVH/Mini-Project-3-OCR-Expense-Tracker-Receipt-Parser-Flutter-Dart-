import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/currency_formatter.dart';
import '../core/utils/date_formatter.dart';
import '../models/category_item.dart';
import '../models/transaction_item.dart';
import '../providers/expense_provider.dart';

class AddEditTransactionScreen extends StatefulWidget {
  final TransactionItem? initialTransaction;

  const AddEditTransactionScreen({
    super.key,
    this.initialTransaction,
  });

  @override
  State<AddEditTransactionScreen> createState() => _AddEditTransactionScreenState();
}

class _AddEditTransactionScreenState extends State<AddEditTransactionScreen> {
  late bool _isExpense;
  late TextEditingController _amountController;
  late TextEditingController _titleController;
  late TextEditingController _noteController;
  late DateTime _selectedDate;
  late String _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    final init = widget.initialTransaction;
    _isExpense = init?.isExpense ?? true;

    _amountController = TextEditingController(
      text: init != null ? init.amount.toStringAsFixed(0) : '',
    );
    _titleController = TextEditingController(text: init?.title ?? '');
    _noteController = TextEditingController(text: init?.note ?? '');
    _selectedDate = init?.dateTime ?? DateTime.now();

    final defaultCats = _isExpense
        ? CategoryItem.defaultExpenseCategories
        : CategoryItem.defaultIncomeCategories;
    _selectedCategoryId = init?.categoryId ?? defaultCats.first.id;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _titleController.dispose();
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

  void _save() {
    final amount = CurrencyFormatter.parseAmount(_amountController.text.trim());
    String title = _titleController.text.trim();

    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập số tiền hợp lệ')),
      );
      return;
    }

    final cat = CategoryItem.findById(_selectedCategoryId);
    if (title.isEmpty) {
      title = cat.name;
    }

    final provider = context.read<ExpenseProvider>();

    if (widget.initialTransaction == null) {
      // Thêm mới
      final newItem = TransactionItem(
        title: title,
        amount: amount,
        isExpense: _isExpense,
        categoryId: _selectedCategoryId,
        categoryName: cat.name,
        dateTime: _selectedDate,
        note: _noteController.text.trim().isNotEmpty ? _noteController.text.trim() : null,
      );
      provider.addTransaction(newItem);
    } else {
      // Cập nhật
      final updated = widget.initialTransaction!.copyWith(
        title: title,
        amount: amount,
        isExpense: _isExpense,
        categoryId: _selectedCategoryId,
        categoryName: cat.name,
        dateTime: _selectedDate,
        note: _noteController.text.trim().isNotEmpty ? _noteController.text.trim() : null,
      );
      provider.updateTransaction(updated);
    }

    Navigator.of(context).pop();
  }

  void _delete() {
    if (widget.initialTransaction?.id != null) {
      context.read<ExpenseProvider>().deleteTransaction(widget.initialTransaction!.id!);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialTransaction != null;
    final currentCategories = _isExpense
        ? CategoryItem.defaultExpenseCategories
        : CategoryItem.defaultIncomeCategories;

    final statusColor = _isExpense ? AppTheme.expenseRed : AppTheme.incomeGreen;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Sửa giao dịch' : 'Thêm giao dịch'),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppTheme.expenseRed),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Xác nhận xóa'),
                    content: const Text('Bạn có chắc chắn muốn xóa giao dịch này?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Hủy'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          _delete();
                        },
                        child: const Text('Xóa', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Switch Loại: Chi tiền / Thu tiền (MISA style tab switch)
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _isExpense = true;
                          _selectedCategoryId = CategoryItem.defaultExpenseCategories.first.id;
                        });
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _isExpense ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: _isExpense
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.06),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  )
                                ]
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            'Chi tiền',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _isExpense ? AppTheme.expenseRed : AppTheme.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _isExpense = false;
                          _selectedCategoryId = CategoryItem.defaultIncomeCategories.first.id;
                        });
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: !_isExpense ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: !_isExpense
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.06),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  )
                                ]
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            'Thu tiền',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: !_isExpense ? AppTheme.incomeGreen : AppTheme.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Nhập số tiền lớn
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Số tiền (VND)',
                    style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '₫',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          autofocus: !isEditing,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
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

            // Form chi tiết
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: _isExpense ? 'Mục chi / Điểm bán' : 'Nguồn thu nhập',
                      prefixIcon: const Icon(Icons.description, color: AppTheme.primaryBlue),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Lưới chọn danh mục
                  const Text(
                    'Chọn danh mục',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 10),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: currentCategories.map((cat) {
                      final isSelected = _selectedCategoryId == cat.id;
                      return ChoiceChip(
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _selectedCategoryId = cat.id);
                          }
                        },
                        avatar: Icon(
                          cat.icon,
                          size: 16,
                          color: isSelected ? Colors.white : cat.color,
                        ),
                        label: Text(cat.name),
                        labelStyle: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? Colors.white : AppTheme.textPrimary,
                        ),
                        selectedColor: AppTheme.primaryBlue,
                        backgroundColor: AppTheme.surfaceMuted,
                        side: BorderSide(
                          color: isSelected ? AppTheme.primaryBlue : AppTheme.border,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Ngày giao dịch
                  InkWell(
                    onTap: _selectDate,
                    borderRadius: BorderRadius.circular(12),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Thời gian giao dịch',
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
                  const SizedBox(height: 16),

                  // Ghi chú
                  TextField(
                    controller: _noteController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Ghi chú thêm (tùy chọn)',
                      prefixIcon: Icon(Icons.edit_note, color: AppTheme.primaryBlue),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: _save,
              child: Text(isEditing ? 'Lưu thay đổi' : 'Hoàn tất'),
            ),
          ],
        ),
      ),
    );
  }
}
