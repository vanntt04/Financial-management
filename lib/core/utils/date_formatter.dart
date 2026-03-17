class DateFormatter {
  DateFormatter._();

  static const _weekdayNames = [
    '', // index 0 unused
    'Thứ Hai',
    'Thứ Ba',
    'Thứ Tư',
    'Thứ Năm',
    'Thứ Sáu',
    'Thứ Bảy',
    'Chủ Nhật',
  ];

  /// DateTime → "15/03/2026"
  static String toDisplay(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    return '$d/$m/${date.year}';
  }

  /// DateTime → "Thứ Hai, 15 tháng 3"
  static String toFullDisplay(DateTime date) {
    final weekday = _weekdayNames[date.weekday];
    return '$weekday, ${date.day} tháng ${date.month}';
  }

  /// DateTime → "Thứ Hai, 15 tháng 3, 2026"
  static String toFullDisplayWithYear(DateTime date) {
    final weekday = _weekdayNames[date.weekday];
    return '$weekday, ${date.day} tháng ${date.month}, ${date.year}';
  }

  /// DateTime → "2026-03-15T00:00:00" (ISO 8601 for API)
  static String toApi(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    final h = date.hour.toString().padLeft(2, '0');
    final min = date.minute.toString().padLeft(2, '0');
    final s = date.second.toString().padLeft(2, '0');
    return '${date.year}-$m-${d}T$h:$min:$s';
  }

  /// DateTime → "2026-03-15" (date only for API)
  static String toApiDate(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    return '${date.year}-$m-$d';
  }

  /// "2026-03-15" or ISO string → DateTime
  static DateTime? fromApi(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return null;
    return DateTime.tryParse(dateStr);
  }

  /// "tháng 3, 2026"
  static String toMonthYear(DateTime date) {
    return 'tháng ${date.month}, ${date.year}';
  }

  /// Relative: "Hôm nay", "Hôm qua", or date string
  static String toRelative(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diff = today.difference(target).inDays;
    if (diff == 0) return 'Hôm nay';
    if (diff == 1) return 'Hôm qua';
    return toDisplay(date);
  }
}
