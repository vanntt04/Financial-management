import 'package:intl/intl.dart';

class CurrencyFormatter {
  static String format(num amount) {
    final String numStr = amount.abs().toStringAsFixed(0);
    final buffer = StringBuffer();
    final int length = numStr.length;

    for (int i = 0; i < length; i++) {
      if (i > 0 && (length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(numStr[i]);
    }

    return '${buffer.toString()} đ';
  }
}