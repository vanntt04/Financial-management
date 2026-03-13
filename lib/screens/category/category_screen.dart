import 'package:flutter/material.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Quản lý Danh mục', style: TextStyle(fontWeight: FontWeight.bold)),
          bottom: TabBar(
            tabs: const [Tab(text: 'Khoản Chi'), Tab(text: 'Khoản Thu')],
            indicatorColor: scheme.primary,
            labelColor: scheme.primary,
            unselectedLabelColor: Colors.grey,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: TabBarView(
          children: [
            _buildCategoryList(context, [
              {'name': 'Ăn uống', 'icon': Icons.restaurant, 'color': Colors.orange},
              {'name': 'Di chuyển', 'icon': Icons.local_taxi, 'color': Colors.blue},
              {'name': 'Mua sắm', 'icon': Icons.shopping_bag, 'color': Colors.purple},
            ], scheme),
            _buildCategoryList(context, [
              {'name': 'Lương', 'icon': Icons.work, 'color': Colors.green},
              {'name': 'Thưởng', 'icon': Icons.card_giftcard, 'color': Colors.redAccent},
            ], scheme),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildCategoryList(BuildContext context, List<Map<String, dynamic>> categories, ColorScheme scheme) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final cat = categories[index];
        final color = cat['color'] as Color;
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            leading: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
              child: Icon(cat['icon'] as IconData, color: color, size: 22),
            ),
            title: Text(cat['name'] as String, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
            trailing: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(color: scheme.primaryContainer, borderRadius: BorderRadius.circular(10)),
              child: IconButton(
                icon: Icon(Icons.edit_outlined, color: scheme.primary, size: 16),
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
