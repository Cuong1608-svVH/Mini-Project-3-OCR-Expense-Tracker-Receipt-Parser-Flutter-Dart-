import 'package:intl/intl.dart';

class DateFormatter {
  static final DateFormat _dayMonthYearFormat = DateFormat('dd/MM/yyyy');
  static final DateFormat _timeFormat = DateFormat('HH:mm');
  static final DateFormat _monthYearFormat = DateFormat('MM/yyyy');

  static String formatDayMonthYear(DateTime date) {
    return _dayMonthYearFormat.format(date);
  }

  static String formatTime(DateTime date) {
    return _timeFormat.format(date);
  }

  static String formatMonthYear(DateTime date) {
    return _monthYearFormat.format(date);
  }

  /// Lấy thứ trong tuần tiếng Việt
  static String getWeekdayVietnamese(DateTime date) {
    switch (date.weekday) {
      case DateTime.monday:
        return 'Thứ Hai';
      case DateTime.tuesday:
        return 'Thứ Ba';
      case DateTime.wednesday:
        return 'Thứ Tư';
      case DateTime.thursday:
        return 'Thứ Năm';
      case DateTime.friday:
        return 'Thứ Sáu';
      case DateTime.saturday:
        return 'Thứ Bảy';
      case DateTime.sunday:
        return 'Chủ Nhật';
      default:
        return '';
    }
  }

  /// Định dạng tiêu đề nhóm ngày phong cách MISA (ví dụ: Thứ Hai, 12/10/2026)
  static String formatMisaDayHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);

    if (target == today) {
      return 'Hôm nay, ${_dayMonthYearFormat.format(date)}';
    } else if (target == today.subtract(const Duration(days: 1))) {
      return 'Hôm qua, ${_dayMonthYearFormat.format(date)}';
    } else {
      return '${getWeekdayVietnamese(date)}, ${_dayMonthYearFormat.format(date)}';
    }
  }

  /// Khóa gom nhóm ngày theo chuỗi YYYY-MM-DD
  static String getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
