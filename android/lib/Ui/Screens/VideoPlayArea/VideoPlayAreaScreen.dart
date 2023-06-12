import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:better_player/better_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:readmore/readmore.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';
import 'package:videoPlus/Provider/SettingProvider.dart';
import 'package:videoPlus/Utils/generalMethods.dart';

import '../../../App/Routes.dart';
import '../../../LocalDataStore/AuthLocalDataStore.dart';
import '../../../Provider/ThemeProvider.dart';
import '../../../Provider/saveVideoListProvider.dart';
import '../../../Provider/videoHistoryProvider.dart';
import '../../../Utils/Constant.dart';
import '../../../Utils/DesignConfig.dart';
import '../../../Utils/InternetConnectivity.dart';
import '../../../Utils/StringRes.dart';
import '../../../Utils/apiParameters.dart';
import '../../../Utils/apiUtils.dart';
import '../../../model/CategoryVideoModel.dart';
import '../../../model/GetPlayListModel.dart';
import '../../../model/SliderModel.dart';
import '../../../model/urlAndResolutionModel.dart';
import '../../Widget/AdsWidget.dart';
import '../../Widget/commonDurationWidget.dart';
import '../../Widget/commonPremiumIconWidget.dart';
import '../ErrorWidget/NoConErrorWidget.dart';
import 'chrome_cast/chrome_cast_controller.dart';

enum AppState { idle, connected, mediaLoaded, error }

class VideoPlayAreaScreen extends StatefulWidget {
  final String cls, currentVideoId;
  final int currentIndex;
  final List<SliderModel>? sliderList;
  final List<CategoryVideoModel>? categoryVideoList;
  final List<Videos>? saveVideoList;
  String? historyDuration;
  VideoPlayAreaScreen({
    Key? key,
    required this.cls,
    required this.currentIndex,
    this.categoryVideoList,
    required this.currentVideoId,
    this.saveVideoList,
    this.sliderList,
    this.historyDuration,
  }) : super(key: key);
  static Route<dynamic> route(RouteSettings routeSettings) {
    Map arguments = routeSettings.arguments as Map;
    return CupertinoPageRoute(
        builder: (context) => VideoPlayAreaScreen(
              cls: arguments["cls"],
              currentIndex: arguments['currentIndex'],
              categoryVideoList: arguments['categoryVideoList'],
              currentVideoId: arguments["currentVideoId"],
              saveVideoList: arguments["saveVideoList"],
              sliderList: arguments["sliderList"],
              historyDuration: arguments["historyDuration"],
            ));
  }

  @override
  State<StatefulWidget> createState() {
    return VideoPlayAreaScreenState();
  }
}

