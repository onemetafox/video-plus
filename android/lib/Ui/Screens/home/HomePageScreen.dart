import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart';
// import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:videoPlus/LocalDataStore/AuthLocalDataStore.dart';
import 'package:videoPlus/Provider/videoHistoryProvider.dart';
import 'package:videoPlus/Ui/Widget/commonPremiumIconWidget.dart';
import 'package:videoPlus/Utils/generalMethods.dart';

import '../../../App/Routes.dart';
import '../../../LocalDataStore/SettingLocalDataSource.dart';
import '../../../Provider/ThemeProvider.dart';
import '../../../Provider/categoryProvider.dart';
import '../../../Utils/ColorRes.dart';
import '../../../Utils/Constant.dart';
import '../../../Utils/DesignConfig.dart';
import '../../../Utils/InternetConnectivity.dart';
import '../../../Utils/PushNotification.dart';
import '../../../Utils/SlideAnimation.dart';
import '../../../Utils/StringRes.dart';
import '../../../Utils/apiParameters.dart';
import '../../../Utils/apiUtils.dart';
import '../../../main.dart';
import '../../../model/CategoryModel.dart';
import '../../../model/CategoryVideoModel.dart';
import '../../../model/SliderModel.dart';
import '../../../model/urlAndResolutionModel.dart';
import '../../Widget/commonCardForAllWidget.dart';
import '../../Widget/commonDurationWidget.dart';
import '../ErrorWidget/NoConErrorWidget.dart';

class HomePageScreen extends StatefulWidget {
  const HomePageScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return HomePageScreenState();
  }
}

class HomePageScreenState extends State<HomePageScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  bool isLoading = true, sliderLoading = true;
  int categoryIndexId = 0;
  List<CategoryVideoModel> tempCategoryVideoList = [];
  List<CategoryVideoModel> categoryVideoList = [];
  List<CategoryVideoModel> tempAllVideoList = [];
  List<CategoryVideoModel> allVideoList = [];
  List<CategoryModel> categoryListProvider = [];
  List<CategoryVideoModel> freeVideoList = [];
  List<CategoryVideoModel> paidVideoList = [];
  List<CategoryVideoModel> videoHistoryList = [];

  ScrollController scrollController = ScrollController();

  final List<String> videoAll = [];
  final List<String> videoFree = [];
  final List<String> videoCat = [];
  final List<String> videoSlider = [];
  final List<String> videoPaid = [];
  List<String> videoHistory = [];

  List<CategoryModel> categoryList = [];
  List<SliderModel> sliderList = [];
  List<SliderModel> sliderListTemp = [];
  List<SliderModel> sliderList1 = [];
// only one time tap on card
  int allVideoIndex = -1,
      freeVideoIndex = -1,
      paidVideoIndex = -1,
      sliderVideoIndex = -1,
      sliderIndexCheck = 0;
  bool allCheck = false,
      freeCheck = false,
      paidCheck = false,
      sliderCheck = false,
      autoPlaySlider = true;

  String _connectionStatus = 'unKnown';
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> connectivitySubscription;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  AnimationController? _animationController;

  Future<void> initDynamicLinks() async {
    dynamicLinks.onLink.listen((dynamicLinkData) async {
      final Uri deepLink = dynamicLinkData.link;
      if (deepLink.queryParameters.isNotEmpty) {
        int index = int.parse(deepLink.queryParameters['index']!);
        // String? title = deepLink.queryParameters["title"];
        String? type = deepLink.queryParameters["type"];
        // String? subTitle = deepLink.queryParameters["subTitle"];
        String? currentVideoId = deepLink.queryParameters["currentVideoId"];
        int? categoryId = int.parse(deepLink.queryParameters["category_id"]!);
        List<CategoryVideoModel> typeList = [];
        if (type == "cat") {
          await getVideo(type: categoryKey, categoryId: categoryId);
        }
        typeList = (type == allKey)
            ? allVideoList
            : type == freeKey
                ? freeVideoList
                : type == paidKey
                    ? paidVideoList
                    : categoryVideoList;
        commonUrlList.clear();
        for (int i = 0; i < typeList.length; i++) {
          if (i == index) {
            UrlAndResolutionModel? urls = await DesignConfig.youtubeCheck(
                videoUrl: typeList[i].videoId!, type: typeList[i].videoType!);
            commonUrlList.insert(i, urls!);
          } else {
            commonUrlList.insert(i, UrlAndResolutionModel());
          }
        }
        Future.delayed(Duration(milliseconds: 5), () async {
          await Navigator.pushNamed(context, Routes.topNewList, arguments: {
            "cls": type,
            "currentIndex": index,
            "categoryVideoList": typeList,
            "currentVideoId": currentVideoId,
          });
        });
      }
    }).onError((error) {
      debugPrint('onLink error');
      debugPrint(error.message);
    });

    final PendingDynamicLinkData? data = await dynamicLinks.getInitialLink();
    final Uri? deepLink = data?.link;
    if (deepLink != null) {
      if (deepLink.queryParameters.length > 0) {
        int index = int.parse(deepLink.queryParameters['index']!);
        // String? title = deepLink.queryParameters["title"];
        String? type = deepLink.queryParameters["type"];
        // String? subTitle = deepLink.queryParameters["subTitle"];
        String? currentVideoId = deepLink.queryParameters["currentVideoId"];
        int? categoryId = int.parse(deepLink.queryParameters["category_id"]!);
        List<CategoryVideoModel> typeList = [];
        if (type == "cat") {
          await getVideo(type: categoryKey, categoryId: categoryId);
        }
        typeList = (type == allKey)
            ? allVideoList
            : type == freeKey
                ? freeVideoList
                : type == paidKey
                    ? paidVideoList
                    : categoryVideoList;
        commonUrlList.clear();
        for (int i = 0; i < typeList.length; i++) {
          if (i == index) {
            UrlAndResolutionModel? urls = await DesignConfig.youtubeCheck(
                videoUrl: typeList[i].videoId!, type: typeList[i].videoType!);
            commonUrlList.insert(i, urls!);
          } else {
            commonUrlList.insert(i, UrlAndResolutionModel());
          }
        }
        Future.delayed(Duration(milliseconds: 5), () async {
          await Navigator.pushNamed(context, Routes.topNewList, arguments: {
            "cls": type,
            "currentIndex": index,
            "categoryVideoList": typeList,
            "currentVideoId": currentVideoId,
          });
        });
      }
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    debugPrint("Fcm:${AuthLocalDataSource.getFcmId()}");
    debugPrint("user id:${AuthLocalDataSource.getUserId()}");
    CheckInternet.initConnectivity().then((value) => setState(() {
          _connectionStatus = value;
        }));
    connectivitySubscription =
        _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      CheckInternet.updateConnectionStatus(result).then((value) => setState(() {
            _connectionStatus = value;
          }));
    });
    firNotificationInitialize();
    callApi();
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2000));

    super.initState();
  }

