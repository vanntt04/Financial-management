class CurrencyFormatter {
  CurrencyFormatter._();

  /// Formats a number to Vietnamese currency string.
  /// Example: 1500000 → "1.500.000 ₫"
  static String format(double amount) {
    final String numStr = amount.abs().toStringAsFixed(0);
    final buffer = StringBuffer();
    final int length = numStr.length;
    for (int i = 0; i < length; i++) {
      if (i > 0 && (length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(numStr[i]);
    }
    final result = '${buffer.toString()} ₫';
    return amount < 0 ? '-$result' : result;
  }

  /// Compact format for large numbers.
  /// Example: 1500000 → "1.5 triệu ₫"
  static String formatCompact(double amount) {
    if (amount.abs() >= 1000000000) {
      return '${(amount / 1000000000).toStringAsFixed(1)} tỷ ₫';
    }
    if (amount.abs() >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)} triệu ₫';
    }
    return format(amount);
  }

  /// Parses formatted Vietnamese currency string back to double.
  /// Example: "1.500.000 ₫" → 1500000.0
  static double parse(String formatted) {
    final cleaned = formatted
        .replaceAll('₫', '')
        .replaceAll('đ', '')
        .replaceAll('.', '')
        .replaceAll(',', '.')
        .trim();
    return double.tryParse(cleaned) ?? 0.0;
  }
}
