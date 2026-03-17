class AppStrings {
  AppStrings._();

  static const String appName = 'Financial Management';

  // Auth
  static const String login = 'Đăng nhập';
  static const String register = 'Đăng ký';
  static const String logout = 'Đăng xuất';
  static const String email = 'Email';
  static const String password = 'Mật khẩu';
  static const String confirmPassword = 'Xác nhận mật khẩu';
  static const String fullName = 'Họ và tên';
  static const String forgotPassword = 'Quên mật khẩu?';
  static const String changePassword = 'Đổi mật khẩu';
  static const String verifyOtp = 'Xác thực OTP';
  static const String resendOtp = 'Gửi lại OTP';

  // Navigation
  static const String home = 'Trang chủ';
  static const String transactions = 'Giao dịch';
  static const String reports = 'Báo cáo';
  static const String settings = 'Cài đặt';

  // Transaction
  static const String income = 'Thu nhập';
  static const String expense = 'Chi tiêu';
  static const String transfer = 'Chuyển khoản';
  static const String transaction = 'Giao dịch';
  static const String addTransaction = 'Thêm giao dịch';
  static const String amount = 'Số tiền';
  static const String note = 'Ghi chú';
  static const String date = 'Ngày';

  // Category
  static const String category = 'Danh mục';
  static const String categories = 'Danh mục';
  static const String addCategory = 'Thêm danh mục';
  static const String categoryName = 'Tên danh mục';
  static const String categoryType = 'Loại danh mục';

  // Account / Jar
  static const String account = 'Tài khoản';
  static const String accounts = 'Hũ / Quỹ';
  static const String jar = 'Hũ';
  static const String addAccount = 'Thêm hũ';
  static const String editAccount = 'Chỉnh sửa hũ';
  static const String accountName = 'Tên hũ';
  static const String balance = 'Số dư';
  static const String allocationPercentage = 'Tỷ lệ phân bổ (%)';
  static const String savingGoal = 'Mục tiêu tiết kiệm';
  static const String targetAmount = 'Số tiền mục tiêu';
  static const String targetDate = 'Ngày hoàn thành';
  static const String fromAccount = 'Từ hũ';
  static const String toAccount = 'Đến hũ';

  // Common actions
  static const String save = 'Lưu';
  static const String cancel = 'Hủy';
  static const String delete = 'Xóa';
  static const String edit = 'Chỉnh sửa';
  static const String confirm = 'Xác nhận';
  static const String retry = 'Thử lại';
  static const String add = 'Thêm';
  static const String update = 'Cập nhật';
  static const String search = 'Tìm kiếm';
  static const String filter = 'Lọc';

  // Errors
  static const String errorConnection = 'Không thể kết nối tới server';
  static const String errorTimeout = 'Kết nối quá thời gian';
  static const String errorUnknown = 'Lỗi không xác định';
  static const String errorRequired = 'Vui lòng nhập trường này';
  static const String errorInvalidEmail = 'Email không hợp lệ';
  static const String errorPasswordTooShort =
      'Mật khẩu phải có ít nhất 6 ký tự';
  static const String errorPasswordMismatch = 'Mật khẩu xác nhận không khớp';
  static const String errorInvalidPhone = 'Số điện thoại không hợp lệ';
  static const String errorInvalidAmount = 'Số tiền phải lớn hơn 0';

  // Success
  static const String successSaved = 'Đã lưu thành công';
  static const String successDeleted = 'Đã xóa thành công';
  static const String successTransfer = 'Chuyển khoản thành công';

  // Dialogs
  static const String deleteConfirmTitle = 'Xác nhận xóa';
  static const String deleteConfirmMessage =
      'Bạn có chắc chắn muốn xóa mục này không?';

  // Empty states
  static const String emptyCategories = 'Không có danh mục nào';
  static const String emptyAccounts = 'Chưa có hũ nào';
  static const String emptyTransactions = 'Chưa có giao dịch nào';
}
