class CategoryModel {
  final int categoryId;
  final String categoryName;
  final String categoryType; // INCOME | EXPENSE

  CategoryModel({
    required this.categoryId,
    required this.categoryName,
    required this.categoryType,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      categoryId:   json['categoryId']   as int,
      categoryName: json['categoryName'] as String,
      categoryType: json['categoryType'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'categoryId':   categoryId,
        'categoryName': categoryName,
        'categoryType': categoryType,
      };
}
