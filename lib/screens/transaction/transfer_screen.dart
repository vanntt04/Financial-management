import 'package:flutter/material.dart';

import '../../core/api_exception.dart';
import '../../core/utils/validators.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/account_model.dart';
import '../../services/account_service.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  List<AccountModel> _accounts = [];
  AccountModel? _fromAccount;
  AccountModel? _toAccount;
  bool _isLoadingAccounts = true;
  bool _isTransferring = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadAccounts() async {
    setState(() => _isLoadingAccounts = true);
    try {
      final list = await AccountService.getAccounts();
      if (mounted) {
        setState(() {
          _accounts = list;
          if (list.isNotEmpty) _fromAccount = list.first;
          if (list.length > 1) _toAccount = list[1];
        });
      }
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoadingAccounts = false);
    }
  }

  Future<void> _doTransfer() async {
    if (!_formKey.currentState!.validate()) return;
    if (_fromAccount == null || _toAccount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn hũ nguồn và hũ đích')),
      );
      return;
    }
    if (_fromAccount!.id == _toAccount!.id) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hũ nguồn và hũ đích không được giống nhau')),
      );
      return;
    }

    final amount =
        double.tryParse(_amountCtrl.text.replaceAll(RegExp(r'[^\d.]'), '')) ??
            0;
    if (amount > (_fromAccount?.currentAmount ?? 0)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Số tiền vượt quá số dư hũ nguồn')),
      );
      return;
    }

    setState(() => _isTransferring = true);
    try {
      // POST a TRANSFER transaction to the backend.
      // The API is expected to handle debit/credit between accounts.
      // Adjust endpoint/body to match your actual backend contract.
      // For now we call account update to simulate a local transfer.
      // TODO: Replace with real transfer API endpoint when available.
      if (_fromAccount!.id != null && _toAccount!.id != null) {
        await AccountService.updateAccount(_fromAccount!.id!, {
          'currentAmount': _fromAccount!.currentAmount - amount,
        });
        await AccountService.updateAccount(_toAccount!.id!, {
          'currentAmount': _toAccount!.currentAmount + amount,
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Đã chuyển ${CurrencyFormatter.format(amount)} từ "${_fromAccount!.name}" đến "${_toAccount!.name}"'),
            backgroundColor: Colors.green,
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
      if (mounted) setState(() => _isTransferring = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chuyển khoản giữa hũ',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: _isLoadingAccounts
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_error!,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      FilledButton(
                          onPressed: _loadAccounts,
                          child: const Text('Thử lại')),
                    ],
                  ),
                )
              : _accounts.length < 2
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.account_balance_wallet_outlined,
                              size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 12),
                          const Text(
                            'Cần ít nhất 2 hũ để thực hiện chuyển khoản',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 16),
                          FilledButton(
                            onPressed: () =>
                                Navigator.pushNamed(context, '/accounts/add-edit'),
                            child: const Text('Thêm hũ mới'),
                          ),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // From account
                            Text('Từ hũ',
                                style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500)),
                            const SizedBox(height: 8),
                            _buildAccountDropdown(
                              value: _fromAccount,
                              onChanged: (v) => setState(() => _fromAccount = v),
                              excludeId: _toAccount?.id,
                              scheme: scheme,
                            ),

                            // Swap button
                            const SizedBox(height: 8),
                            Center(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    final temp = _fromAccount;
                                    _fromAccount = _toAccount;
                                    _toAccount = temp;
                                  });
                                },
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: scheme.primaryContainer,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.swap_vert,
                                      color: scheme.primary),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),

                            // To account
                            Text('Đến hũ',
                                style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500)),
                            const SizedBox(height: 8),
                            _buildAccountDropdown(
                              value: _toAccount,
                              onChanged: (v) => setState(() => _toAccount = v),
                              excludeId: _fromAccount?.id,
                              scheme: scheme,
                            ),

                            const SizedBox(height: 24),

                            // Amount
                            TextFormField(
                              controller: _amountCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Số tiền',
                                prefixIcon: Icon(Icons.attach_money),
                                suffixText: '₫',
                              ),
                              keyboardType: TextInputType.number,
                              validator: (v) {
                                final err = Validators.validateAmount(v);
                                if (err != null) return err;
                                final amount = double.tryParse(
                                    v!.replaceAll(RegExp(r'[^\d.]'), ''));
                                if (amount != null &&
                                    _fromAccount != null &&
                                    amount > _fromAccount!.currentAmount) {
                                  return 'Vượt quá số dư hũ nguồn';
                                }
                                return null;
                              },
                            ),

                            // Available balance hint
                            if (_fromAccount != null) ...[
                              const SizedBox(height: 6),
                              Padding(
                                padding: const EdgeInsets.only(left: 4),
                                child: Text(
                                  'Số dư: ${CurrencyFormatter.format(_fromAccount!.currentAmount)}',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600),
                                ),
                              ),
                            ],

                            const SizedBox(height: 16),

                            // Note (optional)
                            TextFormField(
                              controller: _noteCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Ghi chú (tùy chọn)',
                                prefixIcon: Icon(Icons.note_outlined),
                              ),
                              maxLines: 2,
                            ),

                            const SizedBox(height: 32),

                            SizedBox(
                              width: double.infinity,
                              child: FilledButton.icon(
                                onPressed: _isTransferring ? null : _doTransfer,
                                icon: _isTransferring
                                    ? const SizedBox(
                                        height: 18,
                                        width: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(Icons.send),
                                label: Text(
                                    _isTransferring ? 'Đang chuyển...' : 'Chuyển'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
    );
  }

  Widget _buildAccountDropdown({
    required AccountModel? value,
    required ValueChanged<AccountModel?> onChanged,
    int? excludeId,
    required ColorScheme scheme,
  }) {
    final filtered =
        _accounts.where((a) => a.id != excludeId).toList();
    final effectiveValue = filtered.contains(value) ? value : null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<AccountModel>(
          value: effectiveValue,
          isExpanded: true,
          hint: const Text('Chọn hũ'),
          items: filtered
              .map(
                (a) => DropdownMenuItem(
                  value: a,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            a.type == 'SAVING'
                                ? Icons.savings_outlined
                                : Icons.account_balance_wallet_outlined,
                            color: scheme.primary,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(a.name),
                        ],
                      ),
                      Text(
                        CurrencyFormatter.format(a.currentAmount),
                        style: TextStyle(
                            color: scheme.primary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