// fire firebase and local notification
  void firNotificationInitialize() {
    //for firebase push notification
    FlutterLocalNotificationsPlugin();
// initialise the plugin. ic_launcher needs to be a added as a drawable resource to the Android head project
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('notification_icon');
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    /*  onDidReceiveLocalNotification:
          (int id, String? title, String? body, String? payload) async {
        didReceiveLocalNotificationStream.add(
          ReceivedNotification(
            id: id,
            title: title,
            body: body,
            payload: payload,
          ),
        );
      },
      notificationCategories: darwinNotificationCategories,
    ); */
    final LinuxInitializationSettings initializationSettingsLinux =
        LinuxInitializationSettings(
      defaultActionName: 'Open notification',
      defaultIcon: AssetsLinuxIcon('icons/app_icon.png'),
    );
    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      macOS: initializationSettingsDarwin,
      linux: initializationSettingsLinux,
    );
    /* const IOSInitializationSettings initializationSettingsIOS =
        IOSInitializationSettings(
            requestAlertPermission: true,
            requestBadgePermission: true,
            requestSoundPermission: true);
    const MacOSInitializationSettings initializationSettingsMacOS =
        MacOSInitializationSettings(); 
    const InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS,
            macOS: initializationSettingsMacOS);*/

    PushNotificationService.flutterLocalNotificationsPlugin.initialize(
        initializationSettings, onDidReceiveNotificationResponse:
            (NotificationResponse? notiResponse) async {
      if (notiResponse != null && notiResponse.payload == categoryKey) {
        debugPrint('notification payload: $notiResponse');
        Navigator.of(context).pushNamed(Routes.categoryAll,
            arguments: {"categoryList": categoryList});
      } else if (notiResponse != null && notiResponse.payload == videoKey) {
        debugPrint('notification payload: $notiResponse');
        Navigator.of(context).pushNamed(Routes.video);
      } else {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const MyApp()),
            (Route<dynamic> route) => false);
      }
    }
        /* onSelectNotification: (String? payload) async {
      if (payload != null && payload == categoryKey) {
        debugPrint('notification payload: $payload');
        Navigator.of(context).pushNamed(Routes.categoryAll,
            arguments: {"categoryList": categoryList});
      } else if (payload != null && payload == videoKey) {
        debugPrint('notification payload: $payload');
        Navigator.of(context).pushNamed(Routes.video);
      } else {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const MyApp()),
            (Route<dynamic> route) => false);
      }
    } */
        );
  }

