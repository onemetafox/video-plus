import 'package:flutter/cupertino.dart';

import '../model/GetPlayListModel.dart';

class SaveVideoProvider with ChangeNotifier {
  List<GetPlayListModel> saveVideoPlayList = [];
  List<Videos> videoList = [];
  get getVideosList => videoList;
  int videoLength = 0;
  get videoLengths => videoLength;
  get getSaveVideoPlaylist => saveVideoPlayList;

  setSaveVideoList(List<GetPlayListModel> list) {
    saveVideoPlayList.clear();
    saveVideoPlayList.addAll(list.toSet().toList());
    notifyListeners();
  }

  set setSaveVideoList1(List<GetPlayListModel> list) {
    saveVideoPlayList.addAll(list.toSet().toList());
  }

  setVideoList(List<Videos> list) {
    videoList.clear();
    videoList.addAll(list.toSet().toList());
    notifyListeners();
  }

  set setVideoList1(List<Videos> list) {
    videoList.addAll(list.toSet().toList());
  }

  changeVideoLength(int length) {
    videoLength = length;
    notifyListeners();
  }

  set setVideoLength(int length) {
    videoLength = length;
  }
}
