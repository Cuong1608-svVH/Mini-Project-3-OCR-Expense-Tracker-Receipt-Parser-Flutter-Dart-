import 'package:flutter/material.dart';

class CategoryItem {
  final String id;
  final String name;
  final bool isExpense;
  final IconData icon;
  final Color color;

  const CategoryItem({
    required this.id,
    required this.name,
    required this.isExpense,
    required this.icon,
    required this.color,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'isExpense': isExpense ? 1 : 0,
      'iconCode': icon.codePoint,
      'colorValue': color.value,
    };
  }

  factory CategoryItem.fromMap(Map<String, dynamic> map) {
    final catId = map['id'] as String;
    final defaultCat = findById(catId);
    return CategoryItem(
      id: catId,
      name: map['name'] as String,
      isExpense: (map['isExpense'] as int) == 1,
      icon: defaultCat.icon,
      color: Color(map['colorValue'] as int),
    );
  }

  // Danh sách danh mục chi tiêu mặc định chuẩn Việt Nam
  static final List<CategoryItem> defaultExpenseCategories = [
    const CategoryItem(
      id: 'food',
      name: 'Ăn uống',
      isExpense: true,
      icon: Icons.restaurant,
      color: Color(0xFFFF5E3A),
    ),
    const CategoryItem(
      id: 'shopping',
      name: 'Mua sắm & Siêu thị',
      isExpense: true,
      icon: Icons.shopping_bag,
      color: Color(0xFF9B51E0),
    ),
    const CategoryItem(
      id: 'transport',
      name: 'Di chuyển & Xăng xe',
      isExpense: true,
      icon: Icons.directions_car,
      color: Color(0xFF2F80ED),
    ),
    const CategoryItem(
      id: 'bills',
      name: 'Hóa đơn & Tiện ích',
      isExpense: true,
      icon: Icons.receipt_long,
      color: Color(0xFFF2994A),
    ),
    const CategoryItem(
      id: 'cafe',
      name: 'Cafe & Trà sữa',
      isExpense: true,
      icon: Icons.local_cafe,
      color: Color(0xFF8D6E63),
    ),
    const CategoryItem(
      id: 'entertainment',
      name: 'Giải trí',
      isExpense: true,
      icon: Icons.sports_esports,
      color: Color(0xFFEB5757),
    ),
    const CategoryItem(
      id: 'health',
      name: 'Sức khỏe & Thuốc',
      isExpense: true,
      icon: Icons.medical_services,
      color: Color(0xFF27AE60),
    ),
    const CategoryItem(
      id: 'education',
      name: 'Học tập',
      isExpense: true,
      icon: Icons.school,
      color: Color(0xFF2D9CDB),
    ),
    const CategoryItem(
      id: 'other_expense',
      name: 'Chi tiêu khác',
      isExpense: true,
      icon: Icons.category,
      color: Color(0xFF64748B),
    ),
  ];

  // Danh mục thu nhập mặc định
  static final List<CategoryItem> defaultIncomeCategories = [
    const CategoryItem(
      id: 'salary',
      name: 'Lương',
      isExpense: false,
      icon: Icons.account_balance_wallet,
      color: Color(0xFF00B074),
    ),
    const CategoryItem(
      id: 'bonus',
      name: 'Thưởng',
      isExpense: false,
      icon: Icons.card_giftcard,
      color: Color(0xFF2A85FF),
    ),
    const CategoryItem(
      id: 'investment',
      name: 'Đầu tư / Lãi',
      isExpense: false,
      icon: Icons.trending_up,
      color: Color(0xFFF2C94C),
    ),
    const CategoryItem(
      id: 'other_income',
      name: 'Thu nhập khác',
      isExpense: false,
      icon: Icons.attach_money,
      color: Color(0xFF20C997),
    ),
  ];

  static List<CategoryItem> get allDefaults => [
        ...defaultExpenseCategories,
        ...defaultIncomeCategories,
      ];

  static CategoryItem findById(String id) {
    return allDefaults.firstWhere(
      (c) => c.id == id,
      orElse: () => const CategoryItem(
        id: 'other_expense',
        name: 'Chi tiêu khác',
        isExpense: true,
        icon: Icons.category,
        color: Color(0xFF64748B),
      ),
    );
  }
}