//get category APi
  Future getCategory() async {
    try {
      final body = {};
      final response = await post(Uri.parse(getCategoryUrl),
          body: body, headers: await ApiUtils.getHeaders());
      final responseJson = jsonDecode(response.body);
      if (responseJson['error'] == true) {
        if (responseJson['status'] == "Unauthorized access") {
          Navigator.of(context).pushNamedAndRemoveUntil(
              '/login', (Route<dynamic> route) => false);
        }
        setState(() {
          DesignConfig.setSnackbar(responseJson['error'], context, false);
        });
      } else {
        var parsedList = responseJson["data"];
        categoryList = (parsedList as List)
            .map((data) => CategoryModel.fromJson(data as Map<String, dynamic>))
            .toList();
        if (mounted) {
          context.read<CategoryProvider>().changeCategoryList(categoryList);
        }
      }
      setState(() {
        isLoading = false;
        _animationController!.forward();
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

//get slider images API
  Future getSlider() async {
    try {
      final body = {};
      final response = await post(Uri.parse(getSliderUrl),
          body: body, headers: await ApiUtils.getHeaders());
      final responseJson = jsonDecode(response.body);
      if (responseJson['error'] == true) {
        if (responseJson['status'] == "Unauthorized access") {
          setState(() {
            DesignConfig.setSnackbar(
                "Already Login in other device", context, false);
          });
          Navigator.of(context).pushNamedAndRemoveUntil(
              '/login', (Route<dynamic> route) => false);
        }
        setState(() {
          DesignConfig.setSnackbar(responseJson['message'], context, false);
        });
      } else {
        var parsedList = responseJson["data"];
        sliderListTemp = (parsedList as List)
            .map((data) => SliderModel.fromJson(data as Map<String, dynamic>))
            .toList();

        if (DesignConfig.getPaymentMode == paymentModeStatusVal) {
          sliderList.addAll(sliderListTemp
              .where((element) => element.paymentType == 0)
              .toList());
        } else {
          sliderList.addAll(sliderListTemp);
        }
        for (int i = 0; i < sliderList.length; i++) {
          videoSlider.add(DesignConfig.getThumbnail(
              videoId: sliderList[i].videoId!, type: sliderList[i].videoType!));
        }
      }
      setState(() {
        sliderLoading = false;
      });
    } catch (e) {
      debugPrint(e.toString());
    }
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
      };
      final response = await post(Uri.parse(getVideoUrl),
          body: body, headers: await ApiUtils.getHeaders());
      final responseJson = jsonDecode(response.body);
      print("get all type videos*****:$responseJson");
      if (responseJson['error'] == true && type != "paid") {
        if (responseJson['status'] == "Unauthorized access") {
          setState(() {
            DesignConfig.setSnackbar(
                "Already Login in other device", context, false);
          });
          if (mounted) {
            Navigator.of(context).pushNamedAndRemoveUntil(
                '/login', (Route<dynamic> route) => false);
          }
        }
        setState(() {
          DesignConfig.setSnackbar(responseJson['message'], context, false);
        });
      } else {
        // if (mounted) {

        var parsedList = responseJson["data"];
        if (type == categoryKey) {
          tempCategoryVideoList = (parsedList as List)
              .map((data) =>
                  CategoryVideoModel.fromJson(data as Map<String, dynamic>))
              .toList();

          categoryVideoList.addAll(DesignConfig.getPaymentMode == "0"
              ? tempCategoryVideoList.where((element) => element.type == 0)
              : tempCategoryVideoList);
        } else if (type == freeKey) {
          freeVideoList = (parsedList as List)
              .map((data) =>
                  CategoryVideoModel.fromJson(data as Map<String, dynamic>))
              .toList();

          for (int i = 0; i < freeVideoList.length; i++) {
            videoFree.add(DesignConfig.getThumbnail(
                videoId: freeVideoList[i].videoId!,
                type: freeVideoList[i].videoType!));

            // 'https://img.youtube.com/vi/${freeVideoList[i].videoId}/sddefault.jpg');
          }
        } else if (type == allKey) {
          tempAllVideoList = (parsedList as List)
              .map((data) =>
                  CategoryVideoModel.fromJson(data as Map<String, dynamic>))
              .toList();
          if (DesignConfig.getPaymentMode == paymentModeStatusVal) {
            allVideoList
                .addAll(tempAllVideoList.where((c) => c.type == 0).toList());
          } else {
            allVideoList.addAll(tempAllVideoList);
          }
          for (int i = 0; i < allVideoList.length; i++) {
            videoAll.add(DesignConfig.getThumbnail(
                videoId: allVideoList[i].videoId!,
                type: allVideoList[i].videoType!));
          }
        } else if (type == paidKey) {
          paidVideoList = (parsedList as List)
              .map((data) =>
                  CategoryVideoModel.fromJson(data as Map<String, dynamic>))
              .toList();
          for (int i = 0; i < paidVideoList.length; i++) {
            videoPaid.add(DesignConfig.getThumbnail(
                videoId: paidVideoList[i].videoId!,
                type: paidVideoList[i].videoType!));
          }
        }
        setState(() {});
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

//check network connection and call All Api here
  Future<void> callApi() async {
    await getSlider();

    if (AuthLocalDataSource.getAuthType() != guestNameApiKey) {
      //if user loggedIn
      if (mounted) {
        await context
            .read<VideoHistoryProvider>()
            .getVideoHistory(context: context);
        videoHistory = await context.read<VideoHistoryProvider>().getThumbnails;
        print("len of thumbnail img list ${videoHistory.length}");
      }
    }
    await getCategory();
    await getVideo(type: allKey);
    await getVideo(type: freeKey);
    await getVideo(type: paidKey);
    await initDynamicLinks();
  }

  Future<void> refresh() async {
    allVideoList.clear();
    sliderList.clear();
    freeVideoList.clear();
    paidVideoList.clear();
    videoAll.clear();
    videoFree.clear();
    videoCat.clear();
    videoSlider.clear();
    videoPaid.clear();
    await getSlider();
    if (AuthLocalDataSource.getAuthType() != guestNameApiKey) {
      //if user loggedIn
      videoHistory.clear();
      if (mounted) {
        await context
            .read<VideoHistoryProvider>()
            .getVideoHistory(context: context);
        videoHistory = await context.read<VideoHistoryProvider>().getThumbnails;
        print("len of thumbnail img list ${videoHistory.length}");
      }
    }
    await getCategory();
    await getVideo(type: allKey);
    await getVideo(type: freeKey);
    await getVideo(type: paidKey);
  }

  @override
  Widget build(BuildContext context) {
    print("len of list History - ${videoHistoryList.length}");
    final size = MediaQuery.of(context).size;
    categoryListProvider =
        Provider.of<CategoryProvider>(context).getCategoryList;
    return _connectionStatus == 'ConnectivityResult.none'
        ? NoConErrorWidget(
            onTap: () {
              setState(() {
                callApi();
              });
            },
          )
        : Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              toolbarHeight: size.height * .08,
              elevation: 2,
              backgroundColor:
                  SettingsLocalDataSource().theme() == StringRes.darkThemeKey
                      ? darkButtonDisable
                      : Theme.of(context).backgroundColor,
              leadingWidth: 10,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20)),
              ),
              title: SvgPicture.asset(
                DesignConfig.getImagePath("logo_02.svg"),
                height: MediaQuery.of(context).size.height * .05,
              ),
              actions: [
                GestureDetector(
                  onTap: () {
                    Navigator.of(context)
                        .pushNamed(Routes.search, arguments: false);
                  },
                  child: Padding(
                    padding: EdgeInsets.only(right: size.width * .05),
                    child: Container(
                      width: size.width * .1,
                      height: size.height * .05,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          /*Color(0xff373737)*/
                          color: SettingsLocalDataSource().theme() ==
                                  StringRes.darkThemeKey
                              ? const Color(0xff373737)
                              : Theme.of(context).scaffoldBackgroundColor),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SvgPicture.asset(
                          DesignConfig.getIconPath("search.svg"),
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ),
                ),
                DesignConfig.getPaymentMode == paymentStatusVal
                    ? GestureDetector(
                        onTap: () {
                          if (AuthLocalDataSource.getAuthType() ==
                              guestNameApiKey) {
                            Navigator.of(context).pushNamed(Routes.login);
                          } else {
                            Navigator.of(context)
                                .pushNamed(Routes.buyMembership);
                          }
                        },
                        child: Padding(
                          padding: EdgeInsets.only(right: size.width * .05),
                          child: Container(
                            width: size.width * .1,
                            height: size.height * .05,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: SettingsLocalDataSource().theme() ==
                                        StringRes.darkThemeKey
                                    ? const Color(0xff373737)
                                    : Theme.of(context)
                                        .scaffoldBackgroundColor),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SvgPicture.asset(
                                  DesignConfig.getIconPath("premium_icon.svg")),
                            ),
                          ),
                        ),
                      )
                    : Container(),
              ],
            ),
            body: RefreshIndicator(
                color: Theme.of(context).primaryColor,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                onRefresh: refresh,
                child: homeScreen(MediaQuery.of(context).size)),
          );
  }

  Widget homeScreen(dynamic size) {
    return SizedBox(
      height: size.height,
      width: size.width,
      child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                sliderLoading
                    ? Shimmer.fromColors(
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
                          height: MediaQuery.of(context).size.height * .25,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(borderRadius),
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          margin: const EdgeInsets.all(20),
                        ))
                    : sliderList.isEmpty
                        ? const SizedBox.shrink()
                        : Container(
                            padding: EdgeInsets.zero,
                            margin: EdgeInsets.zero,
                            child: CarouselSlider(
                                items: sliderCard(),
                                options: CarouselOptions(
                                  autoPlay: autoPlaySlider,
                                  reverse: false,
                                  viewportFraction: 1,
                                  autoPlayAnimationDuration:
                                      const Duration(milliseconds: 1000),
                                  aspectRatio: 1.8,
                                  initialPage: 0,
                                  onPageChanged: (index, reason) {},
                                )),
                          ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * .01,
                ),
                (AuthLocalDataSource.getAuthType() != guestNameApiKey &&
                        videoHistory.isNotEmpty)
                    ? Consumer<VideoHistoryProvider>(
                        builder: (_, videoHistoryProvider, __) {
                        videoHistoryList.clear();
                        videoHistoryList
                            .addAll(videoHistoryProvider.getVideoHistoryList);
                        videoHistory = videoHistoryProvider.getThumbnails;
                        return continueWatchingWidget();
                      })
                    : const SizedBox.shrink(),
                commonTitleAndViewAll(
                    name: StringRes.categories,
                    onPress: () {
                      Navigator.of(context).pushNamed(Routes.categoryAll);
                    }),
                SizedBox(
                  height: MediaQuery.of(context).size.height * .006,
                ),
                category(),
                SizedBox(
                  height: MediaQuery.of(context).size.height * .01,
                ),
                topNewText(),
                SizedBox(
                  height: MediaQuery.of(context).size.height * .01,
                ),
                topNew(),
                commonTitleAndViewAll(
                    name: StringRes.freeTitle,
                    onPress: () {
                      Navigator.of(context)
                          .pushNamed(Routes.freeAndPaidVideo, arguments: {
                        "title": StringRes.freeTitle,
                        "freeOrPaidList": freeVideoList,
                        "videoUrlList": videoFree,
                        "cls": freeKey
                      });
                    }),
                SizedBox(
                  height: MediaQuery.of(context).size.height * .01,
                ),
                free(),
                SizedBox(
                  height: MediaQuery.of(context).size.height * .01,
                ),
                DesignConfig.getPaymentMode == paymentStatusVal
                    ? commonTitleAndViewAll(
                        name: StringRes.premium,
                        onPress: () async {
                          await Navigator.of(context)
                              .pushNamed(Routes.freeAndPaidVideo, arguments: {
                            "title": StringRes.premium,
                            "freeOrPaidList": paidVideoList,
                            "videoUrlList": videoPaid,
                            "cls": paidKey
                          });
                        })
                    : Container(),
                SizedBox(
                  height: MediaQuery.of(context).size.height * .01,
                ),
                DesignConfig.getPaymentMode == paymentStatusVal
                    ? premium()
                    : Container(),
                SizedBox(
                  height: size.height * .06,
                ),
              ])),
    );
  }

  continueWatchingWidget() {
    return Column(
      children: [
        commonTitleAndViewAll(
            name: StringRes.continueWatchingLbl,
            onPress: () {
              Navigator.of(context).pushNamed(Routes.historyAll, arguments: {
                "title": StringRes.historyTitleLbl,
                "freeOrPaidList": videoHistoryList,
                "videoUrlList": videoHistory,
                "cls": allKey
              });
            }),
        SizedBox(
          height: MediaQuery.of(context).size.height * .006,
        ),
        videoHistoryWidget(),
        SizedBox(
          height: MediaQuery.of(context).size.height * .01,
        ),
      ],
    );
  }

  List<T?> map<T>(Function handler) {
    List<T?> result = [];
    for (var i = 0; i < sliderList.length; i++) {
      result.add(handler(i));
    }
    return result;
  }

  sliderUrlConverts(int index) async {
    sliderIndexCheck = categoryVideoList
        .indexWhere((element) => element.videoId == sliderList[index].videoId);
    for (int i = 0; i < categoryVideoList.length; i++) {
      if (i == sliderIndexCheck) {
        UrlAndResolutionModel? urls = (await DesignConfig.youtubeCheck(
            videoUrl: categoryVideoList[i].videoId!,
            type: categoryVideoList[i].videoType!));
        commonUrlList.insert(i, urls!);
      } else {
        commonUrlList.insert(i, UrlAndResolutionModel());
      }
      videoCat.add(DesignConfig.getThumbnail(
          videoId: categoryVideoList[i].videoId!,
          type: categoryVideoList[i].videoType!));
    }
  }