class VideoPlayAreaScreenState extends State<VideoPlayAreaScreen>
    with TickerProviderStateMixin {
  late Function sheetSetState;
  final GlobalKey<BetterPlayerPlaylistState> _betterPlayerPlaylistStateKey =
      GlobalKey();
  late BetterPlayerConfiguration _betterPlayerConfiguration;
  late BetterPlayerPlaylistConfiguration _betterPlayerPlaylistConfiguration;
  int getVideoIndex = 0, dataIndex = 0, getIsSub = 0;
  Duration myProgress = Duration.zero;
  double volume = 0.0, brightness = 0.0;
  String _connectionStatus = 'unKnown';
  String? shareLink;
  bool showControls = true,
      _playing = false,
      autoPlayEnable = true,
      isLoaded = false,
      shareCheck = false,
      showBrightness = false,
      showVolume = false,
      check = false;
  List<GetPlayListModel> getPlayList = [];
  List<GetPlayListModel> saveVideoList = [];
  final List<BetterPlayerDataSource> _dataSourceList = [];
  final List<BetterPlayerDataSource> _dataSourceList1 = [];
  final List<String> thumbnailList = [];
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> connectivitySubscription;
  late AnimationController animationController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 5));
  BetterPlayerPlaylistController? get _betterPlayerPlaylistController =>
      _betterPlayerPlaylistStateKey
          .currentState?.betterPlayerPlaylistController;
  ChromeCastController? _controller;
  late final AppState _state = AppState.idle;
  late ShortDynamicLink shortenedLink;
  late Orientation currentOrientation;

  late BetterPlayerController bpController;

  Future getCreatedPlayList() async {
    try {
      final body = {
        userIdApiKey: AuthLocalDataSource.getUserId(),
      };
      final response = await post(Uri.parse(getCreatePlayListUrl),
          body: body, headers: await ApiUtils.getHeaders());
      final responseJson = jsonDecode(response.body);
      debugPrint("get create playList...$responseJson");
      if (responseJson['error'] == "true") {
        setState(() {
          DesignConfig.setSnackbar(responseJson['message'], context, false);
        });
      } else {
        if (mounted) {
          setState(() {
            var parsedList = responseJson["data"];
            getPlayList = (parsedList as List)
                .map((data) =>
                    GetPlayListModel.fromJson(data as Map<String, dynamic>))
                .toList();
          });
          context.read<SaveVideoProvider>().setSaveVideoList(getPlayList);
          context
              .read<SaveVideoProvider>()
              .changeVideoLength(getPlayList[dataIndex].videos!.length);
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future storePlayListVideo(
      {required int playListId, required int videoId}) async {
    try {
      final body = {
        playlistIdApiKey: playListId.toString(),
        userIdApiKey: AuthLocalDataSource.getUserId(),
        videoIdApiKey: videoId.toString()
      };
      final response = await post(Uri.parse(storePlayListVideoUrl),
          body: body, headers: await ApiUtils.getHeaders());
      final responseJson = jsonDecode(response.body);
      debugPrint("Store play list Video:$responseJson");
      if (responseJson['error'] == "true") {
        setState(() {
          DesignConfig.setSnackbar(responseJson['message'], context, false);
        });
      } else {
        getCreatedPlayList();
        setState(() {
          DesignConfig.setSnackbar(responseJson['message'], context, false);
        });
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> getShare() async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: deepLinkUrlPrefix,
      link: Uri.parse(
          '$databaseUrl/?index=$getVideoIndex&title=${widget.cls == "save" ? widget.saveVideoList![getVideoIndex].title : widget.categoryVideoList?[getVideoIndex].title}&type=${widget.cls}&subTitle=${widget.cls == "save" ? widget.saveVideoList![getVideoIndex].description : widget.categoryVideoList![getVideoIndex].description}&currentVideoId=${widget.cls == "save" ? widget.saveVideoList![getVideoIndex].videoId : widget.categoryVideoList![getVideoIndex].videoId}&category_id=${widget.cls == "save" ? widget.saveVideoList![getVideoIndex].categoryId : widget.categoryVideoList![getVideoIndex].categoryId}'),
      androidParameters: const AndroidParameters(
        packageName: packageName,
        minimumVersion: 1,
      ),
      iosParameters: const IOSParameters(
        bundleId: packageName,
        minimumVersion: '1',
        appStoreId: iosAppId,
      ),
    );
    shortenedLink = await dynamicLinks.buildShortLink(parameters);
    Future.delayed(Duration.zero, () {
      shareLink = "\n$appName\n$androidLink\nIos\n$iosLink";
    });
    debugPrint(
        "url is ....${'https://$deepLinkName/?index=$getVideoIndex&type=${widget.cls}&currentVideoId=${widget.cls == "save" ? widget.saveVideoList![getVideoIndex].videoId : widget.categoryVideoList![getVideoIndex].videoId}&category_id=${widget.cls == "save" ? widget.saveVideoList![getVideoIndex].categoryId : widget.categoryVideoList![getVideoIndex].categoryId}'}");
  }

  Future<void> callApi() async {
    getCreatedPlayList();
    getShare();
  }

  void playlistPageState() {
    print("duration value -- ${widget.historyDuration}");
    _betterPlayerConfiguration = BetterPlayerConfiguration(
      aspectRatio: 16 / 9,
      handleLifecycle: true,
      fit: BoxFit.fitHeight,
      autoPlay: true,
      deviceOrientationsAfterFullScreen: [DeviceOrientation.portraitUp],
      deviceOrientationsOnFullScreen: [DeviceOrientation.landscapeRight],
      looping: false,
      startAt: (widget.historyDuration != null)
          ? GeneralMethods.parseDuration(
              widget.historyDuration!) //incase of Already played video
          : const Duration(hours: 00), //fresh video play
      eventListener: (betterPlayerEvent) async {
        debugPrint("events:${betterPlayerEvent.betterPlayerEventType.name}");

        Future.delayed(const Duration(milliseconds: 5), () {
          if (betterPlayerEvent.betterPlayerEventType.name ==
                  "setupDataSource" &&
              _betterPlayerPlaylistController?.currentDataSourceIndex !=
                  widget.currentIndex &&
              autoPlayEnable) {
            setState(() {
              getVideoIndex =
                  _betterPlayerPlaylistController!.currentDataSourceIndex;
            });
          }
        });
        if (betterPlayerEvent.betterPlayerEventType.name == "controlsVisible") {
          setState(() {
            showControls = true;
          });
        } else if (betterPlayerEvent.betterPlayerEventType.name ==
            "controlsHiddenStart") {
          setState(() {
            showControls = false;
          });
        }
        if (betterPlayerEvent.betterPlayerEventType ==
            BetterPlayerEventType.progress) {
          setState(() {
            myProgress = betterPlayerEvent.parameters!['progress'];
            //pass it to API later
          });
        }
        if (betterPlayerEvent.betterPlayerEventType ==
            BetterPlayerEventType.finished) {
          // _betterPlayerPlaylistStateKey.currentState
          // _betterPlayerPlaylistConfiguration.nextVideoDelay
          // _betterPlayerPlaylistController
        }
      },
      controlsConfiguration: BetterPlayerControlsConfiguration(
          playerTheme: Platform.isAndroid
              ? BetterPlayerTheme.cupertino
              : BetterPlayerTheme.cupertino,
          enablePlayPause: true,
          controlBarHeight: 35,
          enablePip: true,
          enableAudioTracks: false,
          showControls: true,
          enableQualities: true,
          enableSubtitles: false),
      //  autoDetectFullscreenDeviceOrientation: true,
      //fit: BoxFit.contain,
      // fit: BoxFit.cover,
      // autoPlay: true,
    );

    _betterPlayerPlaylistConfiguration = !autoPlayEnable
        ? const BetterPlayerPlaylistConfiguration()
        : BetterPlayerPlaylistConfiguration(
            loopVideos: true,
            initialStartIndex: getVideoIndex,
            nextVideoDelay: const Duration(seconds: 3),
          );
  }

  Future<List<BetterPlayerDataSource>> setupData(int index) async {
    _dataSourceList[index] = BetterPlayerDataSource(
        BetterPlayerDataSourceType.network, commonUrlList[index].url!,
        resolutions: commonUrlList[index].resolutionData);
    return _dataSourceList;
  }

  initData() async {
    getVideoIndex = widget.currentIndex;
    callApi();
    playlistPageState();
    setupData(getVideoIndex);
    for (int i = 0;
        i <
            (widget.cls == "save"
                ? widget.saveVideoList!.length
                : widget.categoryVideoList!.length);
        i++) {
      if (i != getVideoIndex) {
        dynamic url = await DesignConfig.youtubeCheck(
            videoUrl: widget.cls == "save"
                ? widget.saveVideoList![i].videoId!
                : widget.categoryVideoList![i].videoId!,
            type: widget.cls == "save"
                ? widget.saveVideoList![i].videoType!
                : widget.categoryVideoList![i].videoType!);
        commonUrlList[i] = url;
        setupData(i);
      }
    }
  }

  onDataTap() async {
    print("Play new video from same screen");

    if (check) return;
    setState(() {
      check = true;
    });

    if (!autoPlayEnable) {
      autoPlayOffListUrl.clear();
      _dataSourceList1.clear();
      dynamic url = await DesignConfig.youtubeCheck(
          videoUrl: widget.cls == "save"
              ? widget.saveVideoList![getVideoIndex].videoId!
              : widget.categoryVideoList![getVideoIndex].videoId!,
          type: widget.cls == "save"
              ? widget.saveVideoList![getVideoIndex].videoType!
              : widget.categoryVideoList![getVideoIndex].videoType!);
      autoPlayOffListUrl.add(url);
      _dataSourceList1.add(BetterPlayerDataSource(
          BetterPlayerDataSourceType.network, autoPlayOffListUrl.first.url!,
          resolutions: autoPlayOffListUrl.first.resolutionData));
      Future.delayed(const Duration(milliseconds: 5), () {
        _betterPlayerPlaylistController?.setupDataSourceList(_dataSourceList1);
      });
      getShare();
      setState(() {});
    } else {
      if (commonUrlList[getVideoIndex].url == "") {
        dynamic url = await DesignConfig.youtubeCheck(
            videoUrl: widget.cls == "save"
                ? widget.saveVideoList![getVideoIndex].videoId!
                : widget.categoryVideoList![getVideoIndex].videoId!,
            type: widget.cls == "save"
                ? widget.saveVideoList![getVideoIndex].videoType!
                : widget.categoryVideoList![getVideoIndex].videoType!);
        // topNewUrlList.add(url);
        commonUrlList[getVideoIndex] = url;
      }
      commonUrlList[getVideoIndex].url != "" ? setupData(getVideoIndex) : null;
      Future.delayed(const Duration(milliseconds: 5), () {
        _betterPlayerPlaylistController?.setupDataSource(getVideoIndex);
      });
      getShare();
      setState(() {});
    }
    setState(() {
      check = false;
    });
  }

  //Auto play enable switch on -off then set list
  data() async {
    for (int i = 0;
        i <
            (widget.cls == "save"
                ? widget.saveVideoList!.length
                : widget.categoryVideoList!.length);
        i++) {
      if (i != getVideoIndex) {
        dynamic url = await DesignConfig.youtubeCheck(
            videoUrl: widget.cls == "save"
                ? widget.saveVideoList![i].videoId!
                : widget.categoryVideoList![i].videoId!,
            type: widget.cls == "save"
                ? widget.saveVideoList![i].videoType!
                : widget.categoryVideoList![i].videoType!);
        commonUrlList[i] = url;
        setupData(i);
      }
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
    (DesignConfig.getAdsStatus == "1")
        ? DesignConfig.showInterstitialAd()
        : null;
    for (int i = 0;
        i <
            (widget.cls == "save"
                ? widget.saveVideoList!.length
                : widget.categoryVideoList!.length);
        i++) {
      _dataSourceList.insert(
          i,
          BetterPlayerDataSource(BetterPlayerDataSourceType.network, "",
              resolutions: {}));
    }

    initData();
    super.initState();
  }

  @override
  void dispose() {
    _betterPlayerPlaylistController?.dispose();
    animationController.dispose();
    super.dispose();
  }

  Future setCurrentProgress(
      {required int currId, required BuildContext context}) async {
    String setProgress = myProgress.toString().split('.').first.padLeft(8, "0");
    debugPrint(
        "progress for history !! - $myProgress  - $setProgress -  ${myProgress.toString()} -$currId - ${widget.categoryVideoList![0].id}");
    if (setProgress != "00:00:00" &&
        AuthLocalDataSource.getAuthType() != guestNameApiKey) {
      if (mounted) {
        await context.read<VideoHistoryProvider>().setVideoHistory(
            context: context, currentDuration: setProgress, videoId: currId);
      }
    } else {
      print(
          "please login to set your Video History -- unavailable for guest user");
    }
  }

  @override
  Widget build(BuildContext context) {
    saveVideoList =
        Provider.of<SaveVideoProvider>(context).getSaveVideoPlaylist;
    getIsSub = Provider.of<SettingProvider>(context).getIsSubscribe!;
    final size = MediaQuery.of(context).size;
    return _connectionStatus == 'ConnectivityResult.none'
        ? NoConErrorWidget(
            onTap: () {
              setState(() {
                callApi();
              });
            },
          )
        : WillPopScope(
            onWillPop: () async {
              //save Watched Video History
              setCurrentProgress(
                  currId: widget.cls == "save"
                      ? widget.saveVideoList![getVideoIndex].id!
                      : widget.categoryVideoList![getVideoIndex].id!,
                  context: context);
              return Future.value(true);
            },
            child: GestureDetector(
              //for Screen go Back Gesture along with WillPopScope
              onHorizontalDragUpdate: (details) {
                if (details.delta.dx > 10) {
                  //10 OR 40 OR 50  //sensitivity
                  //save Watched Video History
                  setCurrentProgress(
                      currId: widget.cls == "save"
                          ? widget.saveVideoList![getVideoIndex].id!
                          : widget.categoryVideoList![getVideoIndex].id!,
                      context: context);
                  Navigator.pop(context);
                }
              },
              child: Scaffold(
                appBar: PreferredSize(
                  preferredSize: Size(
                    MediaQuery.of(context).size.width,
                    MediaQuery.of(context).size.height * .3,
                  ),
                  child: SafeArea(child: topImage(size)),
                ),
                body: SingleChildScrollView(
                  child: Wrap(children: [iconsDisplay(size), playList(size)]),
                ),
              ),
            ),
          );
  }

  Widget showBuyNow(dynamic size) {
    return AspectRatio(
        aspectRatio: 16 / 9,
        child: ClipRect(
          child: Stack(children: [
            Image.network(
              widget.cls == "save"
                  ? (widget.saveVideoList![getVideoIndex].image != null &&
                          widget
                              .saveVideoList![getVideoIndex].image!.isNotEmpty)
                      ? widget.saveVideoList![getVideoIndex].image
                      : DesignConfig.getThumbnail(
                          videoId:
                              widget.categoryVideoList![getVideoIndex].videoId!,
                          type: widget
                              .categoryVideoList![getVideoIndex].videoType!)
                  : (widget.categoryVideoList![getVideoIndex].image != null &&
                          widget.categoryVideoList![getVideoIndex].image!
                              .isNotEmpty)
                      ? widget.categoryVideoList![getVideoIndex].image
                      : DesignConfig.getThumbnail(
                          videoId:
                              widget.categoryVideoList![getVideoIndex].videoId!,
                          type: widget
                              .categoryVideoList![getVideoIndex].videoType!)
              // 'https://img.youtube.com/vi/${widget.cls == "save" ? widget.saveVideoList![getVideoIndex].videoId : widget.categoryVideoList![getVideoIndex].videoId}/sddefault.jpg',
              ,
              fit: BoxFit.fill,
              width: size.width,
            ),
            BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Column(
                  children: [
                    SizedBox(
                      height: size.height * .05,
                    ),
                    Container(
                      height: 50,
                      width: 50,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: SvgPicture.asset(
                            DesignConfig.getIconPath("premium_icon.svg")),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 30, right: 30),
                      child: Text(
                        AuthLocalDataSource.getAuthType() == guestNameApiKey
                            ? StringRes.preGuestText
                            : StringRes.premiumText,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 16),
                      ),
                    ),
                    SizedBox(
                      height: size.height * .02,
                    ),
                    OutlinedButton(
                      onPressed: () {
                        if (AuthLocalDataSource.getAuthType() ==
                            guestNameApiKey) {
                          Navigator.of(context).pushNamed(Routes.login);
                        } else {
                          Navigator.of(context)
                              .pushNamed(Routes.buyMembership)
                              .then((_) => setState(() {}));
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        side: BorderSide(
                            width: 2, color: Theme.of(context).primaryColor),
                      ),
                      child: Text(
                        AuthLocalDataSource.getAuthType() == guestNameApiKey
                            ? StringRes.login
                            : StringRes.buyNow,
                        style: TextStyle(color: Theme.of(context).primaryColor),
                      ),
                    ),
                  ],
                )),
          ]),
        ));
  }

  Widget topImage(dynamic size) {
    return (getIsSub == 0 &&
            (widget.cls == "save"
                ? widget.saveVideoList![getVideoIndex].type == 1
                : widget.categoryVideoList![getVideoIndex].type == 1))
        ? showBuyNow(size)
        : AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              children: [
                SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: /*autoPlayEnable
                        ?*/
                        BetterPlayerPlaylist(
                      key: _betterPlayerPlaylistStateKey,
                      betterPlayerConfiguration: _betterPlayerConfiguration,
                      betterPlayerPlaylistConfiguration:
                          _betterPlayerPlaylistConfiguration,
                      betterPlayerDataSourceList:
                          autoPlayEnable ? _dataSourceList : _dataSourceList1,
                    ) /* : BetterPlayer(controller: _betterPlayerController!)*/),
                // brightness and volume slider with opposite side
                Positioned(
                  left: 0,
                  right: MediaQuery.of(context).size.width * .7,
                  bottom: MediaQuery.of(context).size.height * .06,
                  top: MediaQuery.of(context).size.height * .05,
                  child: RotatedBox(
                      quarterTurns: 3,
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          inactiveTrackColor:
                              showVolume ? Colors.grey : Colors.transparent,
                          thumbShape: showVolume
                              ? const RoundSliderThumbShape()
                              : SliderComponentShape.noThumb,
                        ),
                        child: Slider(
                          value: volume,
                          activeColor: showVolume
                              ? Theme.of(context).primaryColor
                              : Colors.transparent,
                          thumbColor: showVolume
                              ? Theme.of(context).primaryColor
                              : Colors.transparent,
                          onChanged: (e) {
                            setState(() {
                              showBrightness = true;
                              volume = e;
                              brightness = e;
                              BVUtils.setBrightness(brightness);
                            });
                          },
                          onChangeEnd: (d) {
                            setState(() {
                              showBrightness = false;
                            });
                          },
                        ),
                      )),
                ),
                Positioned(
                  right: 0,
                  bottom: MediaQuery.of(context).size.height * .06,
                  left: MediaQuery.of(context).size.width * .7,
                  top: MediaQuery.of(context).size.height * .05,
                  child: RotatedBox(
                    quarterTurns: 3,
                    child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          inactiveTrackColor:
                              showBrightness ? Colors.grey : Colors.transparent,
                          thumbShape: showBrightness
                              ? const RoundSliderThumbShape()
                              : SliderComponentShape.noThumb,
                        ),
                        child: Slider(
                          value: brightness,
                          activeColor: showBrightness
                              ? Theme.of(context).primaryColor
                              : Colors.transparent,
                          thumbColor: showBrightness
                              ? Theme.of(context).primaryColor
                              : Colors.transparent,
                          onChanged: (e) {
                            setState(() {
                              showVolume = true;
                              brightness = e;
                              volume = e;
                              BVUtils.setVolume(volume);
                            });
                          },
                          onChangeEnd: (e) {
                            setState(() {
                              showVolume = false;
                            });
                          },
                        )),
                  ),
                ),
                showControls
                    ? Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(
                            top: 5.0,
                            left: 42.0,
                          ),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                InkWell(
                                  onTap: () {
                                    _betterPlayerPlaylistController!
                                        .betterPlayerController!
                                        .enablePictureInPicture(
                                            _betterPlayerPlaylistStateKey);
                                  },
                                  child: Container(
                                    width: 30,
                                    height: 26,
                                    decoration: BoxDecoration(
                                        color: Colors.black87,
                                        borderRadius: BorderRadius.circular(
                                            borderRadius)),
                                    padding: const EdgeInsets.all(5),
                                    child: const Icon(
                                      Icons.picture_in_picture,
                                      color: Colors.white,
                                      size: 12,
                                    ),
                                  ),
                                ),
                                (DesignConfig.getCastMode == "1")
                                    ? InkWell(
                                        onTap: () async {
                                          await _controller
                                              ?.addSessionListener();
                                          await _controller?.loadMedia(
                                              commonUrlList[getVideoIndex]
                                                  .url!);
                                          showDialog(
                                              context: context,
                                              builder: (context) => Container(
                                                  padding: const EdgeInsets.all(
                                                      10.0),
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      .2,
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      .5,
                                                  child: AlertDialog(
                                                    title: Text(StringRes
                                                        .connectToDevice),
                                                    content: _handleState(),
                                                  )));
                                        },
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(left: 2.0),
                                          child: Container(
                                            width: 30,
                                            height: 26,
                                            decoration: BoxDecoration(
                                                color: Colors.black87,
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        borderRadius)),
                                            padding: const EdgeInsets.all(7),
                                            child: const Icon(
                                              Icons.cast,
                                              color: Colors.white,
                                              size: 12,
                                            ),
                                          ),
                                        ))
                                    : const SizedBox.shrink(),
                                StatefulBuilder(
                                    builder: (thisLowerContext, innerSetState) {
                                  return Padding(
                                      padding: const EdgeInsets.only(left: 2.0),
                                      child: Container(
                                          width: 30,
                                          height: 26,
                                          decoration: BoxDecoration(
                                              color: Colors.black87,
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      borderRadius)),
                                          padding: const EdgeInsets.all(7),
                                          child: CustomSwitch(
                                              value: autoPlayEnable,
                                              onChanged: (bool val) {
                                                setState(() {
                                                  innerSetState(() {
                                                    autoPlayEnable = val;
                                                    if (autoPlayEnable) {
                                                      _dataSourceList1.clear();
                                                      _dataSourceList.clear();
                                                      UrlAndResolutionModel?
                                                          urls =
                                                          UrlAndResolutionModel();
                                                      for (int i = 0;
                                                          i <
                                                              (widget.cls ==
                                                                      "save"
                                                                  ? widget
                                                                      .saveVideoList!
                                                                      .length
                                                                  : widget
                                                                      .categoryVideoList!
                                                                      .length);
                                                          i++) {
                                                        _dataSourceList.insert(
                                                            i,
                                                            BetterPlayerDataSource(
                                                                BetterPlayerDataSourceType
                                                                    .network,
                                                                "",
                                                                resolutions: {}));
                                                        commonUrlList.insert(
                                                            i, urls);
                                                      }
                                                      data();
                                                    } else {
                                                      _dataSourceList.clear();
                                                      commonUrlList.clear();
                                                    }
                                                  });
                                                });
                                              })));
                                }),
                              ]),
                        ),
                      )
                    : const SizedBox.shrink(),
              ],
            ));
  }

  Widget iconsDisplay(dynamic size) {
    return Container(
        decoration: BoxDecoration(
            color: Theme.of(context).backgroundColor,
            borderRadius: const BorderRadius.only(
                bottomRight: Radius.circular(25.0),
                bottomLeft: Radius.circular(25.0))),
        padding: const EdgeInsets.only(left: 20, right: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: size.height * .01,
            ),
            Text(
                widget.cls == "save"
                    ? widget.saveVideoList![getVideoIndex].title![0]
                            .toUpperCase() +
                        widget.saveVideoList![getVideoIndex].title!.substring(1)
                    : (widget.categoryVideoList![getVideoIndex].title != "")
                        ? widget.categoryVideoList![getVideoIndex].title![0]
                                .toUpperCase() +
                            widget.categoryVideoList![getVideoIndex].title!
                                .substring(1)
                        : "",
                style: TextStyle(
                    color: Theme.of(context).secondaryHeaderColor,
                    fontWeight: FontWeight.w700,
                    fontStyle: FontStyle.normal,
                    fontSize: 16.0),
                textAlign: TextAlign.left),
            ReadMoreText(
              widget.cls == "save"
                  ? (widget.saveVideoList![getVideoIndex].description!
                              .isNotEmpty &&
                          widget.saveVideoList![getVideoIndex].description !=
                              "")
                      ? widget.saveVideoList![getVideoIndex].description![0]
                              .toUpperCase() +
                          widget.saveVideoList![getVideoIndex].description!
                              .substring(1)
                      : ""
                  : (widget.categoryVideoList![getVideoIndex].description!
                              .isNotEmpty &&
                          widget.categoryVideoList![getVideoIndex]
                                  .description !=
                              "")
                      ? widget.categoryVideoList![getVideoIndex].description![0]
                              .toUpperCase() +
                          widget.categoryVideoList![getVideoIndex].description!
                              .substring(1)
                      : "",
              trimLines: 1,
              colorClickableText: Theme.of(context).primaryColor,
              style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                  fontWeight: FontWeight.normal,
                  fontStyle: FontStyle.normal,
                  fontSize: 14.0),
              trimMode: TrimMode.Line,
              trimCollapsedText: 'Show more',
              trimExpandedText: 'Show less',
              moreStyle: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.normal),
            ),
            SizedBox(
              height: size.height * .01,
            ),
            Row(
              children: [
                widget.cls == "save"
                    ? Container()
                    : InkWell(
                        onTap: () async {
                          if (AuthLocalDataSource.getAuthType() == "guest") {
                            Navigator.of(context).pushNamed(Routes.login);
                            /*   Navigator.of(context).pushNamedAndRemoveUntil(
                                '/login', (Route<dynamic> route) => false);*/
                          } else {
                            await saveToBottomSheet();
                          }
                        },
                        child: SvgPicture.asset(
                          DesignConfig.getIconPath("component_plus.svg"),
                          height: MediaQuery.of(context).size.height * .025,
                          width: MediaQuery.of(context).size.width * .025,
                          color: Theme.of(context).secondaryHeaderColor,
                        ),
                      ),
                SizedBox(
                  width: size.width * .04,
                ),
                GestureDetector(
                    onTap: () async {
                      if (shareCheck) return;
                      setState(() {
                        shareCheck = true;
                      });
                      String documentDirectory;

                      if (Platform.isIOS) {
                        documentDirectory =
                            (await getApplicationDocumentsDirectory()).path;
                      } else {
                        documentDirectory =
                            (await getExternalStorageDirectory())!.path;
                      }

                      final response1 = await get(Uri.parse(widget.cls == "save"
                          ? (widget.saveVideoList![getVideoIndex].image !=
                                      null &&
                                  widget.saveVideoList![getVideoIndex].image!
                                      .isNotEmpty)
                              ? widget.saveVideoList![getVideoIndex].image!
                              : thumbnailList[getVideoIndex]
                          : (widget.categoryVideoList![getVideoIndex].image !=
                                      null &&
                                  widget.categoryVideoList![getVideoIndex]
                                      .image!.isNotEmpty)
                              ? widget.categoryVideoList![getVideoIndex].image!
                              : thumbnailList[getVideoIndex]));
                      final bytes1 = response1.bodyBytes;

                      final File imageFile =
                          File('$documentDirectory/temp.png');
                      imageFile.writeAsBytesSync(bytes1);
                      /*  Share.shareFiles([imageFile.path],
                          text:
                              "${shortenedLink.shortUrl.toString()}\n$shareLink");

                           print("video id is ${widget.currentVideoId}");*/
                      Share.share(
                          "${widget.cls == "save" ? widget.saveVideoList![getVideoIndex].title : widget.categoryVideoList![getVideoIndex].title}\n${shortenedLink.shortUrl.toString()}\n$shareLink");
                      setState(() {
                        shareCheck = false;
                      });
                    },
                    onDoubleTap: () {},
                    child: shareCheck
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Theme.of(context).primaryColor,
                            ),
                          )
                        : SvgPicture.asset(
                            DesignConfig.getIconPath("share.svg"),
                            height: MediaQuery.of(context).size.height * .025,
                            width: MediaQuery.of(context).size.width * .025,
                            color: Theme.of(context).secondaryHeaderColor,
                          )),
              ],
            ),
            SizedBox(
              height: size.height * .01,
            ),
          ],
        ));
  }

  Widget playList(dynamic size) {
    return Container(
      margin: const EdgeInsets.only(left: 15, right: 15),
      child: ListView.separated(
        itemCount: widget.cls == "save"
            ? widget.saveVideoList!.length
            : widget.categoryVideoList!.length,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
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
          dynamic item = widget.cls == "save"
              ? widget.saveVideoList![index]
              : widget.categoryVideoList![index];
          thumbnailList.add(DesignConfig.getThumbnail(
              videoId: item.videoId, type: item.videoType!));
          return InkWell(
            onTap: getVideoIndex != index
                ? () {
                    if (AuthLocalDataSource.getAuthType() == guestNameApiKey &&
                        (widget.cls == "save"
                            ? widget.saveVideoList![index].type == 1
                            : widget.categoryVideoList![index].type == 1)) {
                      Navigator.of(context).pushNamed(Routes.login);
                    } else {
                      setState(() async {
                        //call API to update Current Video - history duration
                        setCurrentProgress(
                            currId: widget.cls == "save"
                                ? widget.saveVideoList![getVideoIndex].id!
                                : widget.categoryVideoList![getVideoIndex].id!,
                            context: context);
                        widget.historyDuration = null; //Reset it for next Video
                        getVideoIndex = index;
                        (getIsSub == 0 &&
                                (widget.cls == "save"
                                    ? widget.saveVideoList![getVideoIndex]
                                            .type ==
                                        1
                                    : widget.categoryVideoList![getVideoIndex]
                                            .type ==
                                        1))
                            ? null
                            : onDataTap();
                      });
                    }
                  }
                : null,
            child: Container(
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
                  child: check && getVideoIndex == index
                      ? Center(
                          child: CircularProgressIndicator(
                            color: Theme.of(context).primaryColor,
                          ),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width *
                                  .33 /*116*/,
                              height: MediaQuery.of(context).size.height * .092,
                              margin: const EdgeInsets.only(left: 8),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  ClipRRect(
                                    borderRadius:
                                        BorderRadius.circular(borderRadius),
                                    child: CachedNetworkImage(
                                      imageUrl: (item.image != null &&
                                              item.image!.isNotEmpty)
                                          ? item.image!
                                          : thumbnailList[index],
                                      fit: BoxFit.fitWidth,
                                      imageBuilder: (context, imageProvider) =>
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
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    .11,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    .33 /*116*/,
                                                margin: EdgeInsets.all(
                                                    MediaQuery.of(context)
                                                            .size
                                                            .height *
                                                        .008),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          borderRadius),
                                                ),
                                              )),
                                      errorWidget: (context, url, error) =>
                                          const Icon(Icons.error),
                                    ),
                                  ),
                                  item.type == 1
                                      ? const CommonPremiumIconWidget()
                                      : const SizedBox.shrink(),
                                  /*  ? Positioned(
                                            top: 0,
                                            left: 0,
                                            child: Container(
                                              decoration: const BoxDecoration(
                                                  color: Color(0x80000000),
                                                  borderRadius:
                                                      BorderRadius.only(
                                                          topLeft: Radius
                                                              .circular(10),
                                                          bottomRight:
                                                              Radius
                                                                  .circular(
                                                                      10))),
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
                                  getIsSub == subscribeStatusVal &&
                                          (widget.cls == "save"
                                              ? widget
                                                      .saveVideoList![
                                                          getVideoIndex]
                                                      .type ==
                                                  1
                                              : widget
                                                      .categoryVideoList![
                                                          getVideoIndex]
                                                      .type ==
                                                  1)
                                      ? Container()
                                      : getVideoIndex ==
                                              index /* &&
                                      (widget.cls != "slider")*/
                                          ? Align(
                                              alignment: Alignment.center,
                                              child: Lottie.asset(
                                                  "assets/animation/animation.json",
                                                  alignment: Alignment.center,
                                                  controller:
                                                      animationController,
                                                  onLoaded:
                                                      (composition) async {
                                                animationController.duration =
                                                    composition.duration;
                                                await animationController
                                                    .repeat();
                                              }),
                                            )
                                          : Container(),
                                  CommonDurationWidget(
                                      durationValue: item.duration,
                                      isBottomRadius: true),
                                ],
                              ),
                            ),
                            categoryDetails(item: item),
                          ],
                        )),
            ),
          );
        },
      ),
    );
  }

  //widgets
  Widget categoryDetails({required item}) {
    return Container(
      width: MediaQuery.of(context).size.width * .50, //53,
      margin: const EdgeInsets.only(right: 5, left: 8),
      alignment: Alignment.topLeft,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * .015,
            ),
            Text(
                item.categoryName ??
                    ""[0].toUpperCase() + item.categoryName!.substring(1),
                maxLines: 1,
                softWrap: true,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    height: 1,
                    fontWeight: FontWeight.bold,
                    fontSize: 12.0),
                textAlign: TextAlign.left),
            SizedBox(
              height: MediaQuery.of(context).size.height * .005,
            ),
            Text(item.title![0].toUpperCase() + item.title!.substring(1),
                maxLines: 1,
                softWrap: true,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: Theme.of(context).secondaryHeaderColor,
                    height: 1,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0),
                textAlign: TextAlign.left),
            SizedBox(
              height: MediaQuery.of(context).size.height * .005,
            ),
            Text(
                (item.description!.isNotEmpty || item.description != "")
                    ? item.description![0].toUpperCase() +
                        item.description!.substring(1)
                    : "",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                    height: 1,
                    fontWeight: FontWeight.w400,
                    fontSize: 12.0),
                textAlign: TextAlign.left),
            SizedBox(
              height: MediaQuery.of(context).size.height * .005,
            ),
            Text(DesignConfig.timeAgo(DateTime.parse(item.date!)),
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
                textAlign: TextAlign.left)
          ],
        ),
      ),
    );
  }

  Future<void> saveToBottomSheet() {
    return showModalBottomSheet(
        elevation: 0,
        isScrollControlled: true,
        backgroundColor: Theme.of(context).backgroundColor,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
          topLeft: Radius.circular(50.0),
          topRight: Radius.circular(50.0),
        )),
        context: context,
        builder: (context) => Padding(
            padding: MediaQuery.of(context).viewInsets,
            child: StatefulBuilder(builder: (BuildContext context,
                StateSetter setStater /*You can rename this! */) {
              sheetSetState = setStater;
              return Container(
                  height: MediaQuery.of(context).size.height * .5,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20.0),
                        topRight: Radius.circular(20.0),
                      )),
                  child: Container(
                      margin: EdgeInsets.only(
                          left: MediaQuery.of(context).size.width * .06,
                          right: MediaQuery.of(context).size.width * .06),
                      child: SingleChildScrollView(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * .035,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // Buy Premium
                                  Text(StringRes.saveTo,
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .secondaryHeaderColor,
                                          fontWeight: FontWeight.w400,
                                          fontStyle: FontStyle.normal,
                                          fontSize: 22.0),
                                      textAlign: TextAlign.left),
                                  InkWell(
                                    onTap: () {
                                      Navigator.pop(context);
                                    },
                                    child: Align(
                                      alignment: Alignment.topRight,
                                      child: Container(
                                        height: 30,
                                        width: 30,
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: const Color(0xffb9b9b9),
                                            )),
                                        child: const Icon(
                                          Icons.close,
                                          color: Color(0xffb9b9b9),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              saveVideoList.isEmpty
                                  ? Center(
                                      child: Text(
                                        StringRes.msgNoData,
                                        style: TextStyle(
                                            color:
                                                Theme.of(context).primaryColor),
                                      ),
                                    )
                                  : ListView.builder(
                                      itemCount: saveVideoList.length,
                                      physics:
                                          const AlwaysScrollableScrollPhysics(),
                                      padding: EdgeInsets.only(
                                        top:
                                            MediaQuery.of(context).size.height *
                                                .01,
                                        bottom:
                                            MediaQuery.of(context).size.height *
                                                .1,
                                      ),
                                      shrinkWrap: true,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        GetPlayListModel item =
                                            saveVideoList[index];
                                        Map<String, Videos> mp = {};
                                        for (var item in item.videos!) {
                                          mp[item.videoId!] = item;
                                        }
                                        List<Videos> videoList =
                                            mp.values.toList();
                                        return InkWell(
                                          onTap: () {
                                            setState(() {
                                              sheetSetState(() {
                                                debugPrint(
                                                    "******${saveVideoList.last.videos!.any((element) => element.videoId == widget.categoryVideoList![getVideoIndex].videoId)}");
                                                if (saveVideoList.last.videos!
                                                    .any((element) =>
                                                        element.videoId ==
                                                            widget
                                                                .categoryVideoList![
                                                                    getVideoIndex]
                                                                .videoId &&
                                                        index ==
                                                            saveVideoList
                                                                    .length -
                                                                1)) {
                                                  Navigator.pop(context);
                                                  DesignConfig.setSnackbar(
                                                      StringRes.msgVideoSave,
                                                      context,
                                                      false);
                                                } else {
                                                  dataIndex = index;
                                                  storePlayListVideo(
                                                      playListId: item.id!,
                                                      videoId: widget
                                                          .categoryVideoList![
                                                              getVideoIndex]
                                                          .id!);
                                                  Navigator.pop(context);
                                                }
                                              });
                                            });
                                          },
                                          child: Card(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            margin: const EdgeInsets.only(
                                                top: 10, bottom: 10),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      borderRadius),
                                            ),
                                            child: Container(
                                              //  height: size.height * .07,
                                              decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        borderRadius),
                                              ),
                                              child: ListTile(
                                                dense: true,
                                                horizontalTitleGap: 10,
                                                contentPadding:
                                                    const EdgeInsets.only(
                                                        left: 8),
                                                leading: Container(
                                                  width: 50,
                                                  height: 50,
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          const BorderRadius
                                                                  .all(
                                                              Radius.circular(
                                                                  borderRadius)),
                                                      color: Theme.of(context)
                                                          .primaryColor
                                                          .withOpacity(0.1)),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            12.0),
                                                    child: SvgPicture.asset(
                                                      DesignConfig.getIconPath(
                                                          "file.svg"),
                                                      color: Theme.of(context)
                                                          .primaryColor,
                                                    ),
                                                  ),
                                                ),
                                                title: Text(item.name!,
                                                    style: TextStyle(
                                                        color: Theme.of(context)
                                                            .secondaryHeaderColor,
                                                        height: 1,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        fontStyle:
                                                            FontStyle.normal,
                                                        fontSize: 14.0),
                                                    textAlign: TextAlign.left),
                                                subtitle: Text(
                                                    videoList.length
                                                            .toString() +
                                                        ((videoList.length
                                                                        .toString() ==
                                                                    "0" ||
                                                                videoList.length
                                                                        .toString() ==
                                                                    "1")
                                                            ? " Video"
                                                            : " Videos"),
                                                    style: TextStyle(
                                                        height: 1,
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .secondary,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontStyle:
                                                            FontStyle.normal,
                                                        fontSize: 14.0),
                                                    textAlign: TextAlign.left),
                                              ),
                                            ),
                                          ),
                                        );
                                      })
                            ]),
                      )));
            })));
  }

