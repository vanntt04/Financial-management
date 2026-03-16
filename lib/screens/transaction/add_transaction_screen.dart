import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/finance_provider.dart';
import '../../services/api_service.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _amountController = TextEditingController();
  final _titleController = TextEditingController();

  String _selectedType = 'Chi tiêu';
  String? _selectedCategoryName;
  ApiCategory? _selectedCategory;
  ApiAccount? _selectedAccount;
  DateTime _selectedDate = DateTime.now();
  bool _isSaving = false;
  bool _isLoading = false;
  bool _isInitialized = false;

  // Map để lưu mapping giữa tên hiển thị và category object
  Map<String, ApiCategory> _categoryMap = {};

  // Fallback icons - chỉ dùng để hiển thị icon
  final Map<String, IconData> _categoryIcons = {
    'Ăn uống': Icons.restaurant,
    'Mua sắm': Icons.shopping_cart,
    'Nhà cửa': Icons.home,
    'Học tập': Icons.school,
    'Di chuyển': Icons.directions_car,
    'Giải trí': Icons.movie,
    'Y tế': Icons.health_and_safety,
    'Lương': Icons.attach_money,
    'Thưởng': Icons.card_giftcard,
    'Tiền lãi': Icons.savings,
    'Tiền vào': Icons.trending_up,
    'Được cho/tặng': Icons.volunteer_activism,
    'Khác': Icons.more_horiz,
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  Future<void> _initializeData() async {
    if (_isInitialized) return;

    setState(() => _isLoading = true);

    final provider = context.read<FinanceProvider>();

    try {
      // Load accounts và categories
      await Future.wait([
        provider.loadAccounts(),
        provider.loadCategories(type: 'EXPENSE'),
      ]);

      if (!mounted) return;

      // Cập nhật category map
      _updateCategoryMap(provider);

      setState(() {
        if (provider.accounts.isNotEmpty) {
          _selectedAccount = provider.accounts.first;
        }
        _isInitialized = true;
        _isLoading = false;
      });

      debugPrint('Initialized with ${provider.categories.length} categories');
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showSnack('Lỗi tải dữ liệu: ${e.toString()}', Colors.red);
      }
    }
  }

  // Cập nhật map category để tìm kiếm dễ dàng
  void _updateCategoryMap(FinanceProvider provider) {
    _categoryMap = {};
    for (var category in provider.categories) {
      // Lưu với nhiều phiên bản tên để dễ tìm kiếm
      _categoryMap[category.categoryName] = category;
      _categoryMap[category.categoryName.toLowerCase()] = category;
      _categoryMap[category.categoryName.trim()] = category;
      _categoryMap[category.categoryName.toLowerCase().trim()] = category;

      // Loại bỏ dấu tiếng Việt nếu cần
      final withoutDiacritics = _removeDiacritics(category.categoryName);
      _categoryMap[withoutDiacritics] = category;
      _categoryMap[withoutDiacritics.toLowerCase()] = category;
    }
  }

  // Hàm loại bỏ dấu tiếng Việt
  String _removeDiacritics(String str) {
    const withDiacritics = 'áàảãạăắằẳẵặâấầẩẫậđéèẻẽẹêếềểễệíìỉĩịóòỏõọôốồổỗộơớờởỡợúùủũụưứừửữựýỳỷỹỵ';
    const withoutDiacritics = 'aaaaaaaaaaaaaaaaadeeeeeeeeeeeeiiiiiooooooooooooooooouuuuuuuuuuuyyyyy';

    String result = str;
    for (int i = 0; i < withDiacritics.length; i++) {
      result = result.replaceAll(withDiacritics[i], withoutDiacritics[i]);
    }
    return result;
  }

  Future<void> _onTypeChanged(String newType) async {
    if (newType == _selectedType) return;

    setState(() {
      _selectedType = newType;
      _selectedCategory = null;
      _selectedCategoryName = null;
      _isLoading = true;
      _categoryMap = {}; // Reset map
    });

    final provider = context.read<FinanceProvider>();

    try {
      await provider.loadCategories(
        type: newType == 'Thu nhập' ? 'INCOME' : 'EXPENSE',
      );

      if (!mounted) return;

      // Cập nhật lại category map
      _updateCategoryMap(provider);

      setState(() => _isLoading = false);

      debugPrint('Loaded ${provider.categories.length} categories for type: $newType');

      // Nếu không có categories nào, hiển thị thông báo
      if (provider.categories.isEmpty) {
        _showSnack('Không có danh mục nào cho loại giao dịch này', Colors.orange);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showSnack('Lỗi tải danh mục: ${e.toString()}', Colors.red);
      }
    }
  }

  Future<void> _save() async {
    // Validate số tiền
    final raw = _amountController.text.replaceAll('.', '').replaceAll(',', '');
    final amount = double.tryParse(raw);

    if (amount == null || amount <= 0) {
      _showSnack('Vui lòng nhập số tiền hợp lệ', Colors.red);
      return;
    }

    // Validate danh mục
    if (_selectedCategoryName == null) {
      _showSnack('Vui lòng chọn hạng mục', Colors.red);
      return;
    }

    // Validate tài khoản
    if (_selectedAccount == null) {
      _showSnack('Vui lòng chọn tài khoản', Colors.red);
      return;
    }

    // Tìm category nếu chưa có
    if (_selectedCategory == null) {
      final provider = context.read<FinanceProvider>();

      // Thử tìm category trong map
      _selectedCategory = _findCategory(_selectedCategoryName!);

      // Nếu vẫn không tìm thấy, thử tìm trong provider categories
      if (_selectedCategory == null) {
        for (var category in provider.categories) {
          if (_isNameMatch(category.categoryName, _selectedCategoryName!)) {
            _selectedCategory = category;
            break;
          }
        }
      }

      if (_selectedCategory == null) {
        _showSnack('Không tìm thấy danh mục "${_selectedCategoryName}" trong hệ thống', Colors.red);
        return;
      }
    }

    setState(() => _isSaving = true);

    try {
      final success = await context.read<FinanceProvider>().createTransaction(
        amount: amount,
        accountId: _selectedAccount!.accountId,
        categoryId: _selectedCategory!.categoryId,
        transactionType: _selectedType == 'Thu nhập' ? 'INCOME' : 'EXPENSE',
        transactionDate: _selectedDate,
      );

      if (success && mounted) {
        _showSnack('Đã lưu giao dịch!', Colors.green);
        Navigator.pop(context);
      } else if (mounted) {
        _showSnack('Lưu thất bại, thử lại', Colors.red);
      }
    } catch (e) {
      if (mounted) {
        _showSnack('Lỗi: ${e.toString()}', Colors.red);
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // Tìm category theo nhiều cách
  ApiCategory? _findCategory(String categoryName) {
    final provider = context.read<FinanceProvider>();

    // Tìm chính xác
    var match = provider.categories.where((c) =>
    c.categoryName == categoryName
    ).firstOrNull;

    if (match != null) return match;

    // Tìm không phân biệt hoa thường
    match = provider.categories.where((c) =>
    c.categoryName.toLowerCase() == categoryName.toLowerCase()
    ).firstOrNull;

    if (match != null) return match;

    // Tìm chứa từ khóa
    match = provider.categories.where((c) =>
    c.categoryName.toLowerCase().contains(categoryName.toLowerCase()) ||
        categoryName.toLowerCase().contains(c.categoryName.toLowerCase())
    ).firstOrNull;

    return match;
  }

  // Kiểm tra tên có khớp không
  bool _isNameMatch(String dbName, String selectedName) {
    if (dbName == selectedName) return true;
    if (dbName.toLowerCase() == selectedName.toLowerCase()) return true;
    if (_removeDiacritics(dbName).toLowerCase() ==
        _removeDiacritics(selectedName).toLowerCase()) return true;
    return false;
  }

  void _showSnack(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _addQuickAmount(int amount) {
    final current = int.tryParse(
        _amountController.text.replaceAll('.', '').replaceAll(',', '')) ?? 0;
    _amountController.text = _fmtInt(current + amount);
    _amountController.selection =
        TextSelection.collapsed(offset: _amountController.text.length);
  }

  String _fmtInt(int v) => v
      .toString()
      .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  String _formatDate(DateTime d) => '${d.day}/${d.month}/${d.year}';

  @override
  void dispose() {
    _amountController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  // Lấy danh sách categories để hiển thị
  List<Map<String, dynamic>> _getDisplayCategories(FinanceProvider provider) {
    if (provider.categories.isNotEmpty) {
      return provider.categories.map((c) => {
        'name': c.categoryName,
        'icon': _categoryIcons[c.categoryName] ??
            _categoryIcons['Khác'] ??
            Icons.category,
        'category': c,
      }).toList();
    }

    // Nếu đang loading, hiển thị skeleton
    if (_isLoading) {
      return _getFallbackCategories();
    }

    // Nếu không có categories từ API, dùng fallback
    return _getFallbackCategories();
  }

  List<Map<String, dynamic>> _getFallbackCategories() {
    if (_selectedType == 'Thu nhập') {
      return [
        'Lương', 'Thưởng', 'Tiền lãi', 'Tiền vào', 'Được cho/tặng', 'Khác'
      ].map((name) => {
        'name': name,
        'icon': _categoryIcons[name] ?? Icons.attach_money,
        'category': null,
      }).toList();
    } else {
      return [
        'Ăn uống', 'Mua sắm', 'Nhà cửa', 'Học tập',
        'Di chuyển', 'Giải trí', 'Y tế', 'Khác'
      ].map((name) => {
        'name': name,
        'icon': _categoryIcons[name] ?? Icons.more_horiz,
        'category': null,
      }).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FinanceProvider>(
      builder: (context, provider, _) {
        final displayCategories = _getDisplayCategories(provider);

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'Thêm giao dịch',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w500,
                fontSize: 18,
              ),
            ),
            actions: [
              if (_isSaving || _isLoading)
                const Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              else
                IconButton(
                  icon: const Icon(Icons.check, color: Colors.black),
                  onPressed: _save,
                ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Số tiền
                const Text(
                  'Số tiền',
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
                TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black26),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                    contentPadding: EdgeInsets.symmetric(vertical: 8),
                  ),
                  onChanged: (value) {
                    final raw = value.replaceAll('.', '').replaceAll(',', '');
                    final n = int.tryParse(raw);
                    if (n != null) {
                      final fmt = _fmtInt(n);
                      if (fmt != value) {
                        _amountController.value = TextEditingValue(
                          text: fmt,
                          selection: TextSelection.collapsed(offset: fmt.length),
                        );
                      }
                    }
                  },
                ),
                const SizedBox(height: 12),

                // Quick amounts
                Row(
                  children: [
                    _QuickAmountChip(
                      label: '10.000 đ',
                      onTap: () => _addQuickAmount(10000),
                    ),
                    const SizedBox(width: 8),
                    _QuickAmountChip(
                      label: '100.000 đ',
                      onTap: () => _addQuickAmount(100000),
                    ),
                    const SizedBox(width: 8),
                    _QuickAmountChip(
                      label: '1.000.000 đ',
                      onTap: () => _addQuickAmount(1000000),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Tiêu đề
                const Text(
                  'Tiêu đề',
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
                TextField(
                  controller: _titleController,
                  style: const TextStyle(fontSize: 16),
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black26),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                    contentPadding: EdgeInsets.symmetric(vertical: 8),
                    hintText: 'Nhập mô tả (không bắt buộc)',
                  ),
                ),
                const SizedBox(height: 16),

                // Loại giao dịch
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedType,
                      isExpanded: true,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                      items: ['Thu nhập', 'Chi tiêu'].map((t) {
                        return DropdownMenuItem(
                          value: t,
                          child: Text(t),
                        );
                      }).toList(),
                      onChanged: _isLoading
                          ? null
                          : (String? value) {
                        if (value != null) {
                          _onTypeChanged(value);
                        }
                      },
                    ),
                  ),
                ),

                // Tài khoản
                if (provider.accounts.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<ApiAccount>(
                        value: _selectedAccount,
                        isExpanded: true,
                        hint: const Text('Chọn tài khoản / hũ'),
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.black,
                        ),
                        items: provider.accounts.map((a) {
                          return DropdownMenuItem(
                            value: a,
                            child: Text(a.accountName),
                          );
                        }).toList(),
                        onChanged: (v) => setState(() => _selectedAccount = v),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 20),

                // Hạng mục
                Row(
                  children: [
                    const Text(
                      'Chọn hạng mục',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    if (_isLoading) ...[
                      const SizedBox(width: 8),
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 12),

                // Grid danh mục
                if (provider.categories.isEmpty && !_isLoading)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.category_outlined,
                            size: 48,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Không có danh mục nào',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                          TextButton(
                            onPressed: () => _onTypeChanged(_selectedType),
                            child: const Text('Thử lại'),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  GridView.count(
                    crossAxisCount: 4,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 0.95,
                    children: displayCategories.map((cat) {
                      final name = cat['name'] as String;
                      final icon = cat['icon'] as IconData;
                      final isSelected = _selectedCategoryName == name;
                      final hasCategory = cat['category'] != null;

                      return GestureDetector(
                        onTap: _isLoading ? null : () {
                          setState(() {
                            _selectedCategoryName = name;
                            if (cat['category'] != null) {
                              _selectedCategory = cat['category'] as ApiCategory;
                            } else {
                              // Thử tìm category trong provider
                              _selectedCategory = _findCategory(name);
                            }
                          });

                          // Thông báo nếu chọn category từ fallback
                          if (!hasCategory && _selectedCategory == null) {
                            _showSnack(
                                'Danh mục "$name" chưa được đồng bộ. Vui lòng tạo danh mục trước.',
                                Colors.orange
                            );
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.blue.shade50
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                            border: isSelected
                                ? Border.all(color: Colors.blue, width: 1.5)
                                : null,
                          ),
                          child: Opacity(
                            opacity: _isLoading ? 0.5 : 1.0,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Icon(
                                      icon,
                                      size: 26,
                                      color: isSelected
                                          ? Colors.blue
                                          : Colors.grey.shade600,
                                    ),
                                    if (!hasCategory)
                                      Positioned(
                                        top: -2,
                                        right: -2,
                                        child: Container(
                                          width: 8,
                                          height: 8,
                                          decoration: const BoxDecoration(
                                            color: Colors.orange,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  name,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isSelected
                                        ? Colors.blue
                                        : Colors.grey.shade700,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (!hasCategory)
                                  Text(
                                    'chưa đồng bộ',
                                    style: TextStyle(
                                      fontSize: 8,
                                      color: Colors.orange.shade700,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                const SizedBox(height: 20),

                // Ngày
                InkWell(
                  onTap: _pickDate,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 22,
                          color: Colors.black54,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _formatDate(_selectedDate),
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.black87,
                          ),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.chevron_right,
                          size: 22,
                          color: Colors.black45,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _QuickAmountChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _QuickAmountChip({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black26),
          borderRadius: BorderRadius.circular(6),
          color: Colors.white,
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 13, color: Colors.black87),
        ),
      ),
    );
  }
}