// get slider list
  List<Widget>? sliderCard() {
    return map<Widget>((index) {
      return GestureDetector(
        onTap: () async {
          if (sliderList[index].type == categoryKey) {
            for (var element in categoryList) {
              categoryIndexId = categoryList
                  .indexWhere((item) => item.id! == sliderList[index].typeId!);
            }
            await Navigator.of(context)
                .pushNamed(Routes.categoryPlayList, arguments: {
              "totalVideo": categoryList[categoryIndexId].totalVideo.toString(),
              "title": categoryList[categoryIndexId].categoryName,
              "description": categoryList[categoryIndexId].description,
              "categoryId": categoryList[categoryIndexId].id,
              "image": categoryList[categoryIndexId].image
            });
          } else {
            if (sliderList[index].paymentType == 1 &&
                AuthLocalDataSource.getAuthType() == guestNameApiKey) {
              Navigator.of(context).pushNamed(Routes.login);
            } else {
              if (sliderCheck) return;
              sliderVideoIndex = index;
              setState(() {
                sliderCheck = true;
                autoPlaySlider = false;
              });
              commonUrlList.clear();
              videoCat.clear();
              await getVideo(
                  type: categoryKey, categoryId: sliderList[index].categoryId);
              await sliderUrlConverts(index);
              await Future.delayed(const Duration(milliseconds: 5), () {
                Navigator.of(context).pushNamed(Routes.topNewList, arguments: {
                  "image": videoCat[index],
                  "cls": "slider",
                  "currentIndex": sliderIndexCheck,
                  "categoryVideoList": categoryVideoList,
                  "currentVideoId": sliderList[index].videoId,
                  "sliderList": sliderList,
                });
              });
              setState(() {
                sliderCheck = false;
              });
            }
          }
        },
        onDoubleTap: () {},
        child: (sliderVideoIndex == index && sliderCheck)
            ? Container(
                width: MediaQuery.of(context).size.width,
                margin: const EdgeInsets.only(left: 15, right: 15, top: 20),
                child: Center(
                  child: CircularProgressIndicator(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              )
            : Stack(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    margin: const EdgeInsets.only(left: 15, right: 15, top: 20),
                    foregroundDecoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(borderRadius),
                      gradient: const LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.transparent,
                          Colors.black45,
                          Colors.black54
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: [0, 0.8, 0.9, 1],
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(borderRadius),
                      child: CachedNetworkImage(
                        imageUrl: sliderList[index].image ?? "",
                        fit: BoxFit.cover,
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
                              height: MediaQuery.of(context).size.height * .4,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.circular(borderRadius),
                              ),
                            )),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                      ),
                    ),
                  ),
                  Container(
                    alignment: Alignment.bottomLeft,
                    padding: EdgeInsets.zero,
                    //color: Colors.black26,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(borderRadius),
                        gradient: const LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.transparent,
                            Colors.black12,
                            Colors.black54
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: [0, 0.8, 0.9, 1],
                        )),
                    margin: const EdgeInsets.only(
                        //  bottom: MediaQuery.of(context).size.height * .016,
                        left: 15,
                        right: 15),
                    // padding: const EdgeInsets.only(bottom: 8.0),
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: ListTile(
                        horizontalTitleGap: 0,
                        visualDensity:
                            const VisualDensity(horizontal: 0, vertical: -4),
                        leading: Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: sliderList[index].type == videoKey
                                ? SvgPicture.asset(
                                    DesignConfig.getIconPath("play.svg"),
                                    color: Colors.white,
                                  )
                                : const Icon(
                                    Icons.category_outlined,
                                    color: Colors.white,
                                  )),
                        title: Text(
                          sliderList[index].typeTitle ?? "",
                          maxLines: 1,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              height: 1),
                        ),
                        subtitle: Text(
                          sliderList[index].typeDescription ?? "",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              height: 1, fontSize: 12, color: Colors.white70),
                        ),
                      ),
                    ),
                  ),
                  sliderList[index].paymentType == 1
                      ? Positioned(
                          top: 20,
                          left: 15,
                          child: Container(
                            decoration: const BoxDecoration(
                                color: Color(0x80000000),
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(borderRadius),
                                    bottomRight:
                                        Radius.circular(borderRadius))),
                            height: MediaQuery.of(context).size.height * .03,
                            width: MediaQuery.of(context).size.width * .06,
                            padding: const EdgeInsets.all(5.0),
                            child: SvgPicture.asset(
                                DesignConfig.getIconPath("premium_icon.svg")),
                          ))
                      : Container(),
                ],
              ),
      );
    }).cast<Widget>().toList();
  }

  Widget commonTitleAndViewAll(
      {required String name, required VoidCallback onPress}) {
    return Container(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.only(left: 15, right: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name,
              style: TextStyle(
                  color: Theme.of(context).secondaryHeaderColor,
                  fontWeight: FontWeight.w700,
                  fontStyle: FontStyle.normal,
                  fontSize: 16.0),
              textAlign: TextAlign.left),
          InkWell(
            onTap: onPress,
            child: Text(StringRes.viewAll,
                style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.normal,
                    fontSize: 14.0),
                textAlign: TextAlign.right),
          )
        ],
      ),
    );
  }

  ///continue watching / Video History
  Widget videoHistoryWidget() {
    return Container(
        height: MediaQuery.of(context).size.height * .15, //.17,
        padding: const EdgeInsets.only(left: 15, right: 10),
        margin: EdgeInsets.zero,
        child: ListView.builder(
            itemCount:
                (videoHistoryList.length > 5) ? 5 : videoHistoryList.length,
            scrollDirection: Axis.horizontal,
            controller: scrollController,
            itemBuilder: (BuildContext context, int index) {
              CategoryVideoModel item = videoHistoryList[index];
              return GestureDetector(
                  onTap: () async {
                    commonUrlList.clear();
                    for (int i = 0; i < videoHistoryList.length; i++) {
                      if (i == index) {
                        UrlAndResolutionModel? urls =
                            await DesignConfig.youtubeCheck(
                                videoUrl: videoHistoryList[i].videoId!,
                                type: videoHistoryList[i].videoType!);
                        commonUrlList.insert(i, urls!);
                      } else {
                        commonUrlList.insert(i, UrlAndResolutionModel());
                      }
                    }
                    if (mounted) {
                      await Navigator.of(context)
                          .pushNamed(Routes.topNewList, arguments: {
                        "image": videoHistory[index],
                        "cls": "all",
                        "currentIndex": index,
                        "categoryVideoList": videoHistoryList,
                        "currentVideoId": item.videoId.toString(),
                        "historyDuration": item.historyDuration
                      }).then((value) => scrollController.jumpTo(0));
                    }
                  },
                  onDoubleTap: () {},
                  child: Container(
                    width: MediaQuery.of(context).size.width * .40, //.327
                    margin: EdgeInsets.only(
                        right: MediaQuery.of(context).size.width * .027),
                    padding: EdgeInsets.zero,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(borderRadius),
                      color: SettingsLocalDataSource().theme() ==
                              StringRes.darkThemeKey
                          ? darkButtonDisable
                          : backgroundColor,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            ClipRRect(
                                borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(borderRadius),
                                    topRight: Radius.circular(borderRadius)),
                                child: SizedBox(
                                  width: MediaQuery.of(context).size.width,
                                  height:
                                      MediaQuery.of(context).size.height * .09,
                                  child: GeneralMethods.setNetworkImage(
                                      imgUrl:
                                          videoHistoryList[index].image ?? '',
                                      thumbnailImg: (videoHistory.isNotEmpty &&
                                              index < videoHistory.length)
                                          ? videoHistory[index]
                                          : '',
                                      context: context),
                                )),
                            videoHistoryList[index].type == 1
                                ? const CommonPremiumIconWidget()
                                : const SizedBox.shrink(),
                          ],
                        ),
                        Padding(
                            padding: EdgeInsets.only(
                              left: 10,
                              top: MediaQuery.of(context).size.height * .01,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  videoHistoryList[index]
                                          .title![0]
                                          .toUpperCase() +
                                      videoHistoryList[index]
                                          .title!
                                          .substring(1),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      height: 1,
                                      color: Theme.of(context)
                                          .secondaryHeaderColor,
                                      fontWeight: FontWeight.bold,
                                      fontStyle: FontStyle.normal,
                                      fontSize: 14.0),
                                ),
                                Text(
                                  (videoHistoryList[index].description != "" ||
                                          videoHistoryList[index]
                                              .description!
                                              .isNotEmpty)
                                      ? videoHistoryList[index]
                                              .description![0]
                                              .toUpperCase() +
                                          videoHistoryList[index]
                                              .description!
                                              .substring(1)
                                      : "",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      height: 1,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                      fontWeight: FontWeight.normal,
                                      fontSize: 12.0),
                                ),
                                /* Text(
                                    DesignConfig.timeAgo(DateTime.parse(
                                        videoHistoryList[index].date!)),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary
                                            .withOpacity(0.5),
                                        height: 1,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 12.0),
                                    textAlign: TextAlign.left), */
                              ],
                            )),
                      ],
                    ),
                  ));
            }));
  }

