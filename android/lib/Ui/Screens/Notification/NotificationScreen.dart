import 'dart:async';
import 'dart:convert';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:readmore/readmore.dart';
import 'package:videoPlus/LocalDataStore/AuthLocalDataStore.dart';

import '../../../LocalDataStore/SettingLocalDataSource.dart';
import '../../../Utils/ColorRes.dart';
import '../../../Utils/Constant.dart';
import '../../../Utils/DesignConfig.dart';
import '../../../Utils/InternetConnectivity.dart';
import '../../../Utils/SlideAnimation.dart';
import '../../../Utils/StringRes.dart';
import '../../../Utils/apiParameters.dart';
import '../../../Utils/apiUtils.dart';
import '../../../model/NotificationModel.dart';
import '../../Widget/shimmerNotificationWidget.dart';
import '../ErrorWidget/NoConErrorWidget.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return NotificationScreenState();
  }
}

class NotificationScreenState extends State<NotificationScreen>
    with TickerProviderStateMixin {
  List<NotificationModel> notificationList = [];
  bool isLoading = true;
  AnimationController? _animationController;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> connectivitySubscription;
  Future getNotification() async {
    try {
      final body = {userIdApiKey: AuthLocalDataSource.getUserId()};
      final response = await post(Uri.parse(getNotificationUrl),
          body: body, headers: await ApiUtils.getHeaders());
      final responseJson = jsonDecode(response.body);
      print("===get Notification========$responseJson");
      if (responseJson['error'] == "true") {
        if (mounted) {
          setState(() {
            isLoading = false;
            DesignConfig.setSnackbar(responseJson['message'], context, false);
          });
        }
      } else {
        if (mounted) {
          setState(() {
            isLoading = false;
            var parsedList = responseJson["data"];
            notificationList = (parsedList as List)
                .map((data) =>
                    NotificationModel.fromJson(data as Map<String, dynamic>))
                .toList();
          });
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  void initState() {
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));
    CheckInternet.initConnectivity().then((value) => setState(() {
          DesignConfig.connectionStatus = value;
          debugPrint("internet:$value");
        }));
    connectivitySubscription =
        _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      CheckInternet.updateConnectionStatus(result).then((value) => setState(() {
            DesignConfig.connectionStatus = value;
            debugPrint("internets....:$value");
          }));
    });
    getNotification();
    super.initState();
  }

  @override
  void dispose() {
    _animationController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return DesignConfig.connectionStatus == 'ConnectivityResult.none'
        ? NoConErrorWidget(
            onTap: () {
              setState(() {
                getNotification();
              });
            },
          )
        : Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: AppBar(
              automaticallyImplyLeading: false,
              toolbarHeight: size.height * .08,
              elevation: 2,
              titleSpacing: 24,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20)),
              ),
              backgroundColor:
                  SettingsLocalDataSource().theme() == StringRes.darkThemeKey
                      ? darkButtonDisable
                      : Theme.of(context).backgroundColor,
              title: Text(StringRes.notifications,
                  style: TextStyle(
                      color: Theme.of(context).secondaryHeaderColor,
                      fontWeight: FontWeight.w700,
                      fontStyle: FontStyle.normal,
                      fontSize: 24.0),
                  textAlign: TextAlign.left),
            ),
            body: isLoading
                ? ShimmerNotificationWidget(
                    height: MediaQuery.of(context).size.height * .11,
                    length: 15,
                  )
                : notificationList.isEmpty
                    ? DesignConfig.noDataFound(context)
                    : RefreshIndicator(
                        color: Theme.of(context).primaryColor,
                        backgroundColor:
                            Theme.of(context).scaffoldBackgroundColor,
                        onRefresh: getNotification,
                        child: ListView.builder(
                            itemCount: notificationList.length,
                            padding: EdgeInsets.only(
                                top: 8,
                                bottom:
                                    MediaQuery.of(context).size.height * .08),
                            physics: const AlwaysScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemBuilder: (BuildContext context, int index) {
                              return SlideAnimation(
                                  position: index,
                                  itemCount: notificationList.length,
                                  slideDirection: SlideDirection.fromBottom,
                                  animationController: _animationController,
                                  child: Container(
                                    alignment: Alignment.topLeft,
                                    padding: const EdgeInsets.only(
                                      left: 8.0,
                                      right: 8.0,
                                    ),
                                    child: Card(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      elevation: 5,
                                      shadowColor: Colors.black26,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(borderRadius),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                              alignment: Alignment.topLeft,
                                              width: notificationList[index]
                                                      .image!
                                                      .isEmpty
                                                  ? MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      .93
                                                  : MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      .68,
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 15),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                        notificationList[index]
                                                                .title![0]
                                                                .toUpperCase() +
                                                            notificationList[
                                                                    index]
                                                                .title!
                                                                .substring(1),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                            color: Theme.of(
                                                                    context)
                                                                .secondaryHeaderColor,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontStyle: FontStyle
                                                                .normal,
                                                            fontSize: 16.0),
                                                        textAlign:
                                                            TextAlign.left),
                                                    ReadMoreText(
                                                      notificationList[index]
                                                              .message![0]
                                                              .toUpperCase() +
                                                          notificationList[
                                                                  index]
                                                              .message!
                                                              .substring(1),
                                                      textAlign: TextAlign.left,
                                                      trimLines: 2,
                                                      colorClickableText:
                                                          Theme.of(context)
                                                              .primaryColor,
                                                      style: TextStyle(
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .secondary,
                                                          fontWeight:
                                                              FontWeight.normal,
                                                          fontStyle:
                                                              FontStyle.normal,
                                                          fontSize: 12.0),
                                                      trimMode: TrimMode.Line,
                                                      trimCollapsedText:
                                                          'Show more',
                                                      trimExpandedText:
                                                          'Show less',
                                                      moreStyle: TextStyle(
                                                          fontSize: 12,
                                                          color:
                                                              Theme.of(context)
                                                                  .primaryColor,
                                                          fontWeight: FontWeight
                                                              .normal),
                                                    ),
                                                    Text(
                                                        DesignConfig.timeAgo(
                                                            DateTime.parse(
                                                                notificationList[
                                                                        index]
                                                                    .date!)),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .secondary
                                                                .withOpacity(
                                                                    0.5),
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal,
                                                            fontStyle: FontStyle
                                                                .normal,
                                                            fontSize: 12.0),
                                                        textAlign:
                                                            TextAlign.left),
                                                    const SizedBox(
                                                      height: 5,
                                                    )
                                                  ],
                                                ),
                                              )),
                                          notificationList[index].image!.isEmpty
                                              ? const SizedBox.shrink()
                                              : Container(
                                                  width: size.width * .25,
                                                  height: size.height * .1,
                                                  decoration:
                                                      const BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.only(
                                                            topRight: Radius
                                                                .circular(8),
                                                            bottomRight:
                                                                Radius.circular(
                                                                    8)),
                                                  ),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        const BorderRadius.only(
                                                            topRight:
                                                                Radius.circular(
                                                                    8),
                                                            bottomRight:
                                                                Radius.circular(
                                                                    8)),
                                                    child: Image.network(
                                                      notificationList[index]
                                                          .image!,
                                                      fit: BoxFit.fill,
                                                    ),
                                                  ),
                                                )
                                        ],
                                      ),
                                    ),
                                  ));
                            })));
  }
}
