import 'package:flutter/material.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Quản lý Danh mục'),
          bottom: const TabBar(tabs: [Tab(text: 'Khoản Chi'), Tab(text: 'Khoản Thu')]),
        ),
        body: TabBarView(
          children: [
            _buildCategoryList(context, [
              {'name': 'Ăn uống', 'icon': Icons.restaurant, 'color': Colors.orange},
              {'name': 'Di chuyển', 'icon': Icons.local_taxi, 'color': Colors.blue},
              {'name': 'Mua sắm', 'icon': Icons.shopping_bag, 'color': Colors.purple},
            ]),
            _buildCategoryList(context, [
              {'name': 'Lương', 'icon': Icons.work, 'color': Colors.green},
              {'name': 'Thưởng', 'icon': Icons.card_giftcard, 'color': Colors.redAccent},
            ]),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildCategoryList(BuildContext context, List<Map<String, dynamic>> categories) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final cat = categories[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: (cat['color'] as Color).withOpacity(0.2),
              child: Icon(cat['icon'] as IconData, color: cat['color'] as Color),
            ),
            title: Text(cat['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
            trailing: IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () {}),
          ),
        );
      },
    );
  }
}