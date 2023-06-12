import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:videoPlus/Utils/DesignConfig.dart';
import 'package:videoPlus/Utils/StringRes.dart';

import '../../../App/Routes.dart';
import '../../../LocalDataStore/AuthLocalDataStore.dart';
import '../../../Provider/ThemeProvider.dart';
import '../../../Utils/Constant.dart';
import '../../../Utils/InternetConnectivity.dart';
import '../../../Utils/apiParameters.dart';
import '../../../Utils/apiUtils.dart';
import '../../../model/CategoryVideoModel.dart';
import '../../../model/urlAndResolutionModel.dart';
import '../../Widget/CommonCardWidget.dart';
import '../../Widget/shimmerWidget.dart';
import '../ErrorWidget/NoConErrorWidget.dart';

class CategoryScreen extends StatefulWidget {
  final String totalVideo, title, description, image;
  final int categoryId;
  const CategoryScreen({
    Key? key,
    required this.totalVideo,
    required this.title,
    required this.description,
    required this.categoryId,
    required this.image,
  }) : super(key: key);
  static Route<dynamic> route(RouteSettings routeSettings) {
    Map arguments = routeSettings.arguments as Map;
    return CupertinoPageRoute(
        builder: (context) => CategoryScreen(
              totalVideo: arguments['totalVideo'],
              title: arguments['title'],
              description: arguments['description'],
              categoryId: arguments['categoryId'],
              image: arguments['image'],
            ));
  }

  @override
  State<StatefulWidget> createState() {
    return CategoryScreenState();
  }
}

class CategoryScreenState extends State<CategoryScreen> {
  bool check = false, noCon = false, isLoadingMore = true, isLoading = true;
  String radioItem = '', _connectionStatus = 'unKnown';
  int offset = 0, total = 0, perPage = 10, currentIndex = 0;
  List<CategoryVideoModel> categoryVideoList = [];
  List<CategoryVideoModel> paidVideoList = [];
  List<CategoryVideoModel> freeVideoList = [];
  List<CategoryVideoModel> demoList = [];
  final List<String> _videoCat = [];
  final List<String> _videoPaid = [];
  final List<String> _videoFree = [];
  List<CategoryVideoModel> tempListCat = [];
  List<CategoryVideoModel> tempListPaid = [];

  ScrollController controller = ScrollController();
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> connectivitySubscription;

  @override
  void initState() {
    DesignConfig.getAdsStatus == adsStatusVal
        ? DesignConfig.createInterstitialAd()
        : null;
    CheckInternet.initConnectivity().then((value) => setState(() {
          _connectionStatus = value;
        }));
    connectivitySubscription =
        _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      CheckInternet.updateConnectionStatus(result).then((value) => setState(() {
            _connectionStatus = value;
          }));
    });
    DesignConfig.getAdsStatus == adsStatusVal
        ? DesignConfig.showInterstitialAd()
        : null;
    callApi();
    controller.addListener(_scrollListener);

    super.initState();
  }

//scroll Listener for load more
  _scrollListener() {
    if (controller.offset >= controller.position.maxScrollExtent &&
        !controller.position.outOfRange) {
      if (mounted) {
        setState(() {
          isLoadingMore = true;
          if ((offset) < total) {
            getVideo(Type: categoryKey);
          }
        });
      }
    }
  }

  Future<void> callApi() async {
    demoList.clear();
    _videoCat.clear();
    offset = 0;
    await getVideo(Type: categoryKey);
  }

