import 'package:flutter/material.dart';

import '../models/category_model.dart';
import '../services/category_service.dart';

class CategoryProvider extends ChangeNotifier {
  List<CategoryModel> _categories = [];
  bool _isLoading = false;
  String? _error;

  List<CategoryModel> get categories => _categories;
  List<CategoryModel> get incomeCategories =>
      _categories.where((c) => c.categoryType == 'INCOME').toList();
  List<CategoryModel> get expenseCategories =>
      _categories.where((c) => c.categoryType == 'EXPENSE').toList();
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchCategories({String? type}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _categories = await CategoryService.getCategories(type: type);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addCategory(String name, String type) async {
    try {
      final newCat = await CategoryService.createCategory(
        categoryName: name,
        categoryType: type,
      );
      _categories = [..._categories, newCat];
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateCategory(int id, String name) async {
    try {
      final updated =
          await CategoryService.updateCategory(id, categoryName: name);
      _categories =
          _categories.map((c) => c.categoryId == id ? updated : c).toList();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteCategory(int id) async {
    try {
      await CategoryService.deleteCategory(id);
      _categories = _categories.where((c) => c.categoryId != id).toList();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
