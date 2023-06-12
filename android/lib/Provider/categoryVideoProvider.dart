import 'package:flutter/cupertino.dart';

import '../model/CategoryVideoModel.dart';

class CategoryVideoProvider with ChangeNotifier {
  List<CategoryVideoModel> categoryVideoList = [];
  int currentIndex = 0;
  get getCurrentIndex => currentIndex;
  get getVideoList => categoryVideoList;
  changeCategoryVideo(List<CategoryVideoModel> list) {
    categoryVideoList = list;
  }

  set categoryVideoListData(List<CategoryVideoModel> list) {
    categoryVideoList.addAll(list);
    notifyListeners();
  }

  changeCurrentIndex(int index) {
    currentIndex = index;
  }

  set setCurrentIndex(int index) {
    currentIndex = index;
    notifyListeners();
  }
}
