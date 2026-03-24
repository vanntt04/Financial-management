// lib/screens/category/category_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:financial_management/models/category_model.dart';
import 'package:financial_management/providers/finance_provider.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});
  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }
  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final finance = context.watch<FinanceProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh mục', style: TextStyle(fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tab,
          indicatorColor: scheme.primary,
          labelColor: scheme.primary,
          unselectedLabelColor: Colors.grey,
          tabs: const [Tab(text: 'CHI TIÊU'), Tab(text: 'THU NHẬP')],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddDialog(context),
          )
        ],
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          _CatList(cats: finance.expenseCategories, type: 'EXPENSE'),
          _CatList(cats: finance.incomeCategories, type: 'INCOME'),
        ],
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    String type = 'EXPENSE';
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSt) => AlertDialog(
          title: const Text('Thêm danh mục'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Tên danh mục',
                  prefixIcon: Icon(Icons.label_outline),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Loại: '),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Chi tiêu'),
                    selected: type == 'EXPENSE',
                    onSelected: (_) => setSt(() => type = 'EXPENSE'),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Thu nhập'),
                    selected: type == 'INCOME',
                    onSelected: (_) => setSt(() => type = 'INCOME'),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
            FilledButton(
              onPressed: () async {
                if (nameCtrl.text.trim().isNotEmpty) {
                  await context.read<FinanceProvider>().createCategory(
                    name: nameCtrl.text.trim(), type: type);
                  if (ctx.mounted) Navigator.pop(ctx);
                }
              },
              child: const Text('Thêm'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CatList extends StatelessWidget {
  const _CatList({required this.cats, required this.type});
  final List<CategoryModel> cats;
  final String type;
  @override
  Widget build(BuildContext context) {
    if (cats.isEmpty) {
      return const Center(child: Text('Không có danh mục nào'));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: cats.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final cat = cats[i];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (type == 'EXPENSE'
                          ? Colors.red
                          : Colors.green)
                      .withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  type == 'EXPENSE'
                      ? Icons.arrow_upward_rounded
                      : Icons.arrow_downward_rounded,
                  size: 18,
                  color: type == 'EXPENSE' ? Colors.red : Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(cat.name,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
              ),
              if (!cat.isDefault)
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      size: 20, color: Colors.red),
                  onPressed: () async {
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Xóa danh mục?'),
                        content: Text(
                            'Xóa "${cat.name}"? Các giao dịch đã dùng danh mục này vẫn được giữ lại.'),
                        actions: [
                          TextButton(
                              onPressed: () =>
                                  Navigator.pop(context, false),
                              child: const Text('Hủy')),
                          TextButton(
                              onPressed: () =>
                                  Navigator.pop(context, true),
                              style: TextButton.styleFrom(
                                  foregroundColor: Colors.red),
                              child: const Text('Xóa')),
                        ],
                      ),
                    );
                    if (ok == true && context.mounted) {
                      context.read<FinanceProvider>().deleteCategory(cat.id);
                    }
                  },
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('Mặc định',
                      style: TextStyle(
                          fontSize: 11, color: Colors.grey.shade500)),
                ),
            ],
          ),
        );
      },
    );
  }
}
