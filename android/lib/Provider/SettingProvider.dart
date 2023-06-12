import 'package:flutter/cupertino.dart';

import '../LocalDataStore/AuthLocalDataStore.dart';

class SettingProvider with ChangeNotifier {
  int setIsSubscribe = 0;
  String inAppCreateDate = "", inAppExDate = "", profile = "";
  bool? authStatus, guestLoginStatus;

  get getprofile => profile;
  get getinAppCreateDate => inAppCreateDate;
  get getinAppExDate => inAppExDate;
  get getIsSubscribe => setIsSubscribe;

  changeProfile(String val) {
    profile = val;
    notifyListeners();
  }

  set userProfile(String val) {
    profile = val;
    AuthLocalDataSource().setProfile(profile);
  }

  changeSetIsSubscribe(int val) {
    setIsSubscribe = val;
    AuthLocalDataSource().setIsSubscribe(setIsSubscribe);
    notifyListeners();
  }

  set userSetIsSubscribe(int val) {
    setIsSubscribe = val;
  }

  changeInAppCreateDate(String val) {
    inAppCreateDate = val;
    AuthLocalDataSource().setInAppCreateDate(inAppCreateDate);
    notifyListeners();
  }

  set setInAppPurchaseCreateDate(String val) {
    inAppCreateDate = val;
  }

  changeInAppExDate(String val) {
    inAppExDate = val;
    AuthLocalDataSource().setInAppExpDate(inAppExDate);
    notifyListeners();
  }

  set setInAppPurchaseExDate(String val) {
    inAppExDate = val;
  }
}
