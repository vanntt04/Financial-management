// lib/screens/transaction/add_transaction_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:financial_management/providers/finance_provider.dart';
import 'package:financial_management/models/category_model.dart';
import 'package:financial_management/models/account_model.dart';
import 'package:financial_management/utils/currency_formatter.dart';

// ── Tự động thêm dấu phân cách nghìn khi nhập số tiền ───────────────────────
class _ThousandsFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // Lấy chỉ chữ số
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return newValue.copyWith(text: '');
    final n = int.tryParse(digits) ?? 0;
    // Format 1000000 → 1.000.000
    final formatted = NumberFormat('#,###', 'vi_VN').format(n);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});
  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  final _amountCtrl = TextEditingController();
  final _noteCtrl   = TextEditingController();
  CategoryModel? _selectedCategory;
  AccountModel?  _selectedAccount;
  DateTime _selectedDate = DateTime.now();
  bool _isSaving    = false;
  bool _amountError = false;

  // Quick-add presets
  static const _quickAmounts = [10000, 50000, 100000, 500000, 1000000];

  String get _type => _tab.index == 0 ? 'EXPENSE' : 'INCOME';

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _tab.addListener(() => setState(() => _selectedCategory = null));
  }

  @override
  void dispose() {
    _tab.dispose();
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  // ── Quick-add amount ──────────────────────────────────────────────────
  void _addQuick(int amount) {
    final cur = int.tryParse(
        _amountCtrl.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    final next = cur + amount;
    _amountCtrl.text = NumberFormat('#,###', 'vi_VN').format(next);
    setState(() => _amountError = false);
  }

  // ── Date picker ───────────────────────────────────────────────────────
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  // ── Save ──────────────────────────────────────────────────────────────
  Future<void> _save() async {
    // Parse bỏ dấu phân cách → số thực
    final raw    = _amountCtrl.text.replaceAll(RegExp(r'[^0-9]'), '');
    final amount = double.tryParse(raw);

    if (amount == null || amount <= 0) {
      setState(() => _amountError = true);
      _snack('Vui lòng nhập số tiền hợp lệ', isError: true);
      return;
    }
    if (_selectedCategory == null) {
      _snack('Vui lòng chọn danh mục', isError: true);
      return;
    }

    setState(() => _isSaving = true);
    final ok = await context.read<FinanceProvider>().createTransaction(
      amount:   amount,
      type:     _type,
      category: _selectedCategory!,
      account:  _selectedAccount,
      note:     _noteCtrl.text.trim(),
      date:     _selectedDate,
    );
    if (mounted) {
      setState(() => _isSaving = false);
      if (ok) {
        _snack('Thêm giao dịch thành công!');
        Navigator.pop(context);
      } else {
        _snack('Lỗi khi thêm giao dịch', isError: true);
      }
    }
  }

  void _snack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? Colors.red : Colors.green,
      behavior: SnackBarBehavior.floating,
    ));
  }

  // ════════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final scheme  = Theme.of(context).colorScheme;
    final finance = context.watch<FinanceProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thêm giao dịch',
            style: TextStyle(fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tab,
          indicatorColor: scheme.primary,
          labelColor: scheme.primary,
          unselectedLabelColor: Colors.grey,
          tabs: const [Tab(text: 'CHI TIÊU'), Tab(text: 'THU NHẬP')],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          _buildForm(context, finance, 'EXPENSE'),
          _buildForm(context, finance, 'INCOME'),
        ],
      ),
    );
  }

  // ── Form ──────────────────────────────────────────────────────────────
  Widget _buildForm(BuildContext ctx, FinanceProvider finance, String type) {
    final scheme     = Theme.of(ctx).colorScheme;
    final isExpense  = type == 'EXPENSE';
    final typeColor  = isExpense ? Colors.red.shade700 : Colors.green.shade700;
    final typeBg     = isExpense ? Colors.red.shade50  : Colors.green.shade50;
    final categories = isExpense
        ? finance.expenseCategories
        : finance.incomeCategories;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [

        // ── Amount ─────────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          decoration: BoxDecoration(
              color: typeBg, borderRadius: BorderRadius.circular(16)),
          child: Column(children: [
            Text(isExpense ? 'Số tiền chi tiêu' : 'Số tiền thu nhập',
                style: TextStyle(color: typeColor, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            // Amount input
            TextField(
              controller: _amountCtrl,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              inputFormatters: [_ThousandsFormatter()],
              style: TextStyle(
                  fontSize: 36, fontWeight: FontWeight.bold, color: typeColor),
              onChanged: (_) => setState(() => _amountError = false),
              decoration: InputDecoration(
                hintText: '0',
                hintStyle: TextStyle(fontSize: 36, color: Colors.grey.shade300,
                    fontWeight: FontWeight.bold),
                suffixText: 'đ',
                suffixStyle: TextStyle(fontSize: 22, color: typeColor.withOpacity(0.6)),
                filled: false,
                border: _amountError
                    ? OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.red, width: 2))
                    : InputBorder.none,
                enabledBorder: _amountError
                    ? OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.red, width: 2))
                    : InputBorder.none,
                focusedBorder: InputBorder.none,
                errorText: _amountError ? '' : null,
                errorStyle: const TextStyle(height: 0),
              ),
            ),
            if (_amountError) ...[
              const SizedBox(height: 4),
              const Text('Vui lòng nhập số tiền',
                  style: TextStyle(color: Colors.red, fontSize: 12)),
            ],
            const SizedBox(height: 14),
            // Quick-amount chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _quickAmounts.map((amt) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => _addQuick(amt),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: typeColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: typeColor.withOpacity(0.3)),
                      ),
                      child: Text(
                        '+${NumberFormat('#,###', 'vi_VN').format(amt)}đ',
                        style: TextStyle(
                            color: typeColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 13),
                      ),
                    ),
                  ),
                )).toList(),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 16),

        // ── Date picker ─────────────────────────────────────────────────
        InkWell(
          onTap: _pickDate,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200)),
            child: Row(children: [
              Icon(Icons.calendar_today_outlined,
                  color: scheme.primary, size: 20),
              const SizedBox(width: 12),
              Text(DateFormat('dd/MM/yyyy').format(_selectedDate),
                  style: const TextStyle(fontWeight: FontWeight.w500)),
              const Spacer(),
              Icon(Icons.chevron_right, color: Colors.grey.shade400),
            ]),
          ),
        ),
        const SizedBox(height: 16),

        // ── Category grid ───────────────────────────────────────────────
        Text('Danh mục *',
            style: TextStyle(fontWeight: FontWeight.w600,
                color: Colors.grey.shade700)),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            childAspectRatio: 0.85,
            mainAxisSpacing: 10,
            crossAxisSpacing: 8,
          ),
          itemCount: categories.length,
          itemBuilder: (context, i) {
            final cat      = categories[i];
            final selected = _selectedCategory?.id == cat.id && _type == type;
            return GestureDetector(
              onTap: () => setState(() => _selectedCategory = cat),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                decoration: BoxDecoration(
                  color: selected ? scheme.primary : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: selected
                          ? scheme.primary
                          : Colors.grey.shade200,
                      width: selected ? 2 : 1),
                  boxShadow: selected ? [BoxShadow(
                      color: scheme.primary.withOpacity(0.3),
                      blurRadius: 8, offset: const Offset(0, 3))] : [],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(_iconData(cat.icon),
                        size: 24,
                        color: selected ? Colors.white : typeColor),
                    const SizedBox(height: 5),
                    Text(cat.name,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: selected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: selected
                              ? Colors.white
                              : Colors.grey.shade700,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 16),

        // ── Account dropdown ────────────────────────────────────────────
        if (finance.accounts.isNotEmpty) ...[
          Text('Hũ tiền (tùy chọn)',
              style: TextStyle(fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700)),
          const SizedBox(height: 10),
          DropdownButtonFormField<AccountModel?>(
            value: _selectedAccount,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.savings_outlined),
              hintText: 'Chọn hũ tiền',
            ),
            items: [
              const DropdownMenuItem(value: null, child: Text('Không chọn')),
              ...finance.accounts.map((a) => DropdownMenuItem(
                value: a,
                child: Text(
                    '${a.name}  —  ${CurrencyFormatter.format(a.balance)}',
                    overflow: TextOverflow.ellipsis),
              )),
            ],
            onChanged: (v) => setState(() => _selectedAccount = v),
          ),
          const SizedBox(height: 16),
        ],

        // ── Note ────────────────────────────────────────────────────────
        TextField(
          controller: _noteCtrl,
          maxLines: 2,
          decoration: const InputDecoration(
            labelText: 'Ghi chú (tùy chọn)',
            prefixIcon: Icon(Icons.notes_outlined),
            alignLabelWithHint: true,
          ),
        ),
        const SizedBox(height: 28),

        // ── Save button ─────────────────────────────────────────────────
        SizedBox(
          height: 54,
          child: FilledButton.icon(
            onPressed: _isSaving ? null : _save,
            style: FilledButton.styleFrom(
              backgroundColor: typeColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            icon: _isSaving
                ? const SizedBox(
                width: 20, height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.check_circle_outline_rounded),
            label: Text(
                _isSaving
                    ? 'Đang lưu...'
                    : isExpense ? 'LƯU CHI TIÊU' : 'LƯU THU NHẬP',
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.bold,
                    letterSpacing: 0.5)),
          ),
        ),
        const SizedBox(height: 20),
      ]),
    );
  }

  // ── Icon map ──────────────────────────────────────────────────────────
  IconData _iconData(String? name) {
    switch (name) {
      case 'restaurant':         return Icons.restaurant_rounded;
      case 'shopping_cart':      return Icons.shopping_cart_rounded;
      case 'directions_car':     return Icons.directions_car_rounded;
      case 'home':               return Icons.home_rounded;
      case 'school':             return Icons.school_rounded;
      case 'movie':              return Icons.movie_rounded;
      case 'health_and_safety':  return Icons.health_and_safety_rounded;
      case 'attach_money':       return Icons.attach_money_rounded;
      case 'card_giftcard':      return Icons.card_giftcard_rounded;
      case 'savings':            return Icons.savings_rounded;
      case 'trending_up':        return Icons.trending_up_rounded;
      case 'volunteer_activism': return Icons.volunteer_activism_rounded;
      case 'more_horiz':         return Icons.more_horiz_rounded;
      default:                   return Icons.label_outline_rounded;
    }
  }
}
