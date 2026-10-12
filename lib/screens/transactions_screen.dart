import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/currency_formatter.dart';
import '../core/utils/date_formatter.dart';
import '../models/category_item.dart';
import '../models/transaction_item.dart';
import '../providers/expense_provider.dart';
import 'add_edit_transaction_screen.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseProvider>();
    final currentMonth = provider.selectedMonth;
    final grouped = provider.groupedTransactionsByDay;

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm khoản chi, điểm bán...',
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      provider.setSearchQuery('');
                      setState(() => _isSearching = false);
                    },
                  ),
                ),
                onChanged: (q) => provider.setSearchQuery(q),
              )
            : const Text('Sổ giao dịch'),
        actions: [
          if (!_isSearching)
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () => setState(() => _isSearching = true),
            ),
        ],
      ),
      body: Column(
        children: [
          // Thanh điều hướng tháng kiểu MISA
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left, color: AppTheme.primaryBlue),
                  onPressed: () => provider.changeMonth(-1),
                ),
                Text(
                  'Tháng ${currentMonth.month}/${currentMonth.year}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryBlueDark,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right, color: AppTheme.primaryBlue),
                  onPressed: () => provider.changeMonth(1),
                ),
              ],
            ),
          ),

          // Tóm tắt tổng thu/chi tháng trên thanh tiêu đề
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: AppTheme.primaryBlueLight.withOpacity(0.4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const Text('Tổng thu', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                    const SizedBox(height: 2),
                    Text(
                      '+${CurrencyFormatter.formatVnd(provider.monthlyIncome)}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.incomeGreen,
                      ),
                    ),
                  ],
                ),
                Container(width: 1, height: 24, color: AppTheme.border),
                Column(
                  children: [
                    const Text('Tổng chi', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                    const SizedBox(height: 2),
                    Text(
                      '-${CurrencyFormatter.formatVnd(provider.monthlyExpense)}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.expenseRed,
                      ),
                    ),
                  ],
                ),
                Container(width: 1, height: 24, color: AppTheme.border),
                Column(
                  children: [
                    const Text('Số dư tháng', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                    const SizedBox(height: 2),
                    Text(
                      CurrencyFormatter.formatVnd(provider.monthlyNet),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: provider.monthlyNet >= 0
                            ? AppTheme.incomeGreen
                            : AppTheme.expenseRed,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Bộ lọc danh mục (Filter Chips)
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                ChoiceChip(
                  label: const Text('Tất cả'),
                  selected: provider.selectedCategoryFilter == null,
                  onSelected: (_) => provider.setCategoryFilter(null),
                  selectedColor: AppTheme.primaryBlue,
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: provider.selectedCategoryFilter == null
                        ? Colors.white
                        : AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                ...CategoryItem.allDefaults.map((cat) {
                  final isSelected = provider.selectedCategoryFilter == cat.id;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      avatar: Icon(cat.icon, size: 14, color: isSelected ? Colors.white : cat.color),
                      label: Text(cat.name),
                      selected: isSelected,
                      onSelected: (selected) {
                        provider.setCategoryFilter(selected ? cat.id : null);
                      },
                      selectedColor: AppTheme.primaryBlue,
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : AppTheme.textPrimary,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),

          const Divider(height: 1, color: AppTheme.border),

          // Danh sách gom nhóm theo ngày
          Expanded(
            child: grouped.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.receipt_outlined, size: 48, color: AppTheme.textMuted),
                        const SizedBox(height: 8),
                        Text(
                          provider.searchQuery.isNotEmpty
                              ? 'Không tìm thấy giao dịch phù hợp'
                              : 'Chưa có giao dịch trong tháng ${currentMonth.month}/${currentMonth.year}',
                          style: const TextStyle(color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                    itemCount: grouped.keys.length,
                    itemBuilder: (context, index) {
                      final dateKey = grouped.keys.elementAt(index);
                      final transactions = grouped[dateKey]!;
                      return _buildDayGroup(context, transactions);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayGroup(BuildContext context, List<TransactionItem> items) {
    if (items.isEmpty) return const SizedBox.shrink();

    final date = items.first.dateTime;

    // Tính tổng chi và tổng thu trong ngày
    double dayExpense = 0;
    double dayIncome = 0;
    for (final tx in items) {
      if (tx.isExpense) {
        dayExpense += tx.amount;
      } else {
        dayIncome += tx.amount;
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Tiêu đề ngày phong cách MISA
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: const BoxDecoration(
              color: AppTheme.surfaceMuted,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 14, color: AppTheme.primaryBlue),
                    const SizedBox(width: 6),
                    Text(
                      DateFormatter.formatMisaDayHeader(date),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
                Text(
                  dayExpense > 0
                      ? '-${CurrencyFormatter.formatVnd(dayExpense)}'
                      : '+${CurrencyFormatter.formatVnd(dayIncome)}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: dayExpense > 0 ? AppTheme.expenseRed : AppTheme.incomeGreen,
                  ),
                ),
              ],
            ),
          ),

          // Các khoản trong ngày
          ...items.asMap().entries.map((entry) {
            final idx = entry.key;
            final tx = entry.value;
            final cat = CategoryItem.findById(tx.categoryId);
            final isLast = idx == items.length - 1;

            return Column(
              children: [
                Dismissible(
                  key: Key('tx_${tx.id}_${tx.dateTime.millisecondsSinceEpoch}'),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: AppTheme.expenseRed,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 16),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (direction) async {
                    return await showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Xóa giao dịch'),
                        content: Text('Xóa giao dịch "${tx.title}"?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Hủy'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                  },
                  onDismissed: (_) {
                    if (tx.id != null) {
                      context.read<ExpenseProvider>().deleteTransaction(tx.id!);
                    }
                  },
                  child: ListTile(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => AddEditTransactionScreen(initialTransaction: tx),
                        ),
                      );
                    },
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                    leading: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: cat.color.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(cat.icon, color: cat.color, size: 18),
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            tx.title,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (tx.rawOcrText != null && tx.rawOcrText!.isNotEmpty)
                          Container(
                            margin: const EdgeInsets.only(left: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryBlueLight,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'OCR',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryBlue,
                              ),
                            ),
                          ),
                      ],
                    ),
                    subtitle: Text(
                      '${cat.name} • ${DateFormatter.formatTime(tx.dateTime)}${tx.note != null && tx.note!.isNotEmpty ? ' • ${tx.note}' : ''}',
                      style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Text(
                      '${tx.isExpense ? '-' : '+'}${CurrencyFormatter.formatVnd(tx.amount)}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: tx.isExpense ? AppTheme.expenseRed : AppTheme.incomeGreen,
                      ),
                    ),
                  ),
                ),
                if (!isLast) const Divider(height: 1, indent: 56, endIndent: 14, color: AppTheme.border),
              ],
            );
          }),
        ],
      ),
    );
  }
}
