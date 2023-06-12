import 'dart:async';
import 'dart:convert';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:videoPlus/Ui/Screens/ErrorWidget/NoVideoErrorWidget.dart';
import 'package:videoPlus/Utils/DesignConfig.dart';
import 'package:videoPlus/model/CategoryVideoModel.dart';

import '../../../App/Routes.dart';
import '../../../LocalDataStore/AuthLocalDataStore.dart';
import '../../../Provider/saveVideoListProvider.dart';
import '../../../Utils/Constant.dart';
import '../../../Utils/InternetConnectivity.dart';
import '../../../Utils/SlideAnimation.dart';
import '../../../Utils/apiParameters.dart';
import '../../../Utils/apiUtils.dart';
import '../../../model/GetPlayListModel.dart';
import '../../../model/urlAndResolutionModel.dart';
import '../../Widget/commonDurationWidget.dart';
import '../../Widget/commonPremiumIconWidget.dart';
import '../ErrorWidget/NoConErrorWidget.dart';

class SaveVideoDetailScreen extends StatefulWidget {
  final String title;
  const SaveVideoDetailScreen({Key? key, required this.title})
      : super(key: key);
  static Route<dynamic> route(RouteSettings routeSettings) {
    Map arguments = routeSettings.arguments as Map;
    return CupertinoPageRoute(
        builder: (context) => SaveVideoDetailScreen(
              title: arguments['title'],
            ));
  }

  @override
  State<StatefulWidget> createState() {
    return SaveVideoDetailScreenState();
  }
}

