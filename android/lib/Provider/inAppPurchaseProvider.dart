import 'package:flutter/cupertino.dart';
import 'package:videoPlus/model/InAppPurchasseListModel.dart';

class InAppPurchaseProvider with ChangeNotifier {
  List<InAppPurchaseListModel> inAppPurchaseList = [];
  get getInAppPurchaseList => inAppPurchaseList;
  changeCategoryVideo(List<InAppPurchaseListModel> list) {
    inAppPurchaseList = list;
  }

  set categoryVideoListData(List<InAppPurchaseListModel> list) {
    inAppPurchaseList.addAll(list);
    notifyListeners();
  }
}