// for chormecast
  Widget _handleState() {
    switch (_state) {
      case AppState.idle:
        return const Text('ChromeCast not connected');
      case AppState.connected:
        return const Text('No media loaded');
      case AppState.mediaLoaded:
        return _mediaControls();
      case AppState.error:
        return const Text('An error has occurred');
      default:
        return Container();
    }
  }

// for chormecast
  Widget _mediaControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        RoundIconButton(
          icon: Icons.replay_10,
          onPressed: () => _controller!.seek(relative: true, interval: -10.0),
        ),
        RoundIconButton(
            icon: _playing ? Icons.pause : Icons.play_arrow,
            onPressed: _playPause),
        RoundIconButton(
          icon: Icons.forward_10,
          onPressed: () => _controller!.seek(relative: true, interval: 10.0),
        )
      ],
    );
  }

// for chormecast
  Future<void> _playPause() async {
    final playing = await _controller!.isPlaying();
    if (playing!) {
      await _controller!.pause();
    } else {
      await _controller!.play();
    }
    setState(() => _playing = !playing);
  }
}

class BVUtils {
  static const MethodChannel _channel = MethodChannel('brightness_volume');

  static Future<double> get brightness async =>
      (await _channel.invokeMethod('brightness')) as double;

  static Future setBrightness(double brightness) =>
      _channel.invokeMethod('setBrightness', {"brightness": brightness});

