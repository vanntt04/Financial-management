import 'package:flutter/material.dart';

import '../../core/utils/validators.dart';
import '../../models/account_model.dart';
import '../../services/account_service.dart';

class AddEditAccountScreen extends StatefulWidget {
  const AddEditAccountScreen({super.key});

  @override
  State<AddEditAccountScreen> createState() => _AddEditAccountScreenState();
}

class _AddEditAccountScreenState extends State<AddEditAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _balanceCtrl = TextEditingController();
  final _percentageCtrl = TextEditingController();
  final _targetAmountCtrl = TextEditingController();

  String _type = 'SPENDING';
  bool _isGoalActive = false;
  DateTime? _targetDate;
  bool _isLoading = false;
  AccountModel? _editingAccount;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is AccountModel && _editingAccount == null) {
      _editingAccount = args;
      _nameCtrl.text = args.name;
      _balanceCtrl.text = args.currentAmount.toStringAsFixed(0);
      _percentageCtrl.text = args.percentage.toStringAsFixed(0);
      _type = args.type;
      _isGoalActive = args.isGoalActive;
      if (args.targetAmount != null) {
        _targetAmountCtrl.text = args.targetAmount!.toStringAsFixed(0);
      }
      if (args.targetDate != null) {
        _targetDate = DateTime.tryParse(args.targetDate!);
      }
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _balanceCtrl.dispose();
    _percentageCtrl.dispose();
    _targetAmountCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickTargetDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _targetDate ?? DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _targetDate = picked);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isGoalActive && _targetDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ngày hoàn thành mục tiêu')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final balance = double.tryParse(
              _balanceCtrl.text.replaceAll(RegExp(r'[^\d.]'), '')) ??
          0;
      final pct = double.tryParse(_percentageCtrl.text) ?? 0;
      final targetAmt = _isGoalActive && _targetAmountCtrl.text.isNotEmpty
          ? double.tryParse(
              _targetAmountCtrl.text.replaceAll(RegExp(r'[^\d.]'), ''))
          : null;
      final targetDateStr = _targetDate != null
          ? '${_targetDate!.year}-${_targetDate!.month.toString().padLeft(2, '0')}-${_targetDate!.day.toString().padLeft(2, '0')}'
          : null;

      if (_editingAccount?.id != null) {
        await AccountService.updateAccount(_editingAccount!.id!, {
          'name': _nameCtrl.text.trim(),
          'currentAmount': balance,
          'percentage': pct,
          'type': _type,
          'isGoalActive': _isGoalActive,
          if (targetAmt != null) 'targetAmount': targetAmt,
          if (targetDateStr != null) 'targetDate': targetDateStr,
        });
      } else {
        await AccountService.createAccount(
          accountName: _nameCtrl.text.trim(),
          balance: balance,
          currencyId: 1, // default VND
          allocationPercentage: pct,
          isGoalActive: _isGoalActive,
          targetAmount: targetAmt,
          targetDate: targetDateStr,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_editingAccount != null
                ? 'Đã cập nhật hũ thành công'
                : 'Đã tạo hũ thành công'),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isEdit = _editingAccount != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Chỉnh sửa hũ' : 'Thêm hũ mới',
            style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Tên hũ',
                  prefixIcon: Icon(Icons.label_outline),
                ),
                validator: (v) => Validators.validateNotEmpty(v, 'tên hũ'),
              ),
              const SizedBox(height: 16),

              // Balance
              TextFormField(
                controller: _balanceCtrl,
                decoration: const InputDecoration(
                  labelText: 'Số dư ban đầu',
                  prefixIcon: Icon(Icons.attach_money),
                  suffixText: '₫',
                ),
                keyboardType: TextInputType.number,
                validator: Validators.validateAmount,
              ),
              const SizedBox(height: 16),

              // Percentage
              TextFormField(
                controller: _percentageCtrl,
                decoration: const InputDecoration(
                  labelText: 'Tỷ lệ phân bổ (%)',
                  prefixIcon: Icon(Icons.percent),
                  suffixText: '%',
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: Validators.validatePercentage,
              ),
              const SizedBox(height: 16),

              // Type selector
              Text('Loại hũ',
                  style: TextStyle(
                      fontSize: 13, color: Colors.grey.shade600)),
              const SizedBox(height: 8),
              Row(
                children: [
                  _typeChip('SPENDING', 'Chi tiêu',
                      Icons.shopping_cart_outlined, scheme),
                  const SizedBox(width: 12),
                  _typeChip(
                      'SAVING', 'Tiết kiệm', Icons.savings_outlined, scheme),
                ],
              ),
              const SizedBox(height: 20),

              // Goal toggle
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.flag_outlined, color: scheme.primary),
                        const SizedBox(width: 10),
                        const Text('Bật mục tiêu tiết kiệm',
                            style: TextStyle(fontWeight: FontWeight.w500)),
                      ],
                    ),
                    Switch(
                      value: _isGoalActive,
                      onChanged: (v) => setState(() => _isGoalActive = v),
                    ),
                  ],
                ),
              ),

              // Goal fields
              if (_isGoalActive) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _targetAmountCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Số tiền mục tiêu',
                    prefixIcon: Icon(Icons.track_changes),
                    suffixText: '₫',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (v) =>
                      _isGoalActive ? Validators.validateAmount(v) : null,
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: _pickTargetDate,
                  borderRadius: BorderRadius.circular(12),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Ngày hoàn thành',
                      prefixIcon: Icon(Icons.calendar_today_outlined),
                    ),
                    child: Text(
                      _targetDate != null
                          ? '${_targetDate!.day}/${_targetDate!.month}/${_targetDate!.year}'
                          : 'Chọn ngày',
                      style: TextStyle(
                        color: _targetDate != null
                            ? Colors.black87
                            : Colors.grey.shade500,
                      ),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isLoading ? null : _save,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : Text(isEdit ? 'Cập nhật' : 'Tạo hũ'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _typeChip(
      String value, String label, IconData icon, ColorScheme scheme) {
    final selected = _type == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _type = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? scheme.primaryContainer : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? scheme.primary : Colors.transparent,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 18,
                  color: selected ? scheme.primary : Colors.grey.shade600),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: selected ? scheme.primary : Colors.grey.shade600,
                  fontWeight:
                      selected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