// get category vise list
  Widget category() {
    return Container(
        height: MediaQuery.of(context).size.height * .21,
        color: Theme.of(context).scaffoldBackgroundColor,
        padding: const EdgeInsets.only(left: 10, right: 10),
        margin: EdgeInsets.zero,
        child: isLoading
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
                child: ListView.builder(
                    itemCount: 4,
                    padding:
                        const EdgeInsets.only(right: 20, left: 10), //left: 20,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (BuildContext context, int index) {
                      return Container(
                          width: MediaQuery.of(context).size.width * .35,
                          height: MediaQuery.of(context).size.height * .22,
                          padding: EdgeInsets.zero,
                          margin: const EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(borderRadius),
                            color: Theme.of(context).scaffoldBackgroundColor,
                          ));
                    }))
            : categoryList.isEmpty
                ? DesignConfig.noDataFound(context)
                : ListView.builder(
                    itemCount: categoryListProvider.length,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (BuildContext context, int index) {
                      return SlideAnimation(
                          position: index,
                          itemCount: categoryListProvider.length,
                          slideDirection: SlideDirection.fromRight,
                          animationController: _animationController,
                          child: GestureDetector(
                              onTap: () async {
                                await Navigator.of(context).pushNamed(
                                    Routes.categoryPlayList,
                                    arguments: {
                                      "totalVideo": categoryList[index]
                                          .totalVideo
                                          .toString(),
                                      "title": categoryList[index].categoryName,
                                      "description":
                                          categoryList[index].description,
                                      "categoryId": categoryList[index].id,
                                      "image": categoryList[index].image
                                    });
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width * .35,
                                margin: EdgeInsets.only(
                                    right: MediaQuery.of(context).size.width *
                                        .005),
                                padding: EdgeInsets.zero,
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.circular(borderRadius),
                                  color:
                                      Theme.of(context).scaffoldBackgroundColor,
                                ),
                                child: Card(
                                  color: Theme.of(context).colorScheme.primary,
                                  shadowColor: Colors.black12,
                                  elevation: 10,
                                  //margin: EdgeInsets.only(bottom: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(borderRadius),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ClipRRect(
                                        borderRadius: const BorderRadius.only(
                                            topLeft:
                                                Radius.circular(borderRadius),
                                            topRight:
                                                Radius.circular(borderRadius)),
                                        child: CachedNetworkImage(
                                          imageUrl: categoryListProvider[index]
                                                  .image ??
                                              "",
                                          fit: BoxFit.fill,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              .12,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              .35,
                                          errorWidget: (context, url, error) =>
                                              const Icon(Icons.error),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                          left: 10,
                                          top: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              .01,
                                        ),
                                        child: Text(
                                          categoryListProvider[index]
                                                  .categoryName![0]
                                                  .toUpperCase() +
                                              categoryListProvider[index]
                                                  .categoryName!
                                                  .substring(1),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              height: 1,
                                              color: Theme.of(context)
                                                  .secondaryHeaderColor,
                                              fontWeight: FontWeight.bold,
                                              fontStyle: FontStyle.normal,
                                              fontSize: 14.0),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                          left: 10,
                                          top: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              .005,
                                        ),
                                        child: Text(
                                          (categoryListProvider[index]
                                                          .description !=
                                                      null &&
                                                  categoryListProvider[index]
                                                          .description !=
                                                      "")
                                              ? categoryListProvider[index]
                                                      .description![0]
                                                      .toUpperCase() +
                                                  categoryListProvider[index]
                                                      .description!
                                                      .substring(1)
                                              : "",
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              height: 1,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .secondary,
                                              fontWeight: FontWeight.normal,
                                              fontSize: 12.0),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                          left: 10,
                                          top: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              .005,
                                        ),
                                        child: Text(
                                            "${categoryListProvider[index].totalVideo} ${categoryListProvider[index].totalVideo.toString() == "0" || categoryListProvider[index].totalVideo.toString() == "1" ? "Video" : "Videos"}",
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                height: 1,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .secondary
                                                    .withOpacity(0.5),
                                                fontWeight: FontWeight.normal,
                                                fontSize: 12.0)),
                                      ),
                                    ],
                                  ),
                                ),
                              )));
                    }));
  }

  Widget topNewText() {
    return Padding(
      padding: const EdgeInsets.only(
        left: 15,
      ),
      child: Text(StringRes.topNew,
          style: TextStyle(
              color: Theme.of(context).secondaryHeaderColor,
              fontWeight: FontWeight.w700,
              fontStyle: FontStyle.normal,
              fontSize: 16.0),
          textAlign: TextAlign.left),
    );
  }

