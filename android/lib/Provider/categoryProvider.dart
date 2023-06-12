import 'package:flutter/cupertino.dart';

import '../model/CategoryModel.dart';

class CategoryProvider with ChangeNotifier {
  List<CategoryModel> categoryList = [];
  get getCategoryList => categoryList;

  changeCategoryList(List<CategoryModel> list) {
    categoryList.clear();
    categoryList.addAll(list);
    notifyListeners();
  }

  set setCategoryList(List<CategoryModel> list) {
    categoryList.addAll(list);
  }
}
