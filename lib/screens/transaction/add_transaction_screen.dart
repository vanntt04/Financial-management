import 'package:flutter/material.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  String _type = 'EXPENSE';
  String _selectedJar = 'Chi tiêu thiết yếu';

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isExpense = _type == 'EXPENSE';
    final typeColor = isExpense ? Colors.red.shade400 : Colors.green.shade500;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ghi chép giao dịch', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          // Type toggle
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            child: Row(
              children: [
                Expanded(child: _buildTypeButton('CHI TIÊU', 'EXPENSE', Colors.red.shade400, isExpense, scheme)),
                const SizedBox(width: 12),
                Expanded(child: _buildTypeButton('THU NHẬP', 'INCOME', Colors.green.shade500, !isExpense, scheme)),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Amount input
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Số tiền', style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                        TextField(
                          keyboardType: TextInputType.number,
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: typeColor),
                          decoration: InputDecoration(
                            hintText: '0',
                            hintStyle: TextStyle(fontSize: 28, color: Colors.grey.shade300, fontWeight: FontWeight.bold),
                            suffixText: 'VNĐ',
                            suffixStyle: TextStyle(fontSize: 16, color: Colors.grey.shade500),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            filled: false,
                            contentPadding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Form fields
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
                    ),
                    child: Column(
                      children: [
                        DropdownButtonFormField<String>(
                          value: _selectedJar,
                          decoration: const InputDecoration(
                            labelText: 'Quỹ / Hũ',
                            prefixIcon: Icon(Icons.account_balance_wallet_outlined),
                          ),
                          items: ['Chi tiêu thiết yếu', 'Tiết kiệm dài hạn', 'Đầu tư & Giải trí']
                              .map((jar) => DropdownMenuItem(value: jar, child: Text(jar)))
                              .toList(),
                          onChanged: (value) => setState(() => _selectedJar = value!),
                        ),
                        const SizedBox(height: 16),
                        const TextField(
                          decoration: InputDecoration(
                            labelText: 'Ghi chú (tuỳ chọn)',
                            prefixIcon: Icon(Icons.notes_outlined),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),
                  SizedBox(
                    height: 52,
                    child: FilledButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('LƯU GIAO DỊCH'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeButton(String label, String type, Color activeColor, bool isActive, ColorScheme scheme) {
    return GestureDetector(
      onTap: () => setState(() => _type = type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? activeColor.withOpacity(0.12) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isActive ? activeColor : Colors.transparent, width: 1.5),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: isActive ? activeColor : Colors.grey.shade500,
          ),
        ),
      ),
    );
  }
}