// get top new list
  Widget topNew() {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.zero,
      margin: const EdgeInsets.only(left: 15, right: 15),
      child: allVideoList.isEmpty
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
              child: ListView.builder(
                  itemCount: 4,
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      height: MediaQuery.of(context).size.height * .31,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(borderRadius),
                        color: SettingsLocalDataSource().theme() ==
                                StringRes.darkThemeKey
                            ? darkButtonDisable
                            : backgroundColor,
                      ),
                    );
                  }))
          : ListView.builder(
              itemCount: /*  allVideoList.length >= 4
                  ? 4
                  : allVideoList.length >= 3
                      ? 3
                      : allVideoList.length >= 2
                          ? 2
                          : 1, */
                  (allVideoList.length < 4) ? allVideoList.length : 4,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemBuilder: (BuildContext context, int index) {
                CategoryVideoModel categoryVideoModel = allVideoList[index];
                return SlideAnimation(
                  position: index,
                  itemCount: allVideoList.length,
                  slideDirection: SlideDirection.fromBottom,
                  animationController: _animationController,
                  child: GestureDetector(
                    onTap: () async {
                      if (categoryVideoModel.type == 1 &&
                          AuthLocalDataSource.getAuthType() ==
                              guestNameApiKey) {
                        Navigator.of(context).pushNamed(Routes.login);
                      } /* else if (categoryVideoModel.type == 1 &&
                          AuthLocalDataSource.getIsSubscribe() == 0) {
                        Navigator.of(context).pushNamed(Routes.buyMembership);
                      }*/
                      else {
                        if (allCheck) return;
                        allVideoIndex = index;
                        setState(() {
                          allCheck = true;
                        });
                        commonUrlList.clear();
                        for (int i = 0; i < allVideoList.length; i++) {
                          if (i == index) {
                            UrlAndResolutionModel? urls =
                                (await DesignConfig.youtubeCheck(
                                    videoUrl: allVideoList[i].videoId!,
                                    type: allVideoList[i].videoType!));
                            commonUrlList.insert(i, urls!);
                          } else {
                            commonUrlList.insert(i, UrlAndResolutionModel());
                          }
                        }
                        await Navigator.of(context)
                            .pushNamed(Routes.topNewList, arguments: {
                          "image": videoAll[index],
                          "cls": "all",
                          "currentIndex": index,
                          "categoryVideoList": allVideoList,
                          "currentVideoId": categoryVideoModel.videoId,
                          'urlList': commonUrlList,
                        });
                        setState(() {
                          allCheck = false;
                        });
                        //  });
                      }
                    },
                    onDoubleTap: () {},
                    child: (allVideoIndex == index && allCheck)
                        ? Container(
                            height: MediaQuery.of(context).size.height * .3,
                            margin: EdgeInsets.only(
                                bottom:
                                    MediaQuery.of(context).size.height * .015),
                            decoration: BoxDecoration(
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 20.0,
                                ),
                              ],
                              borderRadius: BorderRadius.circular(borderRadius),
                              color: SettingsLocalDataSource().theme() ==
                                      StringRes.darkThemeKey
                                  ? darkButtonDisable
                                  : backgroundColor,
                            ),
                            child: Center(
                                child: CircularProgressIndicator(
                              color: Theme.of(context).primaryColor,
                            )),
                          )
                        : Container(
                            height: MediaQuery.of(context).size.height * .31,
                            margin: EdgeInsets.only(
                                bottom:
                                    MediaQuery.of(context).size.height * .015),
                            decoration: BoxDecoration(
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 20.0,
                                ),
                              ],
                              borderRadius: BorderRadius.circular(borderRadius),
                              color: SettingsLocalDataSource().theme() ==
                                      StringRes.darkThemeKey
                                  ? darkButtonDisable
                                  : backgroundColor,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Stack(
                                  children: [
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width,
                                      child: ClipRRect(
                                        borderRadius: const BorderRadius.only(
                                          topLeft:
                                              Radius.circular(borderRadius),
                                          topRight:
                                              Radius.circular(borderRadius),
                                        ),
                                        child: CachedNetworkImage(
                                          imageUrl: (categoryVideoModel.image !=
                                                      null &&
                                                  categoryVideoModel
                                                      .image!.isNotEmpty)
                                              ? categoryVideoModel.image!
                                              : videoAll[index],
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              .23,
                                          imageBuilder:
                                              (context, imageProvider) =>
                                                  Container(
                                            decoration: BoxDecoration(
                                              image: DecorationImage(
                                                image: imageProvider,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                          placeholder: (context, url) =>
                                              Shimmer.fromColors(
                                                  baseColor:
                                                      Provider.of<ThemeNotifier>(
                                                                      context)
                                                                  .getThemeMode() ==
                                                              ThemeMode.dark
                                                          ? Colors.white30
                                                          : Colors.grey[300]!,
                                                  highlightColor:
                                                      Provider.of<ThemeNotifier>(
                                                                      context)
                                                                  .getThemeMode() ==
                                                              ThemeMode.dark
                                                          ? Colors.white30
                                                          : Colors.grey[100]!,
                                                  child: Container(
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            .3,
                                                    decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                borderRadius)),
                                                  )),
                                          errorWidget: (context, url, error) =>
                                              const Icon(Icons.error),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    categoryVideoModel.type == 1
                                        ? const CommonPremiumIconWidget()
                                        : const SizedBox.shrink(),
                                    /*  ? Positioned(
                                            top: 0,
                                            left: 0,
                                            child: Container(
                                              decoration: const BoxDecoration(
                                                  color: Color(0x80000000),
                                                  borderRadius: BorderRadius.only(
                                                      topLeft: Radius.circular(
                                                          borderRadius),
                                                      bottomRight:
                                                          Radius.circular(
                                                              borderRadius))),
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  .03,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  .06,
                                              padding:
                                                  const EdgeInsets.all(5.0),
                                              child: SvgPicture.asset(
                                                  DesignConfig.getIconPath(
                                                      "premium_icon.svg")),
                                            ))
                                        : Container(), */
                                    CommonDurationWidget(
                                        durationValue:
                                            categoryVideoModel.duration),
                                    /* Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: Container(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                .02,
                                            alignment: Alignment.center,
                                            width: categoryVideoModel
                                                        .duration!.length >
                                                    5
                                                ? MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    .13
                                                : MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    .09,
                                            color: Colors.black54,
                                            child: Text(
                                                categoryVideoModel.duration!,
                                                style: const TextStyle(
                                                    color: Color(0xffffffff),
                                                    fontWeight: FontWeight.w400,
                                                    fontStyle: FontStyle.normal,
                                                    fontSize: 10.0),
                                                textAlign: TextAlign.left))), */
                                  ],
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                    left: 10.0,
                                    top: MediaQuery.of(context).size.height *
                                        .01,
                                  ),
                                  child: Text(
                                      categoryVideoModel.title![0]
                                              .toUpperCase() +
                                          categoryVideoModel.title!
                                              .substring(1),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          height: 1,
                                          color: Theme.of(context)
                                              .secondaryHeaderColor,
                                          fontWeight: FontWeight.bold,
                                          fontStyle: FontStyle.normal,
                                          fontSize: 14.0),
                                      textAlign: TextAlign.left),
                                ),
                                Padding(
                                    padding: EdgeInsets.only(
                                      left: 10.0,
                                      top: MediaQuery.of(context).size.height *
                                          .005,
                                    ),
                                    child: Text(
                                        (categoryVideoModel.description !=
                                                "" /*&&
                                                categoryVideoModel
                                                    .description!.isNotEmpty*/
                                            )
                                            ? categoryVideoModel.description![0]
                                                    .toUpperCase() +
                                                categoryVideoModel.description!
                                                    .substring(1)
                                            : "",
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            height: 1,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary,
                                            fontWeight: FontWeight.normal,
                                            fontSize: 12.0),
                                        textAlign: TextAlign.left)),
                                Expanded(
                                  child: Padding(
                                      padding: EdgeInsets.only(
                                        left: 10.0,
                                        top:
                                            MediaQuery.of(context).size.height *
                                                .005,
                                      ),
                                      child: Text(
                                          DesignConfig.timeAgo(DateTime.parse(
                                              categoryVideoModel.date!)),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .secondary
                                                  .withOpacity(0.5),
                                              height: 1,
                                              fontWeight: FontWeight.w400,
                                              fontSize: 12.0),
                                          textAlign: TextAlign.left)),
                                )
                              ],
                            ),
                          ),
                  ),
                );
              }),
    );
  }

