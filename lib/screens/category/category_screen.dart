import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/api_exception.dart';
import '../../models/category_model.dart';
import '../../providers/finance_provider.dart';
import '../../services/finance_service.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  List<CategoryModel> _expense = [];
  List<CategoryModel> _income  = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final all = await FinanceService.getCategories();
      if (mounted) {
        setState(() {
          _expense   = all.where((c) => c.categoryType == 'EXPENSE').toList();
          _income    = all.where((c) => c.categoryType == 'INCOME').toList();
          _isLoading = false;
        });
      }
    } on ApiException catch (e) {
      if (mounted) setState(() { _error = e.message; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  void _showAddDialog(String type) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Thêm danh mục ${type == 'EXPENSE' ? 'Chi' : 'Thu'}'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Tên danh mục'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              // TODO: gọi API tạo category rồi reload
              _loadCategories();
            },
            child: const Text('Thêm'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Quản lý Danh mục',
              style: TextStyle(fontWeight: FontWeight.bold)),
          bottom: TabBar(
            tabs: const [Tab(text: 'Khoản Chi'), Tab(text: 'Khoản Thu')],
            indicatorColor: scheme.primary,
            labelColor: scheme.primary,
            unselectedLabelColor: Colors.grey,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Text(_error!, style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      FilledButton(
                          onPressed: _loadCategories,
                          child: const Text('Thử lại')),
                    ]))
                : TabBarView(children: [
                    _buildList(_expense, 'EXPENSE', scheme),
                    _buildList(_income,  'INCOME',  scheme),
                  ]),
        floatingActionButton: Builder(
          builder: (ctx) {
            final tabIndex =
                DefaultTabController.of(ctx).index;
            return FloatingActionButton(
              onPressed: () =>
                  _showAddDialog(tabIndex == 0 ? 'EXPENSE' : 'INCOME'),
              child: const Icon(Icons.add),
            );
          },
        ),
      ),
    );
  }

  Widget _buildList(
      List<CategoryModel> cats, String type, ColorScheme scheme) {
    if (cats.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.category_outlined,
              size: 56, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text('Chưa có danh mục nào',
              style: TextStyle(color: Colors.grey.shade500)),
        ]),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: cats.length,
      itemBuilder: (context, i) {
        final cat = cats[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2))
            ],
          ),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            leading: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12)),
              child: Icon(Icons.category_outlined,
                  color: scheme.primary, size: 22),
            ),
            title: Text(cat.categoryName,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 15)),
            subtitle: Text(
                cat.categoryType == 'EXPENSE' ? 'Khoản chi' : 'Khoản thu',
                style:
                    TextStyle(fontSize: 12, color: Colors.grey.shade500)),
            trailing: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(10)),
              child: IconButton(
                icon: Icon(Icons.edit_outlined,
                    color: scheme.primary, size: 16),
                onPressed: () {},
                padding: EdgeInsets.zero,
              ),
            ),
          ),
        );
      },
    );
  }
}
