class TransactionItem {
  final int? id;
  final String title;
  final double amount;
  final bool isExpense;
  final String categoryId;
  final String categoryName;
  final DateTime dateTime;
  final String? note;
  final String? merchant;
  final String? rawOcrText;
  final String? receiptImagePath;

  const TransactionItem({
    this.id,
    required this.title,
    required this.amount,
    required this.isExpense,
    required this.categoryId,
    required this.categoryName,
    required this.dateTime,
    this.note,
    this.merchant,
    this.rawOcrText,
    this.receiptImagePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'isExpense': isExpense ? 1 : 0,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'dateTime': dateTime.toIso8601String(),
      'note': note,
      'merchant': merchant,
      'rawOcrText': rawOcrText,
      'receiptImagePath': receiptImagePath,
    };
  }

  factory TransactionItem.fromMap(Map<String, dynamic> map) {
    return TransactionItem(
      id: map['id'] as int?,
      title: map['title'] as String,
      amount: (map['amount'] as num).toDouble(),
      isExpense: (map['isExpense'] as int) == 1,
      categoryId: map['categoryId'] as String,
      categoryName: map['categoryName'] as String,
      dateTime: DateTime.parse(map['dateTime'] as String),
      note: map['note'] as String?,
      merchant: map['merchant'] as String?,
      rawOcrText: map['rawOcrText'] as String?,
      receiptImagePath: map['receiptImagePath'] as String?,
    );
  }

  TransactionItem copyWith({
    int? id,
    String? title,
    double? amount,
    bool? isExpense,
    String? categoryId,
    String? categoryName,
    DateTime? dateTime,
    String? note,
    String? merchant,
    String? rawOcrText,
    String? receiptImagePath,
  }) {
    return TransactionItem(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      isExpense: isExpense ?? this.isExpense,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      dateTime: dateTime ?? this.dateTime,
      note: note ?? this.note,
      merchant: merchant ?? this.merchant,
      rawOcrText: rawOcrText ?? this.rawOcrText,
      receiptImagePath: receiptImagePath ?? this.receiptImagePath,
    );
  }
}
