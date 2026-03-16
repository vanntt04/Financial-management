import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/finance_provider.dart';
import '../../services/api_service.dart';

class AddEditAccountScreen extends StatefulWidget {
  /// Nếu [account] != null thì đang sửa, null thì đang thêm mới
  final ApiAccount? account;
  const AddEditAccountScreen({super.key, this.account});

  @override
  State<AddEditAccountScreen> createState() => _AddEditAccountScreenState();
}

class _AddEditAccountScreenState extends State<AddEditAccountScreen> {
  final _nameCtrl       = TextEditingController();
  final _percentCtrl    = TextEditingController();
  final _targetCtrl     = TextEditingController();
  bool  _isGoalActive   = false;
  bool  _isSaving       = false;

  bool get _isEditing => widget.account != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final a = widget.account!;
      _nameCtrl.text    = a.accountName;
      _percentCtrl.text = a.allocationPercentage != null
          ? a.allocationPercentage!.toStringAsFixed(0)
          : '';
      _targetCtrl.text  = a.targetAmount != null
          ? a.targetAmount!.toStringAsFixed(0)
          : '';
      _isGoalActive     = a.isGoalActive;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _percentCtrl.dispose();
    _targetCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      _snack('Vui lòng nhập tên hũ', Colors.red); return;
    }

    final pct = double.tryParse(_percentCtrl.text.replaceAll(',', '.'));
    if (_percentCtrl.text.isNotEmpty && (pct == null || pct < 0 || pct > 100)) {
      _snack('Phần trăm phân bổ phải từ 0 đến 100', Colors.red); return;
    }

    final target = double.tryParse(
        _targetCtrl.text.replaceAll('.', '').replaceAll(',', ''));

    setState(() => _isSaving = true);
    final provider = context.read<FinanceProvider>();
    bool ok;

    if (_isEditing) {
      ok = await provider.updateAccount(
        accountId:            widget.account!.accountId,
        accountName:          name,
        allocationPercentage: pct,
        isGoalActive:         _isGoalActive,
        targetAmount:         target,
      );
    } else {
      ok = await provider.createAccount(
        accountName:          name,
        allocationPercentage: pct,
        isGoalActive:         _isGoalActive,
        targetAmount:         target,
      );
    }

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (ok) {
      _snack(_isEditing ? 'Đã cập nhật hũ!' : 'Đã thêm hũ mới!', Colors.green);
      Navigator.pop(context, true);
    } else {
      _snack('Có lỗi xảy ra, vui lòng thử lại', Colors.red);
    }
  }

  void _snack(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Sửa hũ tiền' : 'Thêm hũ tiền',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.all(14),
              child: SizedBox(
                  width: 22, height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _save,
              tooltip: 'Lưu',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Icon minh họa
            Center(
              child: Container(
                width: 72, height: 72,
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isGoalActive
                      ? Icons.savings_outlined
                      : Icons.account_balance_wallet_outlined,
                  size: 36, color: scheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Tên hũ
            TextFormField(
              controller: _nameCtrl,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Tên hũ *',
                prefixIcon: Icon(Icons.label_outline),
                hintText: 'VD: Chi tiêu thiết yếu, Tiết kiệm...',
              ),
            ),
            const SizedBox(height: 16),

            // Phần trăm phân bổ
            TextFormField(
              controller: _percentCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Phần trăm phân bổ (%)',
                prefixIcon: Icon(Icons.pie_chart_outline),
                hintText: 'VD: 55',
                suffixText: '%',
              ),
            ),
            const SizedBox(height: 16),

            // Bật/tắt mục tiêu tiết kiệm
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: SwitchListTile(
                value: _isGoalActive,
                onChanged: (v) => setState(() => _isGoalActive = v),
                title: const Text('Có mục tiêu tiết kiệm',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(
                  _isGoalActive
                      ? 'Hũ này có số tiền mục tiêu cần đạt'
                      : 'Hũ chi tiêu thông thường',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
                secondary: Icon(
                  _isGoalActive
                      ? Icons.flag_outlined
                      : Icons.wallet_outlined,
                  color: scheme.primary,
                ),
              ),
            ),

            // Số tiền mục tiêu (chỉ hiện khi bật goal)
            if (_isGoalActive) ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _targetCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Số tiền mục tiêu',
                  prefixIcon: Icon(Icons.flag_outlined),
                  hintText: 'VD: 50000000',
                  suffixText: 'VNĐ',
                ),
              ),
            ],
            const SizedBox(height: 32),

            // Nút lưu
            SizedBox(
              height: 52,
              child: FilledButton(
                onPressed: _isSaving ? null : _save,
                child: Text(
                  _isEditing ? 'CẬP NHẬT HŨ' : 'THÊM HŨ MỚI',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),

            // Nút xóa (chỉ khi đang sửa)
            if (_isEditing) ...[
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _isSaving ? null : _confirmDelete,
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                label: const Text('Xóa hũ này',
                    style: TextStyle(color: Colors.red)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa hũ tiền'),
        content: Text(
            'Bạn có chắc muốn xóa hũ "${widget.account!.accountName}"?\n'
            'Các giao dịch liên quan sẽ không bị xóa.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Hủy')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child:
                const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;

    setState(() => _isSaving = true);
    final deleted = await context
        .read<FinanceProvider>()
        .deleteAccount(widget.account!.accountId);
    if (!mounted) return;
    setState(() => _isSaving = false);

    if (deleted) {
      _snack('Đã xóa hũ', Colors.green);
      Navigator.pop(context, true);
    } else {
      _snack('Xóa thất bại', Colors.red);
    }
  }
}