// get free video list
  Widget free() {
    return Container(
        height: MediaQuery.of(context).size.height * .17,
        padding: const EdgeInsets.only(left: 15, right: 10),
        margin: EdgeInsets.zero,
        child: freeVideoList.isEmpty
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
                child: ListView.builder(
                    itemCount: 4,
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (BuildContext context, int index) {
                      return Container(
                        height: MediaQuery.of(context).size.height * .15,
                        width: MediaQuery.of(context).size.width * .35,
                        margin: const EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(borderRadius),
                          color: SettingsLocalDataSource().theme() ==
                                  StringRes.darkThemeKey
                              ? darkButtonDisable
                              : backgroundColor,
                        ),
                      );
                    }))
            : ListView.builder(
                itemCount: freeVideoList.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (BuildContext context, int index) {
                  CategoryVideoModel item = freeVideoList[index];
                  return GestureDetector(
                      onTap: () async {
                        if (freeCheck) return;
                        paidVideoIndex = index;
                        freeVideoIndex = index;
                        setState(() {
                          freeCheck = true;
                        });
                        commonUrlList.clear();
                        /*       await DesignConfig.extractVideoUrl1(
                            freeVideoList[index].videoId!);*/
                        for (int i = 0; i < freeVideoList.length; i++) {
                          //await DesignConfig.extractVideoUrl(list[i].videoId!, type);
                          if (i == index) {
                            UrlAndResolutionModel? urls =
                                await DesignConfig.youtubeCheck(
                                    videoUrl: freeVideoList[i].videoId!,
                                    type: freeVideoList[i].videoType!);
                            commonUrlList.insert(i, urls!);
                          } else {
                            commonUrlList.insert(i, UrlAndResolutionModel());
                          }
                        }
                        await Navigator.of(context)
                            .pushNamed(Routes.topNewList, arguments: {
                          "image": videoFree[index],
                          "cls": "free",
                          "currentIndex": index,
                          "categoryVideoList": freeVideoList,
                          "currentVideoId": item.videoId,
                          /*  'urlList244p': freeUrlList240p,
                          'urlList480p': freeUrlList480p,*/
                        });
                        setState(() {
                          freeCheck = false;
                        });
                      },
                      onDoubleTap: () {},
                      child: (freeVideoIndex == index && freeCheck)
                          ? Container(
                              width: MediaQuery.of(context).size.width * .327,
                              margin: EdgeInsets.only(
                                  right:
                                      MediaQuery.of(context).size.width * .027),
                              padding: EdgeInsets.zero,
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(borderRadius),
                                color: SettingsLocalDataSource().theme() ==
                                        StringRes.darkThemeKey
                                    ? darkButtonDisable
                                    : backgroundColor,
                              ),
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            )
                          : Container(
                              width: MediaQuery.of(context).size.width * .327,
                              margin: EdgeInsets.only(
                                  right:
                                      MediaQuery.of(context).size.width * .027),
                              padding: EdgeInsets.zero,
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(borderRadius),
                                color: SettingsLocalDataSource().theme() ==
                                        StringRes.darkThemeKey
                                    ? darkButtonDisable
                                    : backgroundColor,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: const BorderRadius.only(
                                            topLeft:
                                                Radius.circular(borderRadius),
                                            topRight:
                                                Radius.circular(borderRadius)),
                                        child: Image.network(
                                          (freeVideoList[index].image != null &&
                                                  freeVideoList[index]
                                                      .image!
                                                      .isNotEmpty)
                                              ? freeVideoList[index].image!
                                              : videoFree[index],
                                          fit: BoxFit.cover,
                                          width:
                                              MediaQuery.of(context).size.width,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              .09,
                                        ),
                                      ),
                                      CommonDurationWidget(
                                          durationValue:
                                              freeVideoList[index].duration),
                                      /* Positioned(
                                          bottom: 0,
                                          right: 0,
                                          child: Container(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  .02,
                                              alignment: Alignment.center,
                                              width: freeVideoList[index]
                                                          .duration!
                                                          .length >
                                                      5
                                                  ? MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      .12
                                                  : MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      .09,
                                              color: Colors.black54,
                                              child: Text(freeVideoList[index].duration!,
                                                  style: const TextStyle(
                                                      color: Color(0xffffffff),
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontStyle: FontStyle.normal,
                                                      fontSize: 10.0),
                                                  textAlign: TextAlign.left))), */
                                    ],
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                      left: 10,
                                      top: MediaQuery.of(context).size.height *
                                          .01,
                                    ),
                                    child: Text(
                                      freeVideoList[index]
                                              .title![0]
                                              .toUpperCase() +
                                          freeVideoList[index]
                                              .title!
                                              .substring(1),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          height: 1,
                                          color: Theme.of(context)
                                              .secondaryHeaderColor,
                                          fontWeight: FontWeight.bold,
                                          fontStyle: FontStyle.normal,
                                          fontSize: 14.0),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                      left: 10,
                                      top: MediaQuery.of(context).size.height *
                                          .005,
                                    ),
                                    child: Text(
                                      (freeVideoList[index].description != "" ||
                                              freeVideoList[index]
                                                  .description!
                                                  .isNotEmpty)
                                          ? freeVideoList[index]
                                                  .description![0]
                                                  .toUpperCase() +
                                              freeVideoList[index]
                                                  .description!
                                                  .substring(1)
                                          : "",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          height: 1,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                          fontWeight: FontWeight.normal,
                                          fontSize: 12.0),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                      left: 10,
                                      top: MediaQuery.of(context).size.height *
                                          .005,
                                    ),
                                    child: Text(
                                        DesignConfig.timeAgo(DateTime.parse(
                                            freeVideoList[index].date!)),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary
                                                .withOpacity(0.5),
                                            height: 1,
                                            fontWeight: FontWeight.w400,
                                            fontSize: 12.0),
                                        textAlign: TextAlign.left),
                                  )
                                ],
                              ),
                            ));
                }));
  }

