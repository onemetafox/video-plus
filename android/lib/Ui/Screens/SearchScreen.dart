import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:app_settings/app_settings.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:videoPlus/Ui/Screens/ErrorWidget/ErrorWidgetNoData.dart';
import 'package:videoPlus/Ui/Widget/commonDurationWidget.dart';

import '../../App/Routes.dart';
import '../../LocalDataStore/AuthLocalDataStore.dart';
import '../../Provider/ThemeProvider.dart';
import '../../Utils/Constant.dart';
import '../../Utils/DesignConfig.dart';
import '../../Utils/InternetConnectivity.dart';
import '../../Utils/SlideAnimation.dart';
import '../../Utils/StringRes.dart';
import '../../Utils/apiParameters.dart';
import '../../Utils/apiUtils.dart';
import '../../model/CategoryVideoModel.dart';
import '../../model/urlAndResolutionModel.dart';
import '../Widget/commonPremiumIconWidget.dart';
import '../Widget/shimmerWidget.dart';
import 'ErrorWidget/NoConErrorWidget.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return SearchScreenState();
  }
}

class SearchScreenState extends State<SearchScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  AnimationController? _animationController;
  bool isLoadingMore = true,
      checkDataAvailable = false,
      _hasSpeech = false,
      isLoading = true,
      freeLoading = true,
      paidLoading = true,
      check = false;
  List<CategoryVideoModel> demoList = [];
  List<CategoryVideoModel> tempList = [];
  final List<String> thumbnailList = [];
  int selectedIndex = 0, currentIndex = 0, offset = 0, total = 0, perPage = 10;
  List<String> typeList = ['All', /*'New', */ 'Free', 'Premium'];
  ScrollController controller = ScrollController();
  String source = "", query = "";
  final TextEditingController _textController = TextEditingController();
  late StateSetter setStater;
  String lastWords = '',
      _currentLocaleId = '',
      lastStatus = '',
      _connectionStatus = 'unKnown',
      apiType =
          DesignConfig.getPaymentMode == paymentStatusVal ? allKey : freeKey;
  final SpeechToText speech = SpeechToText();
  double level = 0.0, minSoundLevel = 50000, maxSoundLevel = -50000;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> connectivitySubscription;

  void resultListener(SpeechRecognitionResult result) {
    setStater(() {
      lastWords = result.recognizedWords;
      query = lastWords.replaceAll(' ', '');
    });

    if (result.finalResult) {
      Future.delayed(const Duration(seconds: 1)).then((_) async {
        setState(() {
          _textController.text = lastWords;
          query = lastWords;
          _textController.selection = TextSelection.fromPosition(
              TextPosition(offset: _textController.text.length));
        });
        getVideo(search: query, Type: apiType);
        Navigator.of(context).pop();
      });
    }
  }

  void startListening() {
    lastWords = '';
    speech.listen(
        onResult: resultListener,
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 5),
        partialResults: true,
        localeId: _currentLocaleId,
        onSoundLevelChange: soundLevelListener,
        cancelOnError: true,
        listenMode: ListenMode.confirmation);
  }

  void soundLevelListener(double level) {
    minSoundLevel = min(minSoundLevel, level);
    maxSoundLevel = max(maxSoundLevel, level);

    setStater(() {
      this.level = level;
    });
  }

  Future<void> initSpeechState() async {
    var hasSpeech = await speech.initialize(
        onError: (val) => debugPrint("onError.................:$val"),
        onStatus: (val) => debugPrint('onState...................: $val'),
        debugLogging: false,
        finalTimeout: const Duration(milliseconds: 0));

    if (hasSpeech) {
      var systemLocale = await speech.systemLocale();
      _currentLocaleId = systemLocale?.localeId ?? '';
      debugPrint("_currentLocaleId$_currentLocaleId");
    } else {
      AppSettings.openAppSettings();
    }
    if (!mounted) return;
    setState(() {
      _hasSpeech = hasSpeech;
    });
    if (hasSpeech) showSpeechDialog();
  }

  showSpeechDialog() {
    return showDialog(
        context: context,
        builder: (context) => StatefulBuilder(
                builder: (BuildContext context, StateSetter setStater1) {
              setStater = setStater1;
              return AlertDialog(
                backgroundColor: Theme.of(context).backgroundColor,
                title: Text(
                  StringRes.searchdeText,
                  style: Theme.of(context).textTheme.subtitle1!.copyWith(
                      color: Theme.of(context).colorScheme.onBackground),
                  textAlign: TextAlign.center,
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(50)),
                      ),
                      child: IconButton(
                          icon: Icon(
                            Icons.mic,
                            color: Theme.of(context).primaryColor,
                          ),
                          onPressed: () {
                            if (!_hasSpeech) {
                              initSpeechState();
                            } else {
                              !_hasSpeech || speech.isListening
                                  ? null
                                  : startListening();
                            }
                          }),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        lastWords,
                        style: TextStyle(
                            color: Theme.of(context).secondaryHeaderColor),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      color: Theme.of(context).colorScheme.background,
                      child: Center(
                        child: speech.isListening
                            ? Text(
                                StringRes.imListening,
                                style: Theme.of(context)
                                    .textTheme
                                    .subtitle2!
                                    .copyWith(
                                        color: Theme.of(context)
                                            .secondaryHeaderColor,
                                        fontWeight: FontWeight.bold),
                              )
                            : Text(
                                StringRes.notListening,
                                style: Theme.of(context)
                                    .textTheme
                                    .subtitle2!
                                    .copyWith(
                                        color: Theme.of(context)
                                            .secondaryHeaderColor,
                                        fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
                  ],
                ),
              );
            }));
  }

  void errorListener(SpeechRecognitionError error) {
    debugPrint("error:${error.errorMsg}");
    if (mounted) {
      setState(() {
        // lastError = '${error.errorMsg} - ${error.permanent}';
        DesignConfig.setSnackbar(error.errorMsg, context, false);
      });
    }
  }

  void statusListener(String status) {
    setState(() {
      lastStatus = status;
    });
  }

