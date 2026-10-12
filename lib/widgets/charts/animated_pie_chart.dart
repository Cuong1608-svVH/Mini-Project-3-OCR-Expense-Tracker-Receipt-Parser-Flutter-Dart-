import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/currency_formatter.dart';

class PieChartSectionData {
  final String key;
  final String label;
  final double value;
  final Color color;

  PieChartSectionData({
    required this.key,
    required this.label,
    required this.value,
    required this.color,
  });
}

class AnimatedPieChart extends StatefulWidget {
  final List<PieChartSectionData> sections;
  final double totalAmount;
  final double height;

  const AnimatedPieChart({
    super.key,
    required this.sections,
    required this.totalAmount,
    this.height = 280,
  });

  @override
  State<AnimatedPieChart> createState() => _AnimatedPieChartState();
}

class _AnimatedPieChartState extends State<AnimatedPieChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int? _selectedSectionIndex;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant AnimatedPieChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.sections != widget.sections ||
        oldWidget.totalAmount != widget.totalAmount) {
      _controller.forward(from: 0.0);
      _selectedSectionIndex = null;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap(Offset localPosition, Size size) {
    if (widget.totalAmount <= 0 || widget.sections.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final dx = localPosition.dx - center.dx;
    final dy = localPosition.dy - center.dy;
    final distance = math.sqrt(dx * dx + dy * dy);

    final outerRadius = math.min(size.width, size.height) / 2 * 0.9;
    final innerRadius = outerRadius * 0.58;

    // Chỉ nhận diện tap khi nằm trong vành donut (hoặc vùng trung tâm)
    if (distance < innerRadius) {
      // Tap ở giữa để bỏ chọn
      setState(() {
        _selectedSectionIndex = null;
      });
      return;
    }

    if (distance > outerRadius + 15) return;

    // Góc từ -pi đến pi, chuyển về [0, 2*pi) bắt đầu từ hướng -pi/2 (12 giờ)
    double angle = math.atan2(dy, dx) + (math.pi / 2);
    if (angle < 0) angle += 2 * math.pi;

    double currentAngle = 0;
    for (int i = 0; i < widget.sections.length; i++) {
      final sweepAngle = (widget.sections[i].value / widget.totalAmount) * 2 * math.pi;
      if (angle >= currentAngle && angle <= currentAngle + sweepAngle) {
        setState(() {
          _selectedSectionIndex = (_selectedSectionIndex == i) ? null : i;
        });
        return;
      }
      currentAngle += sweepAngle;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.sections.isEmpty || widget.totalAmount <= 0) {
      return SizedBox(
        height: widget.height,
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.pie_chart_outline, size: 48, color: AppTheme.textMuted),
              SizedBox(height: 8),
              Text(
                'Chưa có dữ liệu chi tiêu trong kỳ này',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    final selectedSection = _selectedSectionIndex != null &&
            _selectedSectionIndex! < widget.sections.length
        ? widget.sections[_selectedSectionIndex!]
        : null;

    return Column(
      children: [
        SizedBox(
          height: widget.height,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final size = Size(constraints.maxWidth, constraints.maxHeight);
              return GestureDetector(
                onTapUp: (details) => _handleTap(details.localPosition, size),
                child: AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return CustomPaint(
                      size: size,
                      painter: _PieChartPainter(
                        sections: widget.sections,
                        totalAmount: widget.totalAmount,
                        animationProgress: _animation.value,
                        selectedIndex: _selectedSectionIndex,
                      ),
                      child: Center(
                        child: _buildCenterLabel(selectedSection),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        // Chú thích danh mục có thể bấm chọn
        Wrap(
          spacing: 12,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: List.generate(widget.sections.length, (index) {
            final section = widget.sections[index];
            final percent = (section.value / widget.totalAmount * 100);
            final isSelected = _selectedSectionIndex == index;

            return InkWell(
              onTap: () {
                setState(() {
                  _selectedSectionIndex = isSelected ? null : index;
                });
              },
              borderRadius: BorderRadius.circular(8),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected
                      ? section.color.withOpacity(0.18)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? section.color : Colors.transparent,
                    width: 1.2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: section.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${section.label} (${percent.toStringAsFixed(1)}%)',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? section.color : AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildCenterLabel(PieChartSectionData? selected) {
    if (selected != null) {
      final percent = (selected.value / widget.totalAmount * 100);
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            selected.label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            CurrencyFormatter.formatVnd(selected.value),
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: selected.color,
            ),
          ),
          Text(
            '${percent.toStringAsFixed(1)}%',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Tổng chi',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          CurrencyFormatter.formatVnd(widget.totalAmount),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
          ),
        ),
        const Text(
          'Chạm để xem',
          style: TextStyle(
            fontSize: 10,
            color: AppTheme.textMuted,
          ),
        ),
      ],
    );
  }
}

class _PieChartPainter extends CustomPainter {
  final List<PieChartSectionData> sections;
  final double totalAmount;
  final double animationProgress;
  final int? selectedIndex;

  _PieChartPainter({
    required this.sections,
    required this.totalAmount,
    required this.animationProgress,
    this.selectedIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = math.min(size.width, size.height) / 2 * 0.9;
    final innerRadius = outerRadius * 0.58;

    double startAngle = -math.pi / 2; // Bắt đầu ở đỉnh 12 giờ
    final totalSweepTarget = 2 * math.pi * animationProgress;

    double accumulatedAngle = 0.0;

    for (int i = 0; i < sections.length; i++) {
      final section = sections[i];
      final sectionProportion = section.value / totalAmount;
      final fullSweepAngle = sectionProportion * 2 * math.pi;

      // Tính góc sweep thực tế dựa trên tiến độ animation
      if (accumulatedAngle >= totalSweepTarget) break;

      double sweepAngle = fullSweepAngle;
      if (accumulatedAngle + fullSweepAngle > totalSweepTarget) {
        sweepAngle = totalSweepTarget - accumulatedAngle;
      }

      final isSelected = selectedIndex == i;
      final currentOuterRadius = isSelected ? outerRadius + 8 : outerRadius;
      final currentInnerRadius = isSelected ? innerRadius - 2 : innerRadius;

      // Tính độ lệch tâm khi được chọn (hiệu ứng bùng nổ nhẹ)
      Offset sectionCenter = center;
      if (isSelected) {
        final midAngle = startAngle + (sweepAngle / 2);
        sectionCenter = Offset(
          center.dx + math.cos(midAngle) * 6,
          center.dy + math.sin(midAngle) * 6,
        );
      }

      final path = Path();
      // Điểm bắt đầu trên vòng ngoài
      path.arcTo(
        Rect.fromCircle(center: sectionCenter, radius: currentOuterRadius),
        startAngle,
        sweepAngle,
        false,
      );
      // Nối về vòng trong
      path.arcTo(
        Rect.fromCircle(center: sectionCenter, radius: currentInnerRadius),
        startAngle + sweepAngle,
        -sweepAngle,
        false,
      );
      path.close();

      // Vẽ đổ bóng mềm nếu được chọn
      if (isSelected) {
        final shadowPaint = Paint()
          ..color = section.color.withOpacity(0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
        canvas.drawPath(path, shadowPaint);
      }

      final paint = Paint()
        ..color = section.color
        ..style = PaintingStyle.fill
        ..isAntiAlias = true;

      canvas.drawPath(path, paint);

      // Viền phân tách các lát cắt
      final borderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      canvas.drawPath(path, borderPaint);

      startAngle += sweepAngle;
      accumulatedAngle += fullSweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _PieChartPainter oldDelegate) {
    return oldDelegate.animationProgress != animationProgress ||
        oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.totalAmount != totalAmount ||
        oldDelegate.sections != sections;
  }
}