// get premium video list
  Widget premium() {
    return Flexible(
      child: paidVideoList.isEmpty
          ? Container()
          : ListView.builder(
              itemCount: /* paidVideoList.length >= 4
                  ? 4
                  : paidVideoList.length >= 3
                      ? 3
                      : paidVideoList.length >= 2
                          ? 2 : 1 */
                  (paidVideoList.length < 4) ? paidVideoList.length : 4,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).size.height * .02,
              ),
              shrinkWrap: true,
              itemBuilder: (BuildContext context, int index) {
                CategoryVideoModel item = paidVideoList[index];
                return GestureDetector(
                    onTap: () async {
                      if (AuthLocalDataSource.getAuthType() ==
                          guestNameApiKey) {
                        Navigator.of(context).pushNamed(Routes.login);
                      } else {
                        if (paidCheck) return;
                        paidVideoIndex = index;
                        setState(() {
                          paidCheck = true;
                        });
                        commonUrlList.clear();
                        UrlAndResolutionModel? urls = UrlAndResolutionModel();
                        for (int i = 0; i < paidVideoList.length; i++) {
                          if (i == index) {
                            urls = await DesignConfig.youtubeCheck(
                                videoUrl: paidVideoList[i].videoId!,
                                type: paidVideoList[i].videoType!);
                            commonUrlList.insert(i, urls!);
                          } else {
                            commonUrlList.insert(
                                i, urls ?? UrlAndResolutionModel());
                          }
                        }
                        await Navigator.of(context)
                            .pushNamed(Routes.topNewList, arguments: {
                          "image": videoPaid[index],
                          "cls": paidKey,
                          "currentIndex": index,
                          "categoryVideoList": paidVideoList,
                          "currentVideoId": item.videoId,
                        });
                        setState(() {
                          paidCheck = false;
                        });
                      }
                    },
                    onDoubleTap: () {},
                    child: (paidVideoIndex == index && paidCheck)
                        ? DesignConfig.onTapLoader(context)
                        : CommonCardForAllWidget(
                            index: index,
                            list: paidVideoList,
                            videoList: videoPaid,
                          ));
              },
            ),
    );
  }
}
