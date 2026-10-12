import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/currency_formatter.dart';
import '../models/category_item.dart';
import '../providers/expense_provider.dart';
import '../widgets/charts/animated_bar_chart.dart';
import '../widgets/charts/animated_pie_chart.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  int _chartTypeIndex = 0; // 0: Pie Chart (Cơ cấu), 1: Bar Chart (Xu hướng)
  int _barViewMode = 0; // 0: 7 ngày gần đây, 1: 6 tháng gần đây

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseProvider>();
    final currentMonth = provider.selectedMonth;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Báo cáo phân tích'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Thanh chuyển đổi Tháng
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left, color: AppTheme.primaryBlue),
                    onPressed: () => provider.changeMonth(-1),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.bar_chart, color: AppTheme.primaryBlue, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Tháng ${currentMonth.month}/${currentMonth.year}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryBlueDark,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right, color: AppTheme.primaryBlue),
                    onPressed: () => provider.changeMonth(1),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Tab switch: Cơ cấu chi tiêu (Pie) vs Xu hướng thời gian (Bar)
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
                      onTap: () => setState(() => _chartTypeIndex = 0),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 9),
                        decoration: BoxDecoration(
                          color: _chartTypeIndex == 0 ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: _chartTypeIndex == 0
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
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.pie_chart,
                                size: 16,
                                color: _chartTypeIndex == 0
                                    ? AppTheme.primaryBlue
                                    : AppTheme.textSecondary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Cơ cấu chi tiêu',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: _chartTypeIndex == 0
                                      ? AppTheme.primaryBlue
                                      : AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _chartTypeIndex = 1),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 9),
                        decoration: BoxDecoration(
                          color: _chartTypeIndex == 1 ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: _chartTypeIndex == 1
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
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.bar_chart,
                                size: 16,
                                color: _chartTypeIndex == 1
                                    ? AppTheme.primaryBlue
                                    : AppTheme.textSecondary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Xu hướng thời gian',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: _chartTypeIndex == 1
                                      ? AppTheme.primaryBlue
                                      : AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Card Biểu đồ vẽ bằng CustomPainter
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
                  if (_chartTypeIndex == 0) ...[
                    // BIỂU ĐỒ TRÒN (ANIMATED PIE CHART BẰNG CUSTOMPAINTER)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Tỷ trọng theo danh mục',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          'Tổng: ${CurrencyFormatter.formatVnd(provider.monthlyExpense)}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.expenseRed,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    AnimatedPieChart(
                      sections: provider.pieChartSections,
                      totalAmount: provider.monthlyExpense,
                      height: 250,
                    ),
                  ] else ...[
                    // BIỂU ĐỒ CỘT (ANIMATED BAR CHART BẰNG CUSTOMPAINTER)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Xu hướng chi tiêu',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Row(
                          children: [
                            ChoiceChip(
                              label: const Text('7 ngày', style: TextStyle(fontSize: 11)),
                              selected: _barViewMode == 0,
                              onSelected: (_) => setState(() => _barViewMode = 0),
                              visualDensity: VisualDensity.compact,
                            ),
                            const SizedBox(width: 6),
                            ChoiceChip(
                              label: const Text('6 tháng', style: TextStyle(fontSize: 11)),
                              selected: _barViewMode == 1,
                              onSelected: (_) => setState(() => _barViewMode = 1),
                              visualDensity: VisualDensity.compact,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    AnimatedBarChart(
                      items: _barViewMode == 0
                          ? provider.recentDaysBarChartItems
                          : provider.last6MonthsBarChartItems,
                      height: 240,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Bảng xếp hạng chi tiết các khoản chi theo danh mục
            const Text(
              'Chi tiết danh mục chi tiêu',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 10),

            ..._buildCategoryRankingList(provider),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildCategoryRankingList(ExpenseProvider provider) {
    final sections = provider.pieChartSections;
    final total = provider.monthlyExpense;

    if (sections.isEmpty || total <= 0) {
      return [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.border),
          ),
          child: const Center(
            child: Text(
              'Chưa có dữ liệu chi tiêu',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ),
        ),
      ];
    }

    return sections.map((sec) {
      final percent = (sec.value / total) * 100;
      final cat = CategoryItem.findById(sec.key);

      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: sec.color.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(cat.icon, color: sec.color, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sec.label,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      Text(
                        '${percent.toStringAsFixed(1)}% tổng chi tiêu',
                        style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                ),
                Text(
                  CurrencyFormatter.formatVnd(sec.value),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Thanh tiến trình tỷ lệ %
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (percent / 100).clamp(0.0, 1.0),
                backgroundColor: AppTheme.surfaceMuted,
                color: sec.color,
                minHeight: 5,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}
