import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/currency_formatter.dart';

class BarChartItemData {
  final String label; // e.g., "T2", "12/10", "T10"
  final double expenseAmount;
  final double incomeAmount;
  final String fullDateLabel; // e.g., "Thứ Hai, 12/10"

  BarChartItemData({
    required this.label,
    required this.expenseAmount,
    this.incomeAmount = 0.0,
    required this.fullDateLabel,
  });
}

class AnimatedBarChart extends StatefulWidget {
  final List<BarChartItemData> items;
  final double height;
  final bool showIncome;

  const AnimatedBarChart({
    super.key,
    required this.items,
    this.height = 240,
    this.showIncome = false,
  });

  @override
  State<AnimatedBarChart> createState() => _AnimatedBarChartState();
}

class _AnimatedBarChartState extends State<AnimatedBarChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int? _selectedBarIndex;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant AnimatedBarChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items != widget.items) {
      _controller.forward(from: 0.0);
      _selectedBarIndex = null;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap(Offset localPosition, Size size) {
    if (widget.items.isEmpty) return;

    final count = widget.items.length;
    final chartAreaWidth = size.width - 40; // padding left/right
    final slotWidth = chartAreaWidth / count;
    final relativeX = localPosition.dx - 20;

    if (relativeX < 0 || relativeX > chartAreaWidth) {
      setState(() {
        _selectedBarIndex = null;
      });
      return;
    }

    final tappedIndex = (relativeX / slotWidth).floor().clamp(0, count - 1);
    setState(() {
      _selectedBarIndex = (_selectedBarIndex == tappedIndex) ? null : tappedIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return SizedBox(
        height: widget.height,
        child: const Center(
          child: Text(
            'Chưa có dữ liệu thống kê',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
          ),
        ),
      );
    }

    // Tìm giá trị lớn nhất để chuẩn hóa trục Y
    double maxValue = 1.0;
    for (final item in widget.items) {
      if (item.expenseAmount > maxValue) maxValue = item.expenseAmount;
      if (widget.showIncome && item.incomeAmount > maxValue) {
        maxValue = item.incomeAmount;
      }
    }

    return SizedBox(
      height: widget.height,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = Size(constraints.maxWidth, constraints.maxHeight);
          return GestureDetector(
            onTapUp: (details) => _handleTap(details.localPosition, size),
            onPanUpdate: (details) => _handleTap(details.localPosition, size),
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return CustomPaint(
                  size: size,
                  painter: _BarChartPainter(
                    items: widget.items,
                    maxValue: maxValue,
                    animationProgress: _animation.value,
                    selectedIndex: _selectedBarIndex,
                    showIncome: widget.showIncome,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _BarChartPainter extends CustomPainter {
  final List<BarChartItemData> items;
  final double maxValue;
  final double animationProgress;
  final int? selectedIndex;
  final bool showIncome;

  _BarChartPainter({
    required this.items,
    required this.maxValue,
    required this.animationProgress,
    this.selectedIndex,
    required this.showIncome,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const leftPadding = 20.0;
    const rightPadding = 20.0;
    const bottomPadding = 36.0;
    const topPadding = 40.0; // Khoảng trống cho Tooltip bay phía trên

    final chartWidth = size.width - leftPadding - rightPadding;
    final chartHeight = size.height - bottomPadding - topPadding;
    final count = items.length;
    final slotWidth = chartWidth / count;
    final barWidth = math.min(slotWidth * 0.55, 32.0);

    // 1. Vẽ các đường gióng ngang mờ (Grid lines)
    final gridPaint = Paint()
      ..color = AppTheme.border.withOpacity(0.8)
      ..strokeWidth = 1.0;

    for (int i = 0; i <= 3; i++) {
      final y = topPadding + (chartHeight / 3) * i;
      canvas.drawLine(
        Offset(leftPadding, y),
        Offset(size.width - rightPadding, y),
        gridPaint,
      );
    }

    // 2. Vẽ từng cột Bar
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    Offset? activeTooltipCenter;
    String? tooltipText;
    String? tooltipSubText;

    for (int i = 0; i < count; i++) {
      final item = items[i];
      final slotCenterX = leftPadding + (i * slotWidth) + (slotWidth / 2);
      final isSelected = selectedIndex == i;

      // Chiều cao cột chi tiêu
      final targetBarHeight = (item.expenseAmount / maxValue) * chartHeight;
      final currentBarHeight = targetBarHeight * animationProgress;

      final barLeft = slotCenterX - (barWidth / 2);
      final barTop = topPadding + chartHeight - currentBarHeight;
      final barBottom = topPadding + chartHeight;

      final barRect = RRect.fromRectAndCorners(
        Rect.fromLTRB(barLeft, barTop, barLeft + barWidth, barBottom),
        topLeft: const Radius.circular(6),
        topRight: const Radius.circular(6),
      );

      // Cọ vẽ gradient cho cột
      final barPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isSelected
              ? [AppTheme.primaryBlue, AppTheme.accentBlue]
              : [
                  AppTheme.primaryBlue.withOpacity(0.75),
                  AppTheme.primaryBlue.withOpacity(0.35),
                ],
        ).createShader(Rect.fromLTRB(barLeft, barTop, barLeft + barWidth, barBottom));

      // Vẽ hiệu ứng bóng khi cột được chọn
      if (isSelected) {
        final shadowPaint = Paint()
          ..color = AppTheme.primaryBlue.withOpacity(0.35)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
        canvas.drawRRect(barRect, shadowPaint);
      }

      canvas.drawRRect(barRect, barPaint);

      // 3. Nhãn chữ trục X bên dưới cột
      textPainter.text = TextSpan(
        text: item.label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          color: isSelected ? AppTheme.primaryBlue : AppTheme.textSecondary,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(slotCenterX - (textPainter.width / 2), barBottom + 8),
      );

      // Ghi nhận vị trí vẽ Tooltip nếu cột này được chọn
      if (isSelected) {
        activeTooltipCenter = Offset(slotCenterX, barTop);
        tooltipText = CurrencyFormatter.formatVnd(item.expenseAmount);
        tooltipSubText = item.fullDateLabel;
      }
    }

    // 4. Vẽ Interactive Tooltip nổi nếu có cột được chọn
    if (activeTooltipCenter != null && tooltipText != null) {
      _drawTooltip(
        canvas,
        size,
        activeTooltipCenter,
        tooltipText,
        tooltipSubText,
      );
    }
  }

  void _drawTooltip(
    Canvas canvas,
    Size size,
    Offset barTopCenter,
    String title,
    String? subtitle,
  ) {
    const tooltipWidth = 110.0;
    const tooltipHeight = 36.0;

    // Giữ tooltip không bị tràn lề trái/phải
    final tooltipX = (barTopCenter.dx - (tooltipWidth / 2))
        .clamp(10.0, size.width - tooltipWidth - 10.0);
    final tooltipY = math.max(6.0, barTopCenter.dy - tooltipHeight - 10.0);

    final tooltipRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(tooltipX, tooltipY, tooltipWidth, tooltipHeight),
      const Radius.circular(8),
    );

    // Đổ bóng cho tooltip
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.18)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawRRect(tooltipRect, shadowPaint);

    // Nền Tooltip màu xanh MISA đậm sang trọng
    final bgPaint = Paint()..color = const Color(0xFF1E293B);
    canvas.drawRRect(tooltipRect, bgPaint);

    // Mũi tên trỏ xuống đỉnh cột
    final arrowPath = Path()
      ..moveTo(barTopCenter.dx - 6, tooltipY + tooltipHeight)
      ..lineTo(barTopCenter.dx + 6, tooltipY + tooltipHeight)
      ..lineTo(barTopCenter.dx, tooltipY + tooltipHeight + 5)
      ..close();
    canvas.drawPath(arrowPath, bgPaint);

    // Vẽ chữ số tiền trên Tooltip
    final tp = TextPainter(
      text: TextSpan(
        children: [
          if (subtitle != null)
            TextSpan(
              text: '$subtitle\n',
              style: const TextStyle(fontSize: 9, color: Color(0xFF94A3B8)),
            ),
          TextSpan(
            text: title,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    tp.layout(maxWidth: tooltipWidth);
    tp.paint(
      canvas,
      Offset(
        tooltipX + (tooltipWidth - tp.width) / 2,
        tooltipY + (tooltipHeight - tp.height) / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant _BarChartPainter oldDelegate) {
    return oldDelegate.animationProgress != animationProgress ||
        oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.items != items;
  }
}