// get video list from Api
  Future getVideo({
    String? Type,
  }) async {
    String catId = Type == categoryKey ? widget.categoryId.toString() : "";
    try {
      final body = {
        typeApiKey: Type,
        catIdApiKey: catId,
        limitApiKey: perPage.toString(),
        offsetApiKey: offset.toString(),
      };
      final response = await post(Uri.parse(getVideoUrl),
          body: body, headers: await ApiUtils.getHeaders());
      final responseJson = jsonDecode(response.body);
      print("==get all type videos  ========$responseJson");
      total = responseJson["total"];
      if (responseJson['error'] == "true") {
        setState(() {
          DesignConfig.setSnackbar(responseJson['error'], context, false);
        });
      } else {
        if (mounted) {
          setState(() {
            var parsedList = responseJson["data"];
            if (Type == categoryKey) {
              if ((offset) < total) {
                tempListCat.clear();
                tempListCat = (parsedList as List)
                    .map((data) => CategoryVideoModel.fromJson(
                        data as Map<String, dynamic>))
                    .toList();

                categoryVideoList.addAll(tempListCat);
                demoList.addAll(DesignConfig.getPaymentMode == paymentStatusVal
                    ? tempListCat
                    : tempListCat.where((element) => element.type == 0));
                paidVideoList
                    .addAll(tempListCat.where((c) => c.type == 1).toList());
                freeVideoList
                    .addAll(tempListCat.where((c) => c.type == 0).toList());
                //  allUrlList.clear();
                for (int i = 0; i < categoryVideoList.length; i++) {
                  _videoCat.add(DesignConfig.getThumbnail(
                      videoId: categoryVideoList[i].videoId!,
                      type: categoryVideoList[i].videoType!));
                }
                for (int i = 0; i < paidVideoList.length; i++) {
                  _videoPaid.add(DesignConfig.getThumbnail(
                      videoId: paidVideoList[i].videoId!,
                      type: paidVideoList[i].videoType!));
                }
                for (int i = 0; i < freeVideoList.length; i++) {
                  _videoFree.add(DesignConfig.getThumbnail(
                      videoId: freeVideoList[i].videoId!,
                      type: freeVideoList[i].videoType!));
                }
                offset = offset + perPage;
              }
            }
          });
        }
      }
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print(e.toString());
    }
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
            body: SafeArea(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                topImage(size),
                playList(
                    size,
                    radioItem == "1"
                        ? paidVideoList
                        : radioItem == "2"
                            ? freeVideoList
                            : demoList),
              ]),
            ),
          );
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget topImage(dynamic size) {
    return isLoading
        ? Shimmer.fromColors(
            baseColor: Provider.of<ThemeNotifier>(context).getThemeMode() ==
                    ThemeMode.dark
                ? Colors.white30
                : Colors.grey[300]!,
            highlightColor:
                Provider.of<ThemeNotifier>(context).getThemeMode() ==
                        ThemeMode.dark
                    ? Colors.white30
                    : Colors.grey[100]!,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * .35,
              margin: const EdgeInsets.all(20),
              color: Colors.white,
            ))
        : Stack(
            children: [
              SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * .3,
                  child: CachedNetworkImage(
                    fit: BoxFit.cover,
                    imageUrl: widget.image,
                    imageBuilder: (context, imageProvider) => Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    placeholder: (context, url) => Shimmer.fromColors(
                        baseColor: Provider.of<ThemeNotifier>(context)
                                    .getThemeMode() ==
                                ThemeMode.dark
                            ? Colors.white30
                            : Colors.grey[300]!,
                        highlightColor: Provider.of<ThemeNotifier>(context)
                                    .getThemeMode() ==
                                ThemeMode.dark
                            ? Colors.white30
                            : Colors.grey[100]!,
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height * .3,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                          ),
                        )),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                  )),
              Container(
                height: MediaQuery.of(context).size.height * .3,
                width: MediaQuery.of(context).size.width,
                //color: Colors.black26,
                decoration: const BoxDecoration(
                    gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black12,
                    Colors.black87
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0, 0.2, 0.6, 1],
                )),
                margin: const EdgeInsets.only(bottom: 10),
                // padding: const EdgeInsets.only(bottom: 8.0),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: ListTile(
                      horizontalTitleGap: 0,
                      dense: true,
                      visualDensity:
                          const VisualDensity(horizontal: -4, vertical: -2),
                      title: Text(
                          widget.title[0].toUpperCase() +
                              widget.title.substring(1),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: Colors.white,
                              height: 1,
                              fontWeight: FontWeight.w700,
                              fontStyle: FontStyle.normal,
                              fontSize: 18.0),
                          textAlign: TextAlign.left),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 2.0),
                        child: Text(
                            "${widget.totalVideo} ${widget.totalVideo.toString() == "0" || widget.totalVideo.toString() == "1" ? "Video" : "Videos"}",
                            maxLines: 1,
                            softWrap: true,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: Colors.white70,
                                height: 1,
                                fontWeight: FontWeight.w400,
                                fontStyle: FontStyle.normal,
                                fontSize: 12.0),
                            textAlign: TextAlign.left),
                      ),
                      trailing: DesignConfig.getPaymentMode == paymentStatusVal
                          ? filter()
                          : const SizedBox.shrink()),
                ),
              ),
              Container(
                  margin: EdgeInsets.only(
                      top: size.height * .02, left: size.width * .04),
                  child: DesignConfig.backButton(onPress: () {
                    Navigator.pop(context);
                  })),
            ],
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
              return StatefulBuilder(
                  builder: (BuildContext context, StateSetter setStater) {
                return Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * .3,
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
                                  controlAffinity:
                                      ListTileControlAffinity.trailing,
                                  groupValue: radioItem,
                                  activeColor:
                                      Theme.of(context).secondaryHeaderColor,
                                  onChanged: (value) {
                                    setState(() {
                                      setStater(() {
                                        radioItem = value.toString();

                                        Navigator.pop(context);
                                      });
                                    });
                                  },
                                  value: "1",
                                  title: Text(StringRes.premiums,
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
                                        Navigator.pop(context);
                                      });
                                    });
                                  },
                                  value: "2",
                                  title: Text(StringRes.free,
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .secondaryHeaderColor,
                                          fontWeight: FontWeight.w500,
                                          fontStyle: FontStyle.normal,
                                          fontSize: 18.0),
                                      textAlign: TextAlign.left)),
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

  Widget playList(dynamic size, List<CategoryVideoModel> list) {
    return Flexible(
        fit: FlexFit.loose,
        child: Container(
          margin: const EdgeInsets.only(
              left: 14.0, right: 14.0), //left: 15.0, right: 15.0
          child: isLoading
              ? ShimmerWidget(
                  height: MediaQuery.of(context).size.height * .11,
                  length: 5,
                )
              : RefreshIndicator(
                  color: Theme.of(context).primaryColor,
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  onRefresh: callApi,
                  child: ListView.builder(
                    controller: controller,
                    itemCount: (offset < total) ? list.length + 1 : list.length,
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemBuilder: (BuildContext context, int index) {
                      return (index == demoList.length && isLoadingMore)
                          ? Center(
                              child: CircularProgressIndicator(
                              color: Theme.of(context).primaryColor,
                            ))
                          : listData(
                              radioItem == "1"
                                  ? paidVideoList
                                  : radioItem == "2"
                                      ? freeVideoList
                                      : demoList,
                              index);
                    },
                  ),
                ),
        ));
  }

  Widget listData(List<CategoryVideoModel> list, int index) {
    return GestureDetector(
      onTap: () async {
        if (AuthLocalDataSource.getAuthType() == guestNameApiKey &&
            list[index].type == 1) {
          Navigator.of(context).pushNamed(Routes.login);
          /*   Navigator.of(context).pushNamedAndRemoveUntil(
                '/login', (Route<dynamic> route) => false);*/
        } /*else if (list[index].type == 1 &&
            AuthLocalDataSource.getIsSubscribe() == subscribeStatusVal) {
          Navigator.of(context).pushNamed(Routes.buyMembership);
        }*/
        else {
          currentIndex = index;
          if (check) return;
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
          await Navigator.of(context).pushNamed(Routes.topNewList, arguments: {
            "cls": "cat",
            "currentIndex": index,
            "categoryVideoList": list,
            "currentVideoId": list[index].videoId,
          });
          setState(() {
            check = false;
          });
        }
      },
      onDoubleTap: () {},
      child: (currentIndex == index && check)
          ? Container(
              height: MediaQuery.of(context).size.height * .11,
              margin: const EdgeInsets.only(top: 5, bottom: 5),
              child: Card(
                color: Theme.of(context).colorScheme.primary,
                shadowColor: Colors.black12,
                margin: EdgeInsets.zero,
                elevation: 15,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
                child: Center(
                  child: CircularProgressIndicator(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ))
          : CommonCardCategoryWidget(
              index: index,
              list: list,
              videoList: radioItem == "1"
                  ? _videoPaid
                  : radioItem == "2"
                      ? _videoFree
                      : _videoCat),
    );
  }
}
