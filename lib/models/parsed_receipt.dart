class ParsedReceipt {
  final String? merchant;
  final DateTime? date;
  final double? totalAmount;
  final String? suggestedCategoryId;
  final String? suggestedCategoryName;
  final List<String> rawLines;
  final String rawText;
  final double confidenceScore; // 0.0 - 1.0

  const ParsedReceipt({
    this.merchant,
    this.date,
    this.totalAmount,
    this.suggestedCategoryId,
    this.suggestedCategoryName,
    required this.rawLines,
    required this.rawText,
    this.confidenceScore = 0.8,
  });

  bool get hasValidTotal => totalAmount != null && totalAmount! > 0;
  bool get hasValidMerchant => merchant != null && merchant!.trim().isNotEmpty;
  bool get hasValidDate => date != null;
}