// when search text type highlight text
  List<TextSpan> highlightOccurrences(source, query) {
    if (query == null || query.isEmpty) {
      return [TextSpan(text: source)];
    }

    var matches = <Match>[];
    for (final token in query.trim().toLowerCase().split(' ')) {
      matches.addAll(token.allMatches(source.toLowerCase()));
    }

    if (matches.isEmpty) {
      return [TextSpan(text: source)];
    }
    matches.sort((a, b) => a.start.compareTo(b.start));

    int lastMatchEnd = 0;
    final List<TextSpan> children = [];
    for (final match in matches) {
      if (match.end <= lastMatchEnd) {
      } else if (match.start <= lastMatchEnd) {
        children.add(TextSpan(
          text: source.substring(lastMatchEnd, match.end),
          style: TextStyle(
              backgroundColor: Theme.of(context).primaryColor,
              color: Colors.white),
        ));
      } else if (match.start > lastMatchEnd) {
        children.add(TextSpan(
          text: source.substring(lastMatchEnd, match.start),
        ));

        children.add(TextSpan(
          text: source.substring(match.start, match.end),
          style: TextStyle(
              backgroundColor: Theme.of(context).primaryColor,
              color: Colors.white),
        ));
      }

      if (lastMatchEnd < match.end) {
        lastMatchEnd = match.end;
      }
    }
    if (lastMatchEnd < source.length) {
      children.add(TextSpan(
        text: source.substring(lastMatchEnd, source.length),
      ));
    }
    return children;
  }

  Future<void> callApi(String search) async {
    await getVideo(Type: apiType, search: search);
  }

  Future getVideo(
      {int? categoryId, String? Type, required String search}) async {
    String catId = Type == categoryKey ? categoryId.toString() : "";
    try {
      final body = {
        typeApiKey: Type,
        catIdApiKey: catId,
        limitApiKey: perPage.toString(),
        offsetApiKey: offset.toString(),
        searchApiKey: search.toString(),
      };
      final response = await post(Uri.parse(getVideoUrl),
          body: body, headers: await ApiUtils.getHeaders());
      final responseJson = jsonDecode(response.body);
      print("==get all type videos  ========$responseJson");
      total = responseJson["total"];
      if (responseJson['error'] == "true") {
        setState(() {
          DesignConfig.setSnackbar(responseJson['message'], context, false);
        });
      } else {
        if (mounted) {
          setState(() {
            var parsedList = responseJson["data"];
            if (Type == freeKey) {
              if ((offset) < total) {
                tempList.clear();
                thumbnailList.clear();
                tempList = (parsedList as List)
                    .map((data) => CategoryVideoModel.fromJson(
                        data as Map<String, dynamic>))
                    .toList();
                demoList.addAll(tempList);
                for (int i = 0; i < demoList.length; i++) {
                  thumbnailList.add(DesignConfig.getThumbnail(
                      videoId: demoList[i].videoId!,
                      type: demoList[i].videoType!));
                }
                offset += offset + perPage;
                setState(() {
                  freeLoading = false;
                });
              }
            } else if (Type == allKey) {
              if ((offset) < total) {
                tempList.clear();
                thumbnailList.clear();
                tempList = (parsedList as List)
                    .map((data) => CategoryVideoModel.fromJson(
                        data as Map<String, dynamic>))
                    .toList();
                demoList.addAll(tempList);
                for (int i = 0; i < demoList.length; i++) {
                  thumbnailList.add(DesignConfig.getThumbnail(
                      videoId: demoList[i].videoId!,
                      type: demoList[i].videoType!));
                }
                offset = offset + perPage;
                setState(() {
                  isLoading = false;
                });
              }
            } else if (Type == paidKey) {
              if ((offset) < total) {
                tempList.clear();
                thumbnailList.clear();
                tempList = (parsedList as List)
                    .map((data) => CategoryVideoModel.fromJson(
                        data as Map<String, dynamic>))
                    .toList();
                demoList.addAll(tempList);
                for (int i = 0; i < demoList.length; i++) {
                  thumbnailList.add(DesignConfig.getThumbnail(
                      videoId: demoList[i].videoId!,
                      type: demoList[i].videoType!));
                }
                offset = offset + perPage;
                setState(() {
                  paidLoading = false;
                });
              }
            }
          });
        }
      }
    } catch (e) {
      print(e.toString());
    }
  }

  _scrollListener() {
    if (controller.offset >= controller.position.maxScrollExtent &&
        !controller.position.outOfRange) {
      if (mounted) {
        setState(() {
          isLoadingMore = true;
          if ((offset) < total) {
            getVideo(search: query, Type: apiType);
          }
        });
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
    callApi(query);
    Future.delayed(Duration.zero, () {
      _textController.addListener(() {
        setState(() {
          String sText = _textController.text;
          if (query != sText) {
            offset = 0;
            demoList.clear();
            query = sText;
            getVideo(Type: apiType, search: query);
          }
        });
      });
    });
    controller.addListener(_scrollListener);
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));

    super.initState();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return _connectionStatus == 'ConnectivityResult.none'
        ? NoConErrorWidget(
            onTap: () {
              setState(() {
                callApi(query);
              });
            },
          )
        : Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: Column(
              children: [
                SizedBox(
                  height: size.height * .027,
                ),
                Container(
                  margin: EdgeInsets.only(
                      left: size.width * .01, right: size.width * .02),
                  child: AppBar(
                    elevation: 0,
                    leadingWidth: size.width * .15,
                    titleSpacing: 10,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20)),
                    ),
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    leading: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DesignConfig.backButton(onPress: () {
                          Navigator.pop(context);
                        })),
                    title: search(size),
                  ),
                ),
                (DesignConfig.getPaymentMode == paymentStatusVal)
                    ? SizedBox(
                        height: size.height * .028,
                      )
                    : Container(),
                (DesignConfig.getPaymentMode == paymentStatusVal)
                    ? topBarWidget(size)
                    : Container(),
                list()
              ],
            ),
          );
  }

  Widget search(dynamic size) {
    return TextField(
      controller: _textController,
      autofocus: false,
      cursorColor: const Color(0xffa2a2a2),
      style: TextStyle(color: Theme.of(context).secondaryHeaderColor),
      decoration: InputDecoration(
        fillColor: Theme.of(context).colorScheme.primary,
        filled: true,
        suffixIcon: InkWell(
            onTap: () {
              if (!_hasSpeech) {
                initSpeechState();
              } else {
                if (!_hasSpeech) {
                  initSpeechState();
                } else {
                  !_hasSpeech || speech.isListening ? null : startListening();
                }
                showSpeechDialog();
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: SvgPicture.asset(
                  DesignConfig.getIconPath("microphone.svg"),
                  color: Theme.of(context).secondaryHeaderColor),
            )),
        prefixIcon: Icon(
          Icons.search,
          color: Theme.of(context).hintColor,
        ),
        contentPadding: EdgeInsets.zero,
        hintText: StringRes.hintSearch,
        hintStyle: TextStyle(
            color: Theme.of(context).hintColor,
            fontWeight: FontWeight.w400,
            fontStyle: FontStyle.normal,
            fontSize: 16.0),
        focusedBorder: OutlineInputBorder(
          borderSide:
              BorderSide(color: Theme.of(context).backgroundColor, width: 1.0),
          borderRadius: BorderRadius.circular(100),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide:
              BorderSide(color: Theme.of(context).backgroundColor, width: 1.0),
          borderRadius: BorderRadius.circular(100),
        ),
        disabledBorder: OutlineInputBorder(
          borderSide:
              BorderSide(color: Theme.of(context).backgroundColor, width: 1.0),
          borderRadius: BorderRadius.circular(100),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(100.0),
        ),
      ),
    );
  }

  Widget topBarWidget(dynamic size) {
    return Container(
      margin: EdgeInsets.only(left: size.width * .04),
      height: MediaQuery.of(context).size.height * .043,
      width: MediaQuery.of(context).size.width,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: typeList.length,
        shrinkWrap: true,
        itemBuilder: (_, index) => Container(
          padding: const EdgeInsets.only(right: 15),
          margin:
              EdgeInsets.only(right: MediaQuery.of(context).size.width * .135),
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              elevation: 0,
              alignment: Alignment.center,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(11.0),
              ),
              side: BorderSide(
                  color: selectedIndex == index
                      ? Theme.of(context).primaryColor
                      : Colors.transparent,
                  width: 1),
            ),
            onPressed: () {
              setState(() {
                selectedIndex = index;
                _animationController!.forward(from: 0.0);
                query = "";
                _textController.clear();
                if (selectedIndex == 0) {
                  demoList.clear();
                  offset = 0;
                  apiType = allKey;
                  _animationController!.forward(from: 0.0);
                  getVideo(Type: apiType, search: query);
                } else if (selectedIndex == 1) {
                  print("free........................");
                  demoList.clear();
                  offset = 0;
                  apiType = freeKey;
                  _animationController!.forward(from: 0.0);
                  getVideo(Type: apiType, search: query);
                } else {
                  demoList.clear();
                  offset = 0;
                  apiType = paidKey;
                  _animationController!.forward(from: 0.0);
                  getVideo(Type: apiType, search: query);
                }
              });
            },
            child: Text(typeList[index],
                style: TextStyle(
                    color: selectedIndex == index
                        ? Theme.of(context).secondaryHeaderColor
                        : Theme.of(context).hintColor,
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.normal,
                    fontSize: 14.0),
                textAlign: TextAlign.left),
          ),
        ),
      ),
    );
  }

  Widget list() {
    bool condition =
        (((selectedIndex == 0 || selectedIndex == 1) && isLoading) ||
            (selectedIndex == 2 && freeLoading) ||
            (selectedIndex == 3 && paidLoading) ||
            demoList.isEmpty);
    return Expanded(
        child: (DesignConfig.getPaymentMode == paymentStatusVal
                ? condition
                : freeLoading)
            ? ShimmerWidget(
                height: MediaQuery.of(context).size.height * .11,
                length: 10,
              )
            : checkDataAvailable
                ? const ErrorWidgetNoData()
                : ListView.builder(
                    itemCount: /* (offset < total)
                        ? demoList.length + 1
                        :*/
                        demoList.length,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * .01,
                      bottom: MediaQuery.of(context).size.height * .1,
                    ),
                    controller: controller,
                    shrinkWrap: true,
                    itemBuilder: (BuildContext context, int index) {
                      return SlideAnimation(
                          position: index,
                          itemCount: demoList.length,
                          slideDirection: SlideDirection.fromTop,
                          animationController: _animationController,
                          child: listData(demoList, index, thumbnailList));
                    },
                  ));
  }

  Widget listData(
      List<CategoryVideoModel> item, int index, List<String> videoUrlList) {
    return (index == (item.length - 1) && isLoadingMore && item.isEmpty)
        ? Center(
            child: CircularProgressIndicator(
            color: Theme.of(context).primaryColor,
          ))
        : GestureDetector(
            onTap: () async {
              if (AuthLocalDataSource.getAuthType() == guestNameApiKey &&
                  item[index].type == 1) {
                Navigator.of(context).pushNamed(Routes.login);
              } else {
                if (check) return;
                currentIndex = index;
                setState(() {
                  check = true;
                });
                commonUrlList.clear();
                for (int i = 0; i < item.length; i++) {
                  if (i == index) {
                    UrlAndResolutionModel? urls =
                        await DesignConfig.youtubeCheck(
                            videoUrl: item[i].videoId!,
                            type: item[i].videoType!);
                    commonUrlList.insert(i, urls!);
                  } else {
                    commonUrlList.insert(i, UrlAndResolutionModel());
                  }
                }
                await Navigator.of(context)
                    .pushNamed(Routes.topNewList, arguments: {
                  "image": videoUrlList[index],
                  "cls": "search",
                  "currentIndex": index,
                  "categoryVideoList": item,
                  "currentVideoId": item[index].videoId,
                });
                setState(() {
                  check = false;
                });
              }
            },
            onDoubleTap: () {},
            child: (currentIndex == index && check)
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
                              width:
                                  MediaQuery.of(context).size.width * .31, //33
                              height: MediaQuery.of(context).size.height * .093,
                              margin: const EdgeInsets.only(left: 8),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  ClipRRect(
                                    borderRadius:
                                        BorderRadius.circular(borderRadius),
                                    child: CachedNetworkImage(
                                      imageUrl: (item[index].image != null &&
                                              item[index].image!.isNotEmpty)
                                          ? item[index].image!
                                          : videoUrlList[index],
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
                                                    .33,
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
                                  item[index].type == 1
                                      ? const CommonPremiumIconWidget()
                                      : const SizedBox.shrink(),
                                  /* ? Positioned(
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
                                            padding: const EdgeInsets.all(5.0),
                                            child: SvgPicture.asset(
                                                DesignConfig.getIconPath(
                                                    "premium_icon.svg")),
                                          ))
                                      : Container(),
                                       */
                                  CommonDurationWidget(
                                      durationValue: item[index].duration,
                                      isBottomRadius: true),
                                  /*  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                .02,
                                        alignment: Alignment.center,
                                        width: item[index].duration!.length > 5
                                            ? MediaQuery.of(context).size.width *
                                                .12
                                            : MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                .09,
                                        decoration: const BoxDecoration(
                                            color: Colors.black54,
                                            borderRadius: BorderRadius.only(
                                                bottomRight: Radius.circular(
                                                    borderRadius))),
                                        child: Text(item[index].duration!,
                                            style: const TextStyle(
                                                color: Color(0xffffffff),
                                                fontWeight: FontWeight.w400,
                                                fontStyle: FontStyle.normal,
                                                fontSize: 10.0),
                                            textAlign: TextAlign.left)), 
                                  )*/
                                ],
                              ),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width * .53,
                              margin: const EdgeInsets.only(left: 8, right: 8),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      item[index]
                                              .categoryName![0]
                                              .toUpperCase() +
                                          item[index]
                                              .categoryName!
                                              .substring(1),
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
                                    height: MediaQuery.of(context).size.height *
                                        .005,
                                  ),
                                  RichText(
                                      maxLines: 1,
                                      softWrap: true,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.left,
                                      text: TextSpan(
                                        children: highlightOccurrences(
                                            item[index]
                                                    .title![0]
                                                    .toUpperCase() +
                                                item[index].title!.substring(1),
                                            query),
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .secondaryHeaderColor,
                                            height: 1,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14.0),
                                      )),
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        .005,
                                  ),
                                  (item[index].description!.isNotEmpty &&
                                          item[index].description != "")
                                      ? Text(
                                          item[index]
                                                  .description![0]
                                                  .toUpperCase() +
                                              item[index]
                                                  .description!
                                                  .substring(1),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .secondary,
                                              height: 1,
                                              fontWeight: FontWeight.w400,
                                              fontSize: 12.0),
                                          textAlign: TextAlign.left)
                                      : Container(),
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        .005,
                                  ),
                                  Text(
                                      DesignConfig.timeAgo(
                                          DateTime.parse(item[index].date!)),
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
                            )
                          ],
                        ))));
  }
}
