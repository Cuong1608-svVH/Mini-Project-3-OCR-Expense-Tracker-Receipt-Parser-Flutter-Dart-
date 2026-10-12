import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/utils/date_formatter.dart';
import '../models/category_item.dart';
import '../models/transaction_item.dart';
import '../services/csv_export_service.dart';
import '../services/database_service.dart';
import '../widgets/charts/animated_bar_chart.dart';
import '../widgets/charts/animated_pie_chart.dart';

class ExpenseProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService.instance;

  List<TransactionItem> _allTransactions = [];
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  String _searchQuery = '';
  String? _selectedCategoryFilter;
  bool _isLoading = false;

  List<TransactionItem> get allTransactions => _allTransactions;
  DateTime get selectedMonth => _selectedMonth;
  String get searchQuery => _searchQuery;
  String? get selectedCategoryFilter => _selectedCategoryFilter;
  bool get isLoading => _isLoading;

  ExpenseProvider() {
    loadTransactions();
  }

  Future<void> loadTransactions() async {
    _isLoading = true;
    notifyListeners();

    try {
      _allTransactions = await _db.getAllTransactions();
    } catch (e) {
      debugPrint('Error loading transactions: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Danh sách giao dịch thuộc tháng đang chọn (có áp dụng tìm kiếm & lọc danh mục)
  List<TransactionItem> get filteredTransactions {
    return _allTransactions.where((tx) {
      final isSameMonth = tx.dateTime.year == _selectedMonth.year &&
          tx.dateTime.month == _selectedMonth.month;
      if (!isSameMonth) return false;

      if (_selectedCategoryFilter != null &&
          tx.categoryId != _selectedCategoryFilter) {
        return false;
      }

      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchTitle = tx.title.toLowerCase().contains(q);
        final matchCategory = tx.categoryName.toLowerCase().contains(q);
        final matchMerchant = (tx.merchant ?? '').toLowerCase().contains(q);
        final matchNote = (tx.note ?? '').toLowerCase().contains(q);
        if (!matchTitle && !matchCategory && !matchMerchant && !matchNote) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  /// Gom nhóm giao dịch theo từng ngày (phong cách MISA Money Keeper)
  Map<String, List<TransactionItem>> get groupedTransactionsByDay {
    final Map<String, List<TransactionItem>> groups = {};
    final list = filteredTransactions;

    // Sắp xếp giảm dần theo thời gian
    list.sort((a, b) => b.dateTime.compareTo(a.dateTime));

    for (final tx in list) {
      final key = DateFormatter.getDateKey(tx.dateTime);
      if (!groups.containsKey(key)) {
        groups[key] = [];
      }
      groups[key]!.add(tx);
    }

    return groups;
  }

  /// Tổng chi tiêu trong tháng đang chọn
  double get monthlyExpense {
    double total = 0;
    for (final tx in _allTransactions) {
      if (tx.dateTime.year == _selectedMonth.year &&
          tx.dateTime.month == _selectedMonth.month &&
          tx.isExpense) {
        total += tx.amount;
      }
    }
    return total;
  }

  /// Tổng thu nhập trong tháng đang chọn
  double get monthlyIncome {
    double total = 0;
    for (final tx in _allTransactions) {
      if (tx.dateTime.year == _selectedMonth.year &&
          tx.dateTime.month == _selectedMonth.month &&
          !tx.isExpense) {
        total += tx.amount;
      }
    }
    return total;
  }

  /// Số dư ròng của tháng đang chọn
  double get monthlyNet => monthlyIncome - monthlyExpense;

  /// Tổng số dư toàn bộ tài khoản
  double get totalBalance {
    double total = 0;
    for (final tx in _allTransactions) {
      if (tx.isExpense) {
        total -= tx.amount;
      } else {
        total += tx.amount;
      }
    }
    return total;
  }

  /// Dữ liệu lát cắt cho Animated Pie Chart theo từng danh mục
  List<PieChartSectionData> get pieChartSections {
    final Map<String, double> categorySums = {};

    for (final tx in _allTransactions) {
      if (tx.dateTime.year == _selectedMonth.year &&
          tx.dateTime.month == _selectedMonth.month &&
          tx.isExpense) {
        categorySums[tx.categoryId] =
            (categorySums[tx.categoryId] ?? 0) + tx.amount;
      }
    }

    final List<PieChartSectionData> sections = [];
    categorySums.forEach((catId, sum) {
      final cat = CategoryItem.findById(catId);
      sections.add(
        PieChartSectionData(
          key: catId,
          label: cat.name,
          value: sum,
          color: cat.color,
        ),
      );
    });

    // Sắp xếp các danh mục lớn nhất lên trước
    sections.sort((a, b) => b.value.compareTo(a.value));
    return sections;
  }

  /// Dữ liệu biểu đồ cột cho 7 ngày gần nhất
  List<BarChartItemData> get recentDaysBarChartItems {
    final List<BarChartItemData> items = [];
    final now = DateTime.now();

    for (int i = 6; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      double dayExpense = 0;
      double dayIncome = 0;

      for (final tx in _allTransactions) {
        if (tx.dateTime.year == day.year &&
            tx.dateTime.month == day.month &&
            tx.dateTime.day == day.day) {
          if (tx.isExpense) {
            dayExpense += tx.amount;
          } else {
            dayIncome += tx.amount;
          }
        }
      }

      final label = i == 0 ? 'H.nay' : DateFormat('dd/MM').format(day);
      final fullLabel = DateFormatter.formatMisaDayHeader(day);

      items.add(
        BarChartItemData(
          label: label,
          expenseAmount: dayExpense,
          incomeAmount: dayIncome,
          fullDateLabel: fullLabel,
        ),
      );
    }

    return items;
  }

  /// Dữ liệu biểu đồ cột xu hướng 6 tháng gần nhất
  List<BarChartItemData> get last6MonthsBarChartItems {
    final List<BarChartItemData> items = [];
    final now = DateTime.now();

    for (int i = 5; i >= 0; i--) {
      final monthDate = DateTime(now.year, now.month - i, 1);
      double exp = 0;
      double inc = 0;

      for (final tx in _allTransactions) {
        if (tx.dateTime.year == monthDate.year &&
            tx.dateTime.month == monthDate.month) {
          if (tx.isExpense) {
            exp += tx.amount;
          } else {
            inc += tx.amount;
          }
        }
      }

      items.add(
        BarChartItemData(
          label: 'T${monthDate.month}',
          expenseAmount: exp,
          incomeAmount: inc,
          fullDateLabel: 'Tháng ${monthDate.month}/${monthDate.year}',
        ),
      );
    }

    return items;
  }

  // --- Actions ---

  Future<void> addTransaction(TransactionItem item) async {
    final id = await _db.insertTransaction(item);
    _allTransactions.insert(0, item.copyWith(id: id));
    notifyListeners();
  }

  Future<void> updateTransaction(TransactionItem item) async {
    await _db.updateTransaction(item);
    final index = _allTransactions.indexWhere((t) => t.id == item.id);
    if (index != -1) {
      _allTransactions[index] = item;
      notifyListeners();
    }
  }

  Future<void> deleteTransaction(int id) async {
    await _db.deleteTransaction(id);
    _allTransactions.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  void changeMonth(int delta) {
    _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + delta);
    notifyListeners();
  }

  void setSelectedMonth(DateTime month) {
    _selectedMonth = DateTime(month.year, month.month);
    notifyListeners();
  }

  void setSearchQuery(String q) {
    _searchQuery = q;
    notifyListeners();
  }

  void setCategoryFilter(String? categoryId) {
    _selectedCategoryFilter = categoryId;
    notifyListeners();
  }

  /// Xuất CSV với các tùy chọn phạm vi thời gian
  Future<CsvExportResult> exportTransactions({
    required String scope, // 'current_month', 'last_month', 'all'
  }) async {
    List<TransactionItem> exportList;

    if (scope == 'current_month') {
      final now = DateTime.now();
      exportList = _allTransactions.where((tx) =>
          tx.dateTime.year == now.year && tx.dateTime.month == now.month).toList();
    } else if (scope == 'last_month') {
      final lastMonth = DateTime(DateTime.now().year, DateTime.now().month - 1);
      exportList = _allTransactions.where((tx) =>
          tx.dateTime.year == lastMonth.year && tx.dateTime.month == lastMonth.month).toList();
    } else {
      exportList = List.from(_allTransactions);
    }

    exportList.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    return await CsvExportService.exportTransactionsToCsv(exportList);
  }
}