class SaveVideoDetailScreenState extends State<SaveVideoDetailScreen>
    with TickerProviderStateMixin {
  AnimationController? _animationController;
  final List<String> _video = [];
  String _connectionStatus = 'unKnown';
  final Connectivity _connectivity = Connectivity();
  int currentIndex = -1, selectIndex = 0;
  List<Videos> videoList = [];
  bool isLoading = false;
  late StreamSubscription<ConnectivityResult> connectivitySubscription;
  List<CategoryVideoModel> data = [];

  Future deletePlayList(int typeId) async {
    try {
      final body = {
        userIdApiKey: AuthLocalDataSource.getUserId(),
        typeApiKey: videoKey,
        typeIdApiKey: typeId.toString()
      };
      final response = await post(Uri.parse(removePlaylistOrVideoUrl),
          body: body, headers: await ApiUtils.getHeaders());
      final responseJson = jsonDecode(response.body);
      debugPrint("===deletePlayList ========$responseJson");
      if (responseJson['error'] == true) {
        setState(() {
          DesignConfig.setSnackbar(responseJson['message'], context, false);
        });
      } else {
        setState(() {
          videoList.removeAt(currentIndex);
          _video.removeAt(currentIndex);
        });
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  void initState() {
    CheckInternet.initConnectivity().then((value) => setState(() {
          _connectionStatus = value;
        }));
    connectivitySubscription =
        _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      CheckInternet.updateConnectionStatus(result).then((value) => setState(() {
            _connectionStatus = value;
          }));
    });
    // checkAwait();
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));
    super.initState();
  }

  Map<String, Videos> mp = {};
  List<GetPlayListModel> saveVideoList = [];
  @override
  Widget build(BuildContext context) {
    videoList = Provider.of<SaveVideoProvider>(context).getVideosList;
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
        : WillPopScope(
            onWillPop: () {
              Navigator.of(context).pushReplacementNamed(Routes.savedVideos);
              return Future.value(false);
            },
            child: Scaffold(
              appBar: AppBar(
                elevation: 0,
                backgroundColor: Theme.of(context).colorScheme.primary,
                leadingWidth: size.width * .18,
                titleSpacing: 0,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20)),
                ),
                leading: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: DesignConfig.backButton(onPress: () {
                      Navigator.of(context)
                          .pushReplacementNamed(Routes.savedVideos);
                      // Navigator.pop(context);
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
              body: videoList.isEmpty
                  ? const NoVideoErrorWidget()
                  : playList(size),
            ));
  }

  Widget playList(dynamic size) {
    return SizedBox(
      height: size.height,
      child: ListView.builder(
        itemCount: videoList.length,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).size.height * .01,
          bottom: MediaQuery.of(context).size.height * .1,
        ),
        shrinkWrap: true,
        itemBuilder: (BuildContext context, int index) {
          Videos item = videoList[index];
          _video.add(DesignConfig.getThumbnail(
              videoId: videoList[index].videoId!,
              type: videoList[index].videoType!));
          return SlideAnimation(
              position: index,
              itemCount: videoList.length,
              slideDirection: SlideDirection.fromBottom,
              animationController: _animationController,
              child: GestureDetector(
                onTap: () async {
                  if (isLoading) return;
                  selectIndex = index;
                  setState(() {
                    isLoading = true;
                  });
                  /*topNewUrlList.clear();
                        for (int i = 0; i < allVideoList.length; i++) {
                          if (i == index) {
                            UrlAndResolutionModel? urls =
                                (await DesignConfig.youtubeCheck(
                                    videoUrl: allVideoList[i].videoId!,
                                    type: allVideoList[i].videoType!));
                            topNewUrlList.insert(i, urls!);
                          } else {
                            topNewUrlList.insert(i, UrlAndResolutionModel());
                          }
                        }*/

                  commonUrlList.clear();
                  for (int i = 0; i < videoList.length; i++) {
                    //await DesignConfig.extractVideoUrl(list[i].videoId!, type);
                    if (i == index) {
                      UrlAndResolutionModel? urls =
                          await DesignConfig.youtubeCheck(
                              videoUrl: videoList[i].videoId!,
                              type: videoList[i].videoType!);
                      commonUrlList.insert(i, urls!);
                    } else {
                      commonUrlList.insert(i, UrlAndResolutionModel());
                    }
                  }
                  await Navigator.of(context)
                      .pushNamed(Routes.topNewList, arguments: {
                    "cls": "save",
                    "currentIndex": index,
                    "categoryVideoList": data,
                    "currentVideoId": item.videoId,
                    'saveVideoList': videoList
                  });
                  setState(() {
                    isLoading = false;
                  });
                },
                onDoubleTap: () {},
                child: (selectIndex == index && isLoading)
                    ? DesignConfig.onTapLoader(context)
                    : Container(
                        height: MediaQuery.of(context).size.height * .11,
                        margin: const EdgeInsets.only(
                            top: 5, bottom: 5, left: 15, right: 15),
                        child: Card(
                            color: Theme.of(context).colorScheme.primary,
                            shadowColor: Colors.black12,
                            margin: EdgeInsets.zero,
                            elevation: 20,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(borderRadius),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: MediaQuery.of(context).size.width *
                                      .33 /*116*/,
                                  height:
                                      MediaQuery.of(context).size.height * .093,
                                  margin: const EdgeInsets.only(left: 8),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(borderRadius),
                                        child: Image.network(
                                          (item.image != null &&
                                                  item.image!.isNotEmpty)
                                              ? item.image!
                                              : _video[index],
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      item.type == 1
                                          ? const CommonPremiumIconWidget()
                                          : const SizedBox.shrink(),
                                      /*   ? Positioned(
                                              top: 0,
                                              left: 0,
                                              child: Container(
                                                decoration: const BoxDecoration(
                                                    color: Color(0x80000000),
                                                    borderRadius: BorderRadius.only(
                                                        topLeft:
                                                            Radius.circular(
                                                                borderRadius),
                                                        bottomRight:
                                                            Radius.circular(
                                                                borderRadius))),
                                                height: 35,
                                                width: 35,
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: SvgPicture.asset(
                                                    DesignConfig.getIconPath(
                                                        "premium_icon.svg")),
                                              ))
                                          : Container(), */
                                      CommonDurationWidget(
                                          durationValue: item.duration,
                                          isBottomRadius: true),
                                      /* Positioned(
                                        bottom: 0,
                                        right: 0,
                                        // top: MediaQuery.of(context).size.height * .18,
                                        child: Container(
                                            height: 20,
                                            alignment: Alignment.center,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                .15,
                                            decoration: const BoxDecoration(
                                                color: Colors.black54,
                                                borderRadius: BorderRadius.only(
                                                    bottomRight:
                                                        Radius.circular(
                                                            borderRadius))),
                                            child: Text(item.duration!,
                                                style: const TextStyle(
                                                    color: Color(0xffffffff),
                                                    fontWeight: FontWeight.w400,
                                                    fontStyle: FontStyle.normal,
                                                    fontSize: 12.0),
                                                textAlign: TextAlign.left)),
                                      ) */
                                    ],
                                  ),
                                ),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * .42,
                                  margin:
                                      const EdgeInsets.only(left: 8, right: 8),
                                  alignment: Alignment.centerLeft,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                          item.title![0].toUpperCase() +
                                              item.title!.substring(1),
                                          maxLines: 2,
                                          softWrap: true,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .secondaryHeaderColor,
                                              height: 1,
                                              fontWeight: FontWeight.normal,
                                              fontSize: 16.0),
                                          textAlign: TextAlign.left),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: MediaQuery.of(context).size.width * .1,
                                  alignment: Alignment.center,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        currentIndex = index;
                                      });
                                      deletePlayList(item.playlistVideoId!);
                                    },
                                    child: SvgPicture.asset(
                                        DesignConfig.getIconPath("delete.svg")),
                                  ),
                                ),
                              ],
                            )),
                      ),
              ));
        },
      ),
    );
  }
}
