import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:videoPlus/Utils/generalMethods.dart';

import '../LocalDataStore/AuthLocalDataStore.dart';
import '../Utils/DesignConfig.dart';
import '../Utils/apiParameters.dart';
import '../Utils/apiUtils.dart';
import '../model/CategoryVideoModel.dart';

class VideoHistoryProvider with ChangeNotifier {
  List<CategoryVideoModel> videoHistoryList = [];
  List<String> videoHistory = [];
  int total = 0;

  get getVideoHistoryList => videoHistoryList;
  get getThumbnails => videoHistory;

  Future getVideoHistory(
      {required BuildContext context, int offset = 0, int perPage = 10}) async {
    try {
      final body = {
        userIdApiKey: AuthLocalDataSource.getUserId(),
        limitApiKey: perPage.toString(),
        offsetApiKey: offset.toString(),
      };
      final response = await post(Uri.parse(getVideoHistoryUrl),
          body: body, headers: await ApiUtils.getHeaders());
      final responseJson = jsonDecode(response.body);
      print("json response - $responseJson");
      total = responseJson["total"];
      if (responseJson['error'] == true) {
        if (responseJson['status'] == "Unauthorized access") {
          Navigator.of(context).pushNamedAndRemoveUntil(
              '/login', (Route<dynamic> route) => false);
        }
        setState() {
          DesignConfig.setSnackbar(responseJson['error'], context, false);
        }
      } else {
        if ((offset) < total) {
          var parsedList = responseJson["data"];
          print("video history data - ${parsedList.toString()}");
          List<CategoryVideoModel> tempList = (parsedList as List)
              .map((data) => CategoryVideoModel.historyFromJson(
                  data as Map<String, dynamic>))
              .toList();
          /* videoHistoryList = (parsedList as List)
            .map((data) => CategoryVideoModel.historyFromJson(
                data as Map<String, dynamic>))
            .toList();

        videoHistoryList.removeWhere((element) =>
            element.duration ==
            element
                .historyDuration);  */ // difference should be greater than 0 //remove from list - once completely watched

          setVideoHistoryList(tempList);
          offset = offset + perPage;

          // if (mounted) {
          //   context.read<CategoryProvider>().changeCategoryList(categoryList);
          // }
        }
      }
      setState() {
        // isLoading = false;
        // _animationController!.forward();
      }
      print("History list updated - ${videoHistoryList.length}");
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future setVideoHistory({
    required BuildContext context,
    required String currentDuration,
    required int videoId,
  }) async {
    try {
      final body = {
        userIdApiKey: AuthLocalDataSource.getUserId(),
        durationApiKey: currentDuration, //'myProgess from VideoPlayAreaScreen',
        videoIdApiKey: videoId.toString() //'CurrentVideoId'
      };
      final response = await post(Uri.parse(setVideoHistoryUrl),
          body: body, headers: await ApiUtils.getHeaders());
      final responseJson = jsonDecode(response.body);
      // print("Video history set - json response - $responseJson");
      if (responseJson['error'] == true) {
        if (responseJson['status'] == "Unauthorized access") {
          Navigator.of(context).pushNamedAndRemoveUntil(
              '/login', (Route<dynamic> route) => false);
        }
        SetState() {
          DesignConfig.setSnackbar(responseJson['error'], context, false);
        }
      } else {
        // isSaved = true;
        print(responseJson["message"]);
        //get updated list & notify listeners
        getVideoHistory(context: context);
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  setVideoHistoryList(List<CategoryVideoModel> valuesList) {
    print("Notifier called !!");
    videoHistoryList.clear();
    videoHistoryList.addAll(valuesList);
    videoHistoryList
        .removeWhere((element) => element.duration == element.historyDuration);
    videoHistory = GeneralMethods.getThumbnail(listData: videoHistoryList);
    notifyListeners();
  }
}