  static Future resetCustomBrightness() =>
      _channel.invokeMethod('resetCustomBrightness');

  static Future<bool> get isKeptOn async =>
      (await _channel.invokeMethod('isKeptOn')) as bool;

  static Future keepOn(bool on) => _channel.invokeMethod('keepOn', {"on": on});

  static Future<double> get volume async =>
      (await _channel.invokeMethod('volume')) as double;

  static Future setVolume(double volume) =>
      _channel.invokeMethod('setVolume', {"volume": volume});

  static Future<double> get freeDiskSpace async =>
      (await _channel.invokeMethod('freeDiskSpace')) as double;

  static Future<double> get totalDiskSpace async =>
      (await _channel.invokeMethod('totalDiskSpace')) as double;
}

class RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const RoundIconButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(18.0),
        child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, shape: const CircleBorder()),
            child: Icon(
              icon,
              color: Colors.white,
            )));
  }
}

class CustomSwitch extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const CustomSwitch({Key? key, required this.value, required this.onChanged})
      : super(key: key);

  @override
  CustomSwitchState createState() => CustomSwitchState();
}

class CustomSwitchState extends State<CustomSwitch>
    with SingleTickerProviderStateMixin {
  Animation? _circleAnimation;
  AnimationController? _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 60));
    _circleAnimation = AlignmentTween(
            begin: widget.value ? Alignment.centerRight : Alignment.centerLeft,
            end: widget.value ? Alignment.centerLeft : Alignment.centerRight)
        .animate(CurvedAnimation(
            parent: _animationController!, curve: Curves.linear));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController!,
      builder: (context, child) {
        return GestureDetector(
          onTap: () {
            if (_animationController!.isCompleted) {
              _animationController!.reverse();
            } else {
              _animationController!.forward();
            }
            widget.value == false
                ? widget.onChanged(true)
                : widget.onChanged(false);
          },
          child: Container(
            width: 20.0,
            height: 10.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24.0),
              color: _circleAnimation!.value == Alignment.centerLeft
                  ? Colors.grey
                  : Theme.of(context).primaryColor,
            ),
            child: Container(
              alignment:
                  widget.value ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 10.0,
                height: 10.0,
                decoration: const BoxDecoration(
                    shape: BoxShape.circle, color: Colors.white),
              ),
            ),
          ),
        );
      },
    );
  }
}
