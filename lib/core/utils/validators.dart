class Validators {
  Validators._();

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập email';
    }
    final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Email không hợp lệ';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập mật khẩu';
    }
    if (value.length < 6) {
      return 'Mật khẩu phải có ít nhất 6 ký tự';
    }
    return null;
  }

  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng xác nhận mật khẩu';
    }
    if (value != password) {
      return 'Mật khẩu xác nhận không khớp';
    }
    return null;
  }

  static String? validateNotEmpty(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập $fieldName';
    }
    return null;
  }

  static String? validatePhoneVN(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập số điện thoại';
    }
    final phoneRegex = RegExp(r'^(0|\+84)(3|5|7|8|9)\d{8}$');
    if (!phoneRegex.hasMatch(value.trim())) {
      return 'Số điện thoại không hợp lệ';
    }
    return null;
  }

  static String? validateAmount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập số tiền';
    }
    // Remove formatting characters before parsing
    final cleaned = value.replaceAll(RegExp(r'[^\d.]'), '');
    final amount = double.tryParse(cleaned);
    if (amount == null || amount <= 0) {
      return 'Số tiền phải lớn hơn 0';
    }
    return null;
  }

  static String? validatePercentage(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập tỷ lệ phân bổ';
    }
    final pct = double.tryParse(value.trim());
    if (pct == null || pct < 0 || pct > 100) {
      return 'Tỷ lệ phải từ 0 đến 100';
    }
    return null;
  }
}
