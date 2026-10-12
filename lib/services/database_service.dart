import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_common_ffi.dart';
import '../models/category_item.dart';
import '../models/transaction_item.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._internal();
  DatabaseService._internal();

  Database? _database;
  List<TransactionItem>? _webTransactions;
  static const String _webStorageKey = 'misa_local_transactions_v2';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // Khởi tạo FFI cho Windows/Linux Desktop
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    String dbPath;
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux)) {
      final docDir = await getApplicationDocumentsDirectory();
      dbPath = join(docDir.path, 'ocr_expense_tracker.db');
    } else {
      final defaultDatabasesPath = await getDatabasesPath();
      dbPath = join(defaultDatabasesPath, 'ocr_expense_tracker.db');
    }

    return await openDatabase(
      dbPath,
      version: 1,
      onCreate: _onCreate,
    );
  }

  List<TransactionItem> _generateDefaultSampleTransactions() {
    final now = DateTime.now();
    return [
      TransactionItem(
        id: 1,
        title: 'WinMart+ Lê Lợi',
        amount: 237576,
        isExpense: true,
        categoryId: 'shopping',
        categoryName: 'Mua sắm & Siêu thị',
        dateTime: DateTime(2026, 4, 25, 10, 31),
        merchant: 'WinMart+',
        note: 'Mua sắm thực phẩm và táo Gala',
        rawOcrText: 'WinMart+\nPHIẾU TÍNH TIỀN\nTiền cần thanh toán: 237,576',
      ),
      TransactionItem(
        id: 2,
        title: 'WinMart Thịt Heo Meat Deli',
        amount: 68097,
        isExpense: true,
        categoryId: 'shopping',
        categoryName: 'Mua sắm & Siêu thị',
        dateTime: DateTime(2026, 3, 6, 11, 28),
        merchant: 'WinMart',
        note: 'Thịt heo xay & Cam vàng (Ưu đãi 400.000đ)',
        rawOcrText: 'WinMart\nTỔNG TIỀN: 468,097\nTiền cần thanh toán: 68,097',
      ),
      TransactionItem(
        id: 3,
        title: 'Highlands Coffee',
        amount: 129000,
        isExpense: true,
        categoryId: 'cafe',
        categoryName: 'Cafe & Trà sữa',
        dateTime: DateTime(now.year, now.month, now.day, 9, 30),
        merchant: 'Highlands Coffee',
        note: 'Cà phê sáng cùng đồng nghiệp (quét từ hóa đơn)',
        rawOcrText: 'HIGHLANDS COFFEE\nTỔNG CỘNG: 129.000 ₫',
      ),
      TransactionItem(
        id: 4,
        title: 'Lương chuyển khoản tháng',
        amount: 18500000,
        isExpense: false,
        categoryId: 'salary',
        categoryName: 'Lương',
        dateTime: DateTime(now.year, now.month, 1, 8, 0),
        note: 'Nhận lương định kỳ hàng tháng',
      ),
      TransactionItem(
        id: 5,
        title: 'Cơm Niêu Sài Gòn',
        amount: 580000,
        isExpense: true,
        categoryId: 'food',
        categoryName: 'Ăn uống',
        dateTime: now.subtract(const Duration(days: 1)),
        merchant: 'Nhà Hàng Cơm Niêu Sài Gòn',
        note: 'Tiệc tối cuối tuần',
      ),
      TransactionItem(
        id: 6,
        title: 'Đổ xăng Petrolimex',
        amount: 90000,
        isExpense: true,
        categoryId: 'transport',
        categoryName: 'Di chuyển & Xăng xe',
        dateTime: now.subtract(const Duration(days: 2)),
        merchant: 'Petrolimex',
        note: 'Xăng xe máy',
      ),
    ];
  }

  // Quản lý LocalStorage vĩnh viễn trên Web (không bị mất khi F5 reload)
  Future<List<TransactionItem>> _getOrLoadWebTransactions() async {
    if (_webTransactions != null) return _webTransactions!;

    final prefs = await SharedPreferences.getInstance();
    final savedJson = prefs.getString(_webStorageKey);

    if (savedJson != null && savedJson.isNotEmpty) {
      try {
        final List<dynamic> list = jsonDecode(savedJson);
        _webTransactions = list
            .map((item) => TransactionItem.fromMap(Map<String, dynamic>.from(item)))
            .toList();
        return _webTransactions!;
      } catch (e) {
        debugPrint('Lỗi đọc dữ liệu từ SharedPreferences: $e');
      }
    }

    // Nếu chưa có dữ liệu trong LocalStorage, nạp mẫu và lưu lại
    _webTransactions = _generateDefaultSampleTransactions();
    await _saveWebTransactionsToStorage();
    return _webTransactions!;
  }

  Future<void> _saveWebTransactionsToStorage() async {
    if (_webTransactions == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final listMaps = _webTransactions!.map((t) => t.toMap()).toList();
      await prefs.setString(_webStorageKey, jsonEncode(listMaps));
    } catch (e) {
      debugPrint('Lỗi lưu SharedPreferences: $e');
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    // Bảng categories
    await db.execute('''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        isExpense INTEGER NOT NULL,
        iconCode INTEGER NOT NULL,
        colorValue INTEGER NOT NULL
      )
    ''');

    // Bảng transactions
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        isExpense INTEGER NOT NULL,
        categoryId TEXT NOT NULL,
        categoryName TEXT NOT NULL,
        dateTime TEXT NOT NULL,
        note TEXT,
        merchant TEXT,
        rawOcrText TEXT,
        receiptImagePath TEXT
      )
    ''');

    // Seed danh mục mặc định
    for (final cat in CategoryItem.allDefaults) {
      await db.insert('categories', cat.toMap());
    }

    // Seed dữ liệu giao dịch mẫu phong cách MISA
    final sampleTransactions = _generateDefaultSampleTransactions();
    for (final tx in sampleTransactions) {
      await db.insert('transactions', tx.toMap());
    }
  }

  // Transaction CRUD Operations
  Future<int> insertTransaction(TransactionItem item) async {
    if (kIsWeb) {
      await _getOrLoadWebTransactions();
      final newId = DateTime.now().millisecondsSinceEpoch;
      final newItem = item.copyWith(id: newId);
      _webTransactions!.insert(0, newItem);
      await _saveWebTransactionsToStorage();
      return newId;
    }

    final db = await database;
    return await db.insert('transactions', item.toMap());
  }

  Future<int> updateTransaction(TransactionItem item) async {
    if (kIsWeb) {
      await _getOrLoadWebTransactions();
      final idx = _webTransactions!.indexWhere((t) => t.id == item.id);
      if (idx != -1) {
        _webTransactions![idx] = item;
        await _saveWebTransactionsToStorage();
      }
      return 1;
    }

    final db = await database;
    return await db.update(
      'transactions',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> deleteTransaction(int id) async {
    if (kIsWeb) {
      await _getOrLoadWebTransactions();
      _webTransactions!.removeWhere((t) => t.id == id);
      await _saveWebTransactionsToStorage();
      return 1;
    }

    final db = await database;
    return await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<TransactionItem>> getAllTransactions() async {
    if (kIsWeb) {
      return await _getOrLoadWebTransactions();
    }

    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      orderBy: 'dateTime DESC',
    );
    return List.generate(maps.length, (i) => TransactionItem.fromMap(maps[i]));
  }

  Future<List<TransactionItem>> getTransactionsByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    if (kIsWeb) {
      final list = await _getOrLoadWebTransactions();
      return list
          .where((t) => t.dateTime.isAfter(start) && t.dateTime.isBefore(end))
          .toList();
    }

    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: 'dateTime >= ? AND dateTime <= ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'dateTime DESC',
    );
    return List.generate(maps.length, (i) => TransactionItem.fromMap(maps[i]));
  }

  Future<List<CategoryItem>> getAllCategories() async {
    return CategoryItem.allDefaults;
  }
}
