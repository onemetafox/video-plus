import 'dart:async';
import 'dart:convert';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

import '../../../App/Routes.dart';
import '../../../LocalDataStore/AuthLocalDataStore.dart';
import '../../../Utils/Constant.dart';
import '../../../Utils/DesignConfig.dart';
import '../../../Utils/InternetConnectivity.dart';
import '../../../Utils/SlideAnimation.dart';
import '../../../Utils/apiParameters.dart';
import '../../../Utils/apiUtils.dart';
import '../../../model/CategoryVideoModel.dart';
import '../../../model/urlAndResolutionModel.dart';
import '../../Widget/AdsWidget.dart';
import '../../Widget/commonCardForAllWidget.dart';
import '../../Widget/shimmerWidget.dart';
import '../ErrorWidget/NoConErrorWidget.dart';

class FreeAndPaidAllScreen extends StatefulWidget {
  final String title, cls;
  final List<CategoryVideoModel> freeOrPaidList;
  final List<String> videoUrlList;
  const FreeAndPaidAllScreen(
      {Key? key,
      required this.freeOrPaidList,
      required this.videoUrlList,
      required this.title,
      required this.cls})
      : super(key: key);
  static Route<dynamic> route(RouteSettings routeSettings) {
    Map arguments = routeSettings.arguments as Map;
    return CupertinoPageRoute(
        builder: (context) => FreeAndPaidAllScreen(
              title: arguments['title'],
              freeOrPaidList: arguments['freeOrPaidList'],
              videoUrlList: arguments['videoUrlList'],
              cls: arguments['cls'],
            ));
  }

  @override
  State<StatefulWidget> createState() {
    return FreeAndPaidAllScreenState();
  }
}

class FreeAndPaidAllScreenState extends State<FreeAndPaidAllScreen>
    with TickerProviderStateMixin {
  AnimationController? _animationController;
  String _connectionStatus = 'unKnown';
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> connectivitySubscription;

  bool check = false, isLoadingMore = true, loading = true;
  int currentIndex = 0, offset = 0, total = 0, perPage = 10;
  late Orientation currentOrientation;
  ScrollController controller = ScrollController();
  List<CategoryVideoModel> freeOrPaidList = [];
  List<CategoryVideoModel> tempList = [];
  List<String> videoUrlList = [];
  @override
  void initState() {
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));
    CheckInternet.initConnectivity().then((value) => setState(() {
          _connectionStatus = value;
        }));
    connectivitySubscription =
        _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      CheckInternet.updateConnectionStatus(result).then((value) => setState(() {
            _connectionStatus = value;
          }));
    });
    commonUrlList.clear();
    getVideo(type: widget.cls);
    controller.addListener(_scrollListener);
    super.initState();
  }

