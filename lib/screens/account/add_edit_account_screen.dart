// lib/screens/account/add_edit_account_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:financial_management/models/account_model.dart';
import 'package:financial_management/providers/finance_provider.dart';
import 'package:financial_management/utils/currency_formatter.dart';


class AddEditAccountScreen extends StatefulWidget {
  const AddEditAccountScreen({super.key});
  @override
  State<AddEditAccountScreen> createState() => _AddEditAccountScreenState();
}

class _AddEditAccountScreenState extends State<AddEditAccountScreen> {
  AccountModel? _editAccount;
  final _nameCtrl = TextEditingController();
  final _balanceCtrl = TextEditingController(text: '0');
  final _allocCtrl = TextEditingController();
  final _targetCtrl = TextEditingController();
  bool _isGoalActive = false;
  bool _isSaving = false;
  bool _isInit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      _editAccount =
          ModalRoute.of(context)!.settings.arguments as AccountModel?;
      if (_editAccount != null) {
        _nameCtrl.text = _editAccount!.name;
        _balanceCtrl.text = _editAccount!.balance.toStringAsFixed(0);
        _allocCtrl.text =
            _editAccount!.allocationPercent?.toStringAsFixed(0) ?? '';
        _targetCtrl.text =
            _editAccount!.targetAmount?.toStringAsFixed(0) ?? '';
        _isGoalActive = _editAccount!.isGoalActive;
      }
      _isInit = true;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _balanceCtrl.dispose();
    _allocCtrl.dispose();
    _targetCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty) {
      _snack('Vui lòng nhập tên hũ', isError: true);
      return;
    }
    setState(() => _isSaving = true);
    final finance = context.read<FinanceProvider>();
    bool ok;
    if (_editAccount == null) {
      ok = await finance.createAccount(
        name: _nameCtrl.text.trim(),
        balance:
            double.tryParse(_balanceCtrl.text.replaceAll(',', '')) ?? 0,
        allocationPercent:
            double.tryParse(_allocCtrl.text.replaceAll(',', '')),
        isGoalActive: _isGoalActive,
        targetAmount: _isGoalActive
            ? double.tryParse(_targetCtrl.text.replaceAll(',', ''))
            : null,
      );
    } else {
      ok = await finance.updateAccount(
        _editAccount!,
        name: _nameCtrl.text.trim(),
        allocationPercent:
            double.tryParse(_allocCtrl.text.replaceAll(',', '')),
        isGoalActive: _isGoalActive,
        targetAmount: _isGoalActive
            ? double.tryParse(_targetCtrl.text.replaceAll(',', ''))
            : null,
      );
    }
    if (mounted) {
      setState(() => _isSaving = false);
      if (ok) {
        _snack(_editAccount == null
            ? 'Tạo hũ tiền thành công!'
            : 'Cập nhật thành công!');
        Navigator.pop(context);
      } else {
        _snack('Lỗi. Vui lòng thử lại.', isError: true);
      }
    }
  }

  void _snack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? Colors.red : Colors.green,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isEdit = _editAccount != null;
    final finance = context.watch<FinanceProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Chỉnh sửa hũ tiền' : 'Thêm hũ tiền',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: isEdit
            ? [
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => _confirmDelete(context),
                ),
              ]
            : null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Existing accounts overview (only on add)
            if (!isEdit && finance.accounts.isNotEmpty) ...[
              const Text('Hũ tiền hiện có',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey)),
              const SizedBox(height: 8),
              ...finance.accounts.map((a) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.savings_outlined,
                            color: scheme.primary, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                            child: Text(a.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500))),
                        Text(CurrencyFormatter.format(a.balance),
                            style: TextStyle(
                                color: scheme.primary,
                                fontWeight: FontWeight.bold)),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 18),
                          onPressed: () => Navigator.pushNamed(
                              context, '/add-edit-account',
                              arguments: a),
                        ),
                      ],
                    ),
                  )),
              const Divider(height: 24),
              const Text('Thêm hũ mới',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey)),
              const SizedBox(height: 12),
            ],

            // Name
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Tên hũ tiền *',
                prefixIcon: Icon(Icons.savings_outlined),
                hintText: 'VD: Chi tiêu hàng ngày, Tiết kiệm...',
              ),
            ),
            const SizedBox(height: 16),

            // Balance (only for create)
            if (!isEdit)
              TextFormField(
                controller: _balanceCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Số dư ban đầu (đ)',
                  prefixIcon: Icon(Icons.account_balance_wallet_outlined),
                ),
              ),
            if (!isEdit) const SizedBox(height: 16),

            // Allocation %
            TextFormField(
              controller: _allocCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Tỷ lệ phân bổ (%) - tùy chọn',
                prefixIcon: Icon(Icons.pie_chart_outline),
                hintText: 'VD: 10 (nghĩa là 10% thu nhập)',
              ),
            ),
            const SizedBox(height: 16),

            // Goal toggle
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Kích hoạt mục tiêu tiết kiệm'),
                subtitle: const Text('Theo dõi tiến trình hướng đến mục tiêu'),
                value: _isGoalActive,
                onChanged: (v) => setState(() => _isGoalActive = v),
              ),
            ),

            if (_isGoalActive) ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _targetCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Số tiền mục tiêu (đ) *',
                  prefixIcon: Icon(Icons.flag_outlined),
                ),
              ),
            ],
            const SizedBox(height: 28),

            SizedBox(
              height: 52,
              child: FilledButton.icon(
                onPressed: _isSaving ? null : _save,
                icon: _isSaving
                    ? const SizedBox(
                        width: 18, height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : Icon(isEdit ? Icons.save_outlined : Icons.add_rounded),
                label: Text(
                    _isSaving ? 'Đang lưu...' : (isEdit ? 'CẬP NHẬT' : 'TẠO HŨ TIỀN')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xóa hũ tiền?'),
        content: Text(
            'Xóa hũ "${_editAccount!.name}"? Các giao dịch liên quan vẫn được giữ lại.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Hủy')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Xóa')),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      await context.read<FinanceProvider>().deleteAccount(_editAccount!.id);
      if (context.mounted) Navigator.pop(context);
    }
  }
}
