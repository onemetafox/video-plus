import 'dart:async';
import 'dart:convert';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

import '../../../App/Routes.dart';
import '../../../LocalDataStore/AuthLocalDataStore.dart';
import '../../../LocalDataStore/SettingLocalDataSource.dart';
import '../../../Utils/ColorRes.dart';
import '../../../Utils/Constant.dart';
import '../../../Utils/DesignConfig.dart';
import '../../../Utils/InternetConnectivity.dart';
import '../../../Utils/SlideAnimation.dart';
import '../../../Utils/StringRes.dart';
import '../../../Utils/apiParameters.dart';
import '../../../Utils/apiUtils.dart';
import '../../../model/CategoryVideoModel.dart';
import '../../../model/urlAndResolutionModel.dart';
import '../../Widget/AdsWidget.dart';
import '../../Widget/commonCardForAllWidget.dart';
import '../../Widget/shimmerWidget.dart';
import '../ErrorWidget/NoConErrorWidget.dart';
import '../ErrorWidget/NoVideoErrorWidget.dart';

int offset = 0, total = 0, perPage = 10;

class VideoScreen extends StatefulWidget {
  const VideoScreen({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return VideoScreenState();
  }
}

class VideoScreenState extends State<VideoScreen>
    with TickerProviderStateMixin {
  List<CategoryVideoModel> allVideoList = [];
  List<CategoryVideoModel> freeVideoList = [];
  List<CategoryVideoModel> paidVideoList = [];
  List<CategoryVideoModel> tempList = [];
  List<CategoryVideoModel> demoList = [];
  List<CategoryVideoModel> tempListAll = [];
  List<CategoryVideoModel> tempListFree = [];
  List<CategoryVideoModel> tempListPaid = [];
  final List<String> commonVideo = [];

  String cls =
      DesignConfig.getPaymentMode == paymentStatusVal ? allKey : freeKey;
  bool isLoadingMore = true, isLoading = true, check = false;
  ScrollController controller = ScrollController();
  String _connectionStatus = 'unKnown', radioItem = '1';
  int currentIndex = 0;

  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> connectivitySubscription;
  AnimationController? _animationController;

// get video list from Api
  Future getVideo({
    String? type,
  }) async {
    try {
      final body = {
        typeApiKey: type,
        catIdApiKey: "",
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
        if (mounted) {
          setState(() {
            var parsedList = responseJson["data"];
            if (type == freeKey) {
              if ((offset) < total) {
                tempListFree.clear();
                freeVideoList.clear();
                allVideoList.clear();
                paidVideoList.clear();
                tempListFree = (parsedList as List)
                    .map((data) => CategoryVideoModel.fromJson(
                        data as Map<String, dynamic>))
                    .toList();
                freeVideoList.addAll(tempListFree);
                demoList.addAll(tempListFree);
                for (int i = 0; i < freeVideoList.length; i++) {
                  commonVideo.add(DesignConfig.getThumbnail(
                      videoId: freeVideoList[i].videoId!,
                      type: freeVideoList[i].videoType!));
                }
                offset = offset + perPage;
              }
            } else if (type == allKey) {
              if ((offset) < total) {
                tempListAll.clear();
                commonVideo.clear();
                freeVideoList.clear();
                allVideoList.clear();
                paidVideoList.clear();
                tempListAll = (parsedList as List)
                    .map((data) => CategoryVideoModel.fromJson(
                        data as Map<String, dynamic>))
                    .toList();
                allVideoList.addAll(tempListAll);
                demoList.addAll(tempListAll);
                for (int i = 0; i < demoList.length; i++) {
                  commonVideo.add(DesignConfig.getThumbnail(
                      videoId: demoList[i].videoId!,
                      type: demoList[i].videoType!));
                }
                offset = offset + perPage;
              }
            } else if (type == paidKey) {
              if ((offset) < total) {
                tempListPaid.clear();
                freeVideoList.clear();
                allVideoList.clear();
                paidVideoList.clear();
                tempListPaid = (parsedList as List)
                    .map((data) => CategoryVideoModel.fromJson(
                        data as Map<String, dynamic>))
                    .toList();
                paidVideoList.addAll(tempListPaid);
                demoList.addAll(tempListPaid);
                for (int i = 0; i < paidVideoList.length; i++) {
                  commonVideo.add(DesignConfig.getThumbnail(
                      videoId: paidVideoList[i].videoId!,
                      type: paidVideoList[i].videoType!));
                }
                offset = offset + perPage;
              }
            }
          });
        }
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> callApi() async {
    await getVideo(type: cls);
  }

  Future<void> refresh() async {
    allVideoList = [];
    freeVideoList = [];
    paidVideoList = [];
    tempList = [];
    demoList = [];
    tempListAll = [];
    tempListFree = [];
    tempListPaid = [];
    commonVideo.clear();
    offset = 0;
    getVideo(type: cls);
  }

  _scrollListener() {
    if (controller.offset >= controller.position.maxScrollExtent &&
        !controller.position.outOfRange) {
      if (mounted) {
        setState(() {
          isLoadingMore = true;
          if ((offset) < total) {
            getVideo(type: cls);
          }
        });
      }
    }
  }

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
    callApi();
    controller.addListener(_scrollListener);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return _connectionStatus == 'ConnectivityResult.none'
        ? NoConErrorWidget(
            onTap: () {
              setState(() {
                callApi();
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
              title: Text(StringRes.videos,
                  style: TextStyle(
                      color: Theme.of(context).secondaryHeaderColor,
                      fontWeight: FontWeight.w700,
                      fontStyle: FontStyle.normal,
                      fontSize: 24.0),
                  textAlign: TextAlign.left),
              actions: [
                (DesignConfig.getPaymentMode == paymentStatusVal)
                    ? filter()
                    : Container(),
                const SizedBox(
                  width: 20,
                ),
              ],
            ),
            body: list(),
          );
  }

  Widget filter() {
    return DesignConfig.iconButton(
        iconColor: Theme.of(context).secondaryHeaderColor,
        color: Theme.of(context).scaffoldBackgroundColor,
        icon: "filter.svg",
        onPress: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return StatefulBuilder(builder: (BuildContext context,
                  StateSetter setStater /*You can rename this! */) {
                return Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * .07,
                          right: MediaQuery.of(context).size.width * .06),
                      child: Material(
                        color: Theme.of(context).colorScheme.primary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0)),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * .5,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              RadioListTile(
                                  dense: true,
                                  controlAffinity:
                                      ListTileControlAffinity.trailing,
                                  groupValue: radioItem,
                                  activeColor:
                                      Theme.of(context).secondaryHeaderColor,
                                  onChanged: (value) {
                                    setState(() {
                                      setStater(() {
                                        radioItem = value.toString();
                                        demoList.clear();
                                        commonVideo.clear();
                                        offset = 0;
                                        cls = allKey;
                                        getVideo(type: cls);
                                        Navigator.pop(context);
                                      });
                                    });
                                  },
                                  value: "1",
                                  title: Text(
                                    "All",
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .secondaryHeaderColor,
                                        fontWeight: FontWeight.w500,
                                        fontStyle: FontStyle.normal,
                                        fontSize: 18.0),
                                  )),
                              Container(
                                  margin: const EdgeInsets.only(
                                      left: 15, right: 25),
                                  height: 0.5,
                                  decoration: const BoxDecoration(
                                      color: Color(0x7f181818))),
                              RadioListTile(
                                  controlAffinity:
                                      ListTileControlAffinity.trailing,
                                  groupValue: radioItem,
                                  activeColor:
                                      Theme.of(context).secondaryHeaderColor,
                                  onChanged: (value) {
                                    setState(() {
                                      setStater(() {
                                        radioItem = value.toString();
                                        demoList.clear();
                                        commonVideo.clear();
                                        offset = 0;
                                        cls = freeKey;
                                        getVideo(type: cls);
                                        Navigator.pop(context);
                                      });
                                    });
                                  },
                                  value: "2",
                                  title: Text("Free",
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .secondaryHeaderColor,
                                          fontWeight: FontWeight.w500,
                                          fontStyle: FontStyle.normal,
                                          fontSize: 18.0),
                                      textAlign: TextAlign.left)),
                              Container(
                                  margin: const EdgeInsets.only(
                                      left: 15, right: 25),
                                  height: 0.5,
                                  decoration: const BoxDecoration(
                                      color: Color(0x7f181818))),
                              (DesignConfig.getPaymentMode == paymentStatusVal)
                                  ? RadioListTile(
                                      controlAffinity:
                                          ListTileControlAffinity.trailing,
                                      groupValue: radioItem,
                                      activeColor: Theme.of(context)
                                          .secondaryHeaderColor,
                                      onChanged: (value) {
                                        setState(() {
                                          setStater(() {
                                            radioItem = value.toString();
                                            demoList.clear();
                                            commonVideo.clear();
                                            offset = 0;
                                            cls = paidKey;
                                            getVideo(type: cls);
                                            Navigator.pop(context);
                                          });
                                        });
                                      },
                                      value: "3",
                                      title: Text(StringRes.premiums,
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .secondaryHeaderColor,
                                              fontWeight: FontWeight.w500,
                                              fontStyle: FontStyle.normal,
                                              fontSize: 18.0),
                                          textAlign: TextAlign.left))
                                  : const SizedBox.shrink(),
                              Container(
                                  margin: const EdgeInsets.only(
                                      left: 15, right: 25),
                                  height: 0.5,
                                  decoration: const BoxDecoration(
                                      color: Color(0x7f181818))),
                            ],
                          ),
                        ),
                      ),
                    ));
              });
            },
          );
        },
        size: MediaQuery.of(context).size);
  }

  Widget list() {
    return commonVideo.isEmpty
        ? ShimmerWidget(
            height: MediaQuery.of(context).size.height * .11,
            length: 15,
          )
        : demoList.isEmpty
            ? const NoVideoErrorWidget()
            : RefreshIndicator(
                color: Theme.of(context).primaryColor,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                onRefresh: refresh,
                child: ListView.separated(
                    controller: controller,
                    itemCount: (offset < total)
                        ? demoList.length + 1
                        : demoList.length,
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
                      return (index == (demoList.length) && isLoadingMore)
                          ? Center(
                              child: CircularProgressIndicator(
                              color: Theme.of(context).primaryColor,
                            ))
                          : listData(demoList, index);
                    }));
  }

  Widget listData(List<CategoryVideoModel> list, int index) {
    return SlideAnimation(
      position: index,
      itemCount: list.length,
      slideDirection: SlideDirection.fromBottom,
      animationController: _animationController,
      child: GestureDetector(
        onTap: () async {
          if (AuthLocalDataSource.getAuthType() == guestNameApiKey &&
              list[index].type == 1) {
            Navigator.of(context).pushNamed(Routes.login);
          } else {
            if (check) return;
            currentIndex = index;
            setState(() {
              check = true;
            });
            commonUrlList.clear();
            for (int i = 0; i < list.length; i++) {
              if (i == index) {
                UrlAndResolutionModel? urls = await DesignConfig.youtubeCheck(
                    videoUrl: list[i].videoId!, type: list[i].videoType!);
                commonUrlList.insert(i, urls!);
              } else {
                commonUrlList.insert(i, UrlAndResolutionModel());
              }
            }
            await Navigator.of(context)
                .pushNamed(Routes.topNewList, arguments: {
              "image": commonVideo[index],
              "cls": cls,
              "currentIndex": index,
              "categoryVideoList": list,
              "currentVideoId": list[index].videoId!,
            });
            setState(() {
              check = false;
            });
          }
        },
        onDoubleTap: () {},
        child: (currentIndex == index && check)
            ? DesignConfig.onTapLoader(context)
            : CommonCardForAllWidget(
                index: index,
                list: list,
                videoList: commonVideo,
              ),
      ),
    );
  }
}