// get video API
  Future getVideo({
    int? categoryId,
    String? type,
  }) async {
    String catId = type == categoryKey ? categoryId.toString() : "";
    try {
      final body = {
        typeApiKey: type,
        catIdApiKey: catId,
        limitApiKey: perPage.toString(),
        offsetApiKey: offset.toString(),
      };
      final response = await post(Uri.parse(getVideoUrl),
          body: body, headers: await ApiUtils.getHeaders());
      final responseJson = jsonDecode(response.body);
      total = responseJson["total"];
      if (responseJson['error'] == "true") {
        setState(() {
          DesignConfig.setSnackbar(responseJson['error'], context, false);
        });
      } else {
        var parsedList = responseJson["data"];
        if (type == freeKey) {
          if ((offset) < total) {
            tempList.clear();
            videoUrlList.clear();
            tempList = (parsedList as List)
                .map((data) =>
                    CategoryVideoModel.fromJson(data as Map<String, dynamic>))
                .toList();
            freeOrPaidList.addAll(tempList);
            for (int i = 0; i < freeOrPaidList.length; i++) {
              videoUrlList.add(DesignConfig.getThumbnail(
                  videoId: freeOrPaidList[i].videoId!,
                  type: freeOrPaidList[i].videoType!));
            }
            offset = offset + perPage;
            setState(() {
              loading = false;
            });
          }
        } else if (type == paidKey) {
          if ((offset) < total) {
            tempList.clear();
            videoUrlList.clear();
            tempList = (parsedList as List)
                .map((data) =>
                    CategoryVideoModel.fromJson(data as Map<String, dynamic>))
                .toList();
            freeOrPaidList.addAll(tempList);
            for (int i = 0; i < freeOrPaidList.length; i++) {
              videoUrlList.add(DesignConfig.getThumbnail(
                  videoId: freeOrPaidList[i].videoId!,
                  type: freeOrPaidList[i].videoType!));
            }
            offset = offset + perPage;
            setState(() {
              loading = false;
            });
          }
        }
        setState(() {});
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> refresh() async {
    freeOrPaidList.clear();
    offset = 0;
    await getVideo(type: widget.cls);
  }

  _scrollListener() {
    if (controller.offset >= controller.position.maxScrollExtent &&
        !controller.position.outOfRange) {
      if (mounted) {
        setState(() {
          isLoadingMore = true;
          if ((offset) < total) {
            getVideo(type: widget.cls);
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return _connectionStatus == 'ConnectivityResult.none'
        ? NoConErrorWidget(
            onTap: () {
              setState(() {
                CheckInternet.initConnectivity().then((value) => setState(() {
                      _connectionStatus = value;
                    }));
                connectivitySubscription = _connectivity.onConnectivityChanged
                    .listen((ConnectivityResult result) {
                  CheckInternet.updateConnectionStatus(result)
                      .then((value) => setState(() {
                            _connectionStatus = value;
                          }));
                });
              });
            },
          )
        : Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Theme.of(context).colorScheme.primary,
              leadingWidth: size.width * .18,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20)),
              ),
              titleSpacing: 0,
              leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DesignConfig.backButton(onPress: () {
                    Navigator.pop(context);
                  })),
              title: Text(widget.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: Theme.of(context).secondaryHeaderColor,
                      fontWeight: FontWeight.w700,
                      fontStyle: FontStyle.normal,
                      fontSize: 16.0),
                  textAlign: TextAlign.left),
            ),
            body: RefreshIndicator(
                color: Theme.of(context).primaryColor,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                onRefresh: refresh,
                child: playList(size)),
          );
  }

  Widget playList(dynamic size) {
    return freeOrPaidList.isEmpty
        ? ShimmerWidget(
            height: MediaQuery.of(context).size.height * .11,
            length: 15,
          )
        : ListView.separated(
            itemCount: (offset < total)
                ? freeOrPaidList.length + 1
                : freeOrPaidList.length,
            controller: controller,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).size.height * .01,
              bottom: MediaQuery.of(context).size.height * .1,
            ),
            shrinkWrap: true,
            separatorBuilder: (context, index) {
              if (DesignConfig.getAdsStatus == adsStatusVal) {
                if (index % 5 == 4 && index != 0) {
                  return const AdsWidget();
                }
              }
              return Container();
            },
            itemBuilder: (BuildContext context, int index) {
              return (index == (freeOrPaidList.length) && isLoadingMore)
                  ? Center(
                      child: CircularProgressIndicator(
                      color: Theme.of(context).primaryColor,
                    ))
                  : SlideAnimation(
                      position: index,
                      itemCount: widget.freeOrPaidList.length,
                      slideDirection: SlideDirection.fromTop,
                      animationController: _animationController,
                      child: GestureDetector(
                        onTap: () async {
                          if (widget.cls == freeKey) {
                            if (check) return;
                            currentIndex = index;
                            setState(() {
                              check = true;
                            });
                            commonUrlList.clear();
                            for (int i = 0; i < freeOrPaidList.length; i++) {
                              //await DesignConfig.extractVideoUrl(list[i].videoId!, type);
                              if (i == index) {
                                UrlAndResolutionModel? urls =
                                    await DesignConfig.youtubeCheck(
                                        videoUrl: freeOrPaidList[i].videoId!,
                                        type: freeOrPaidList[i].videoType!);
                                commonUrlList.insert(i, urls!);
                              } else {
                                commonUrlList.insert(
                                    i, UrlAndResolutionModel());
                              }
                            }
                            await Navigator.of(context)
                                .pushNamed(Routes.topNewList, arguments: {
                              "image": videoUrlList[index],
                              "cls": widget.cls,
                              "currentIndex": index,
                              "categoryVideoList": freeOrPaidList,
                              "currentVideoId": freeOrPaidList[index].videoId,
                            });
                            setState(() {
                              check = false;
                            });
                          } else {
                            if (AuthLocalDataSource.getAuthType() ==
                                guestNameApiKey) {
                              Navigator.of(context).pushNamed(Routes.login);
                            } else {
                              if (check) return;
                              currentIndex = index;
                              setState(() {
                                check = true;
                              });
                              commonUrlList.clear();
                              for (int i = 0; i < freeOrPaidList.length; i++) {
                                if (i == index) {
                                  UrlAndResolutionModel? urls =
                                      await DesignConfig.youtubeCheck(
                                          videoUrl: freeOrPaidList[i].videoId!,
                                          type: freeOrPaidList[i].videoType!);
                                  commonUrlList.insert(i, urls!);
                                } else {
                                  commonUrlList.insert(
                                      i, UrlAndResolutionModel());
                                }
                              }
                              await Navigator.of(context)
                                  .pushNamed(Routes.topNewList, arguments: {
                                "image": videoUrlList[index],
                                "subTitle": freeOrPaidList[index].description,
                                "title": freeOrPaidList[index].title,
                                "cls": "video",
                                "currentIndex": index,
                                "categoryVideoList": freeOrPaidList,
                                "currentVideoId": freeOrPaidList[index].videoId,
                              });
                              setState(() {
                                check = false;
                              });
                            }
                          }
                        },
                        onDoubleTap: () {},
                        child: (currentIndex == index && check)
                            ? DesignConfig.onTapLoader(context)
                            : CommonCardForAllWidget(
                                index: index,
                                list: freeOrPaidList,
                                videoList: videoUrlList,
                              ),
                      ),
                    );
            },
          );
  }
}
