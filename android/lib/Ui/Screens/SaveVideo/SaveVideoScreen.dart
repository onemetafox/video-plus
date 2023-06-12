import 'dart:async';
import 'dart:convert';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:videoPlus/LocalDataStore/AuthLocalDataStore.dart';
import 'package:videoPlus/Ui/Widget/shimmerNotificationWidget.dart';
import 'package:videoPlus/Utils/Constant.dart';

import '../../../App/Routes.dart';
import '../../../LocalDataStore/SettingLocalDataSource.dart';
import '../../../Provider/saveVideoListProvider.dart';
import '../../../Utils/ColorRes.dart';
import '../../../Utils/DesignConfig.dart';
import '../../../Utils/InternetConnectivity.dart';
import '../../../Utils/SlideAnimation.dart';
import '../../../Utils/StringRes.dart';
import '../../../Utils/apiParameters.dart';
import '../../../Utils/apiUtils.dart';
import '../../../model/GetPlayListModel.dart';
import '../ErrorWidget/NoConErrorWidget.dart';
import '../ErrorWidget/NoVideoErrorWidget.dart';

class SaveVideoScreen extends StatefulWidget {
  const SaveVideoScreen({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return SaveVideoScreenState();
  }
}

class SaveVideoScreenState extends State<SaveVideoScreen>
    with TickerProviderStateMixin {
  TextEditingController controllerNewPlayList = TextEditingController();
  late Function sheetSetState;
  String _connectionStatus = 'unKnown';
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> connectivitySubscription;
  List<GetPlayListModel> getPlayList = [];
  AnimationController? _animationController;
  int dataIndex = 0;
  bool isLoading = true;
  List<GetPlayListModel> saveVideoList = [];
  List<Videos> videoList = [];
  Future createPlayList(String listName) async {
    try {
      final body = {
        userIdApiKey: AuthLocalDataSource.getUserId(),
        nameApiKey: listName
      };
      final response = await post(Uri.parse(createPlayListUrl),
          body: body, headers: await ApiUtils.getHeaders());
      final responseJson = jsonDecode(response.body);
      debugPrint("===create play list ========$responseJson");
      if (responseJson['error'] == "true") {
        setState(() {
          DesignConfig.setSnackbar(responseJson['error'], context, false);
        });
      } else {
        loadCat();
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future deletePlayList(String typeId) async {
    try {
      final body = {
        userIdApiKey: AuthLocalDataSource.getUserId().toString(),
        typeApiKey: "playlist",
        typeIdApiKey: typeId
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
          saveVideoList.removeAt(dataIndex);
          getCreatedPlayList();
        });
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future getCreatedPlayList() async {
    try {
      final body = {
        userIdApiKey: AuthLocalDataSource.getUserId(),
      };
      final response = await post(Uri.parse(getCreatePlayListUrl),
          body: body, headers: await ApiUtils.getHeaders());
      final responseJson = jsonDecode(response.body);
      debugPrint("===getCreatedPlayList ========$responseJson");
      if (responseJson['error'] == "true") {
        setState(() {
          DesignConfig.setSnackbar(responseJson['error'], context, false);
        });
      } else {
        if (mounted) {
          setState(() {
            var parsedList = responseJson["data"];
            getPlayList = (parsedList as List)
                .map((data) =>
                    GetPlayListModel.fromJson(data as Map<String, dynamic>))
                .toList();

            context.read<SaveVideoProvider>().setSaveVideoList(getPlayList);
            context
                .read<SaveVideoProvider>()
                .changeVideoLength(getPlayList[dataIndex].videos!.length);
          });
        }
        setState(() {
          isLoading = false;
          _animationController!.forward();
        });
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> loadCat() async {
    getCreatedPlayList();
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
    // DesignConfig.showInterstitialAd();
    loadCat();
    super.initState();
  }

  @override
  void dispose() {
    controllerNewPlayList.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    saveVideoList =
        Provider.of<SaveVideoProvider>(context).getSaveVideoPlaylist;
    return _connectionStatus == 'ConnectivityResult.none'
        ? NoConErrorWidget(
            onTap: () {
              setState(() {
                loadCat();
              });
            },
          )
        : Scaffold(
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
                    Navigator.pop(context);
                  })),
              title: Text(StringRes.savedVideos,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: Theme.of(context).secondaryHeaderColor,
                      fontWeight: FontWeight.w700,
                      fontStyle: FontStyle.normal,
                      fontSize: 16.0),
                  textAlign: TextAlign.left),
              actions: [
                Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: InkWell(
                      onTap: () {
                        if (AuthLocalDataSource.getAuthType() == "guest") {
                          Navigator.of(context).pushNamed(Routes.login);
                          /*      Navigator.of(context).pushNamedAndRemoveUntil(
                              '/login', (Route<dynamic> route) => false);*/
                        } else {
                          createNewBottomSheet(size).whenComplete(() {
                            controllerNewPlayList.text = "";
                          });
                        }
                      },
                      child: Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: Icon(
                            Icons.add,
                            color: Theme.of(context).secondaryHeaderColor,
                          )),
                    )),
              ],
            ),
            body: isLoading
                ? ShimmerNotificationWidget(
                    height: MediaQuery.of(context).size.height * .08,
                    length: 15,
                  )
                : saveVideoList.isEmpty
                    ? const NoVideoErrorWidget()
                    : SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListView.builder(
                                itemCount: saveVideoList.length,
                                physics: const NeverScrollableScrollPhysics(),
                                padding: EdgeInsets.only(
                                  top: MediaQuery.of(context).size.height * .01,
                                  bottom:
                                      MediaQuery.of(context).size.height * .1,
                                ),
                                shrinkWrap: true,
                                itemBuilder: (BuildContext context, int index) {
                                  GetPlayListModel item = saveVideoList[index];
                                  videoList = item.videos!;
                                  Map<String, Videos> mp = {};
                                  for (var item in videoList) {
                                    mp[item.videoId!] = item;
                                  }
                                  videoList = mp.values.toList();
                                  return SlideAnimation(
                                    position: index,
                                    itemCount: saveVideoList.length,
                                    slideDirection: SlideDirection.fromBottom,
                                    animationController: _animationController,
                                    child: InkWell(
                                      onTap: () {
                                        for (var item in item.videos!) {
                                          mp[item.videoId!] = item;
                                        }
                                        context
                                            .read<SaveVideoProvider>()
                                            .setVideoList(mp.values.toList());
                                        Navigator.of(context)
                                            .pushReplacementNamed(
                                                Routes.saveVideoDetail,
                                                arguments: {
                                              "title": item.name,
                                            });
                                      },
                                      child: Card(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        margin: const EdgeInsets.only(
                                            left: 15,
                                            right: 15,
                                            top: 10,
                                            bottom: 10),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              borderRadius),
                                        ),
                                        child: Container(
                                          //  height: size.height * .07,
                                          decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            borderRadius: BorderRadius.circular(
                                                borderRadius),
                                          ),
                                          child: ListTile(
                                            dense: true,
                                            horizontalTitleGap: 10,
                                            contentPadding:
                                                const EdgeInsets.only(left: 8),
                                            leading: Container(
                                              width: 50,
                                              height: 50,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                          Radius.circular(
                                                              borderRadius)),
                                                  color: Theme.of(context)
                                                      .primaryColor
                                                      .withOpacity(0.1)),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(12.0),
                                                child: SvgPicture.asset(
                                                  DesignConfig.getIconPath(
                                                      "file.svg"),
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                ),
                                              ),
                                            ),
                                            title: Text(item.name ?? "",
                                                style: TextStyle(
                                                    color: Theme.of(context)
                                                        .secondaryHeaderColor,
                                                    fontWeight: FontWeight.w400,
                                                    fontStyle: FontStyle.normal,
                                                    fontSize: 18.0),
                                                textAlign: TextAlign.left),
                                            subtitle: Text(
                                                (videoList.length.toString()) +
                                                    ((videoList.length
                                                                    .toString() ==
                                                                "0" ||
                                                            videoList.length
                                                                    .toString() ==
                                                                "1")
                                                        ? " Video"
                                                        : " Videos")
                                                /*  Provider.of<SaveVideoProvider>(context)
                                                        .videoLengths
                                                        .toString() +
                                                    (Provider.of<SaveVideoProvider>(
                                                                        context)
                                                                    .videoLengths
                                                                    .toString() ==
                                                                "0" ||
                                                            Provider.of<SaveVideoProvider>(
                                                                        context)
                                                                    .videoLengths
                                                                    .toString() ==
                                                                "1"
                                                        ? " Video"
                                                        : " Videos")*/
                                                ,
                                                style: TextStyle(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .secondary,
                                                    fontWeight: FontWeight.w400,
                                                    fontStyle: FontStyle.normal,
                                                    fontSize: 14.0),
                                                textAlign: TextAlign.left),
                                            trailing: item.id == 0
                                                ? const SizedBox.shrink()
                                                : GestureDetector(
                                                    onTap: () {
                                                      deletePlayList(
                                                          item.id.toString());
                                                      setState(() {
                                                        dataIndex = index;
                                                      });
                                                    },
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              12.0),
                                                      child: SvgPicture.asset(
                                                          DesignConfig
                                                              .getIconPath(
                                                                  "delete.svg")),
                                                    ),
                                                  ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                          ],
                        ),
                      ),
          );
  }

  createNewBottomSheet(dynamic size) {
    return showModalBottomSheet(
        elevation: 0,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
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
                  height: MediaQuery.of(context).size.height * .35, //.31
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      color: Theme.of(context).backgroundColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20.0),
                        topRight: Radius.circular(20.0),
                      )),
                  child: Container(
                      margin: EdgeInsets.only(
                          left: MediaQuery.of(context).size.width * .06,
                          right: MediaQuery.of(context).size.width * .06,
                          top: 10,
                          bottom: 10),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /* SizedBox(
                              height: MediaQuery.of(context).size.height * .01,
                            ), */
                            bottomSheetTitle(title: StringRes.createNew),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * .01,
                            ),
                            bottomSheetSubTitle(
                                subTitle: StringRes.creteNewSubTitle),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * .02,
                            ),
                            TextFormField(
                              controller: controllerNewPlayList,
                              cursorColor: const Color(0xffa2a2a2),
                              style: TextStyle(
                                  color:
                                      Theme.of(context).secondaryHeaderColor),
                              onChanged: (text) {
                                sheetSetState(() {
                                  controllerNewPlayList.text;
                                  debugPrint(controllerNewPlayList.text);
                                });
                              },
                              decoration: InputDecoration(
                                fillColor: SettingsLocalDataSource().theme() ==
                                        StringRes.darkThemeKey
                                    ? darkButtonDisable
                                    : Theme.of(context).scaffoldBackgroundColor,
                                filled: true,
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 20.0,
                                      right: 10,
                                      bottom: 10,
                                      top: 10),
                                  child: SvgPicture.asset(
                                    DesignConfig.getIconPath("file.svg"),
                                    color: controllerNewPlayList.text.isNotEmpty
                                        ? Theme.of(context).primaryColor
                                        : Theme.of(context)
                                            .colorScheme
                                            .secondary
                                            .withOpacity(0.4),
                                  ),
                                ),
                                isDense: true,
                                //contentPadding: EdgeInsets.all(20.0),
                                hintText: StringRes.hintNewPlayList,
                                hintStyle: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondary
                                        .withOpacity(0.4),
                                    fontWeight: FontWeight.w400,
                                    fontStyle: FontStyle.normal,
                                    fontSize: 16.0),
                                focusedBorder: DesignConfig.textFieldBorder(
                                    context: context),
                                focusedErrorBorder:
                                    DesignConfig.textFieldBorder(
                                        context: context),
                                errorBorder: DesignConfig.textFieldBorder(
                                    context: context),
                                enabledBorder: DesignConfig.textFieldBorder(
                                    context: context),
                              ),
                              keyboardType: TextInputType.emailAddress,
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * .02,
                            ),
                            Align(
                              alignment: Alignment.center,
                              child: controllerNewPlayList.text.isNotEmpty
                                  ? DesignConfig.gradientButton(
                                      isBlack: true,
                                      width: 131,
                                      height: 44,
                                      onPress: () {
                                        setState(() {
                                          sheetSetState(() {
                                            createPlayList(controllerNewPlayList
                                                .text
                                                .trim());

                                            Navigator.pop(context);
                                          });
                                        });
                                      },
                                      name: StringRes
                                          .createText /*StringRes.sendLink*/,
                                    )
                                  : Container(
                                      width: 131,
                                      height: 44,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(25)),
                                          border: Border.all(
                                              color: const Color(0x00000000),
                                              width: 1),
                                          gradient: LinearGradient(
                                              begin: const Alignment(
                                                  -0.022495072335004807, 1),
                                              end: const Alignment(
                                                  1.1026651859283447,
                                                  -0.5471386909484863),
                                              colors: [
                                                const Color(0xff415fff)
                                                    .withOpacity(0.5),
                                                const Color(0xff08dcff)
                                                    .withOpacity(0.5)
                                              ])),
                                      child: Text(StringRes.create,
                                          style: const TextStyle(
                                              color: Color(0xffffffff),
                                              fontWeight: FontWeight.w700,
                                              fontStyle: FontStyle.normal,
                                              fontSize: 16.0),
                                          textAlign: TextAlign.center),
                                    ),
                            ),
                            /* SizedBox(
                              height: MediaQuery.of(context).size.height * .02,
                            ), */
                          ])));
            })));
  }

  Widget bottomSheetTitle({required String title}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: Text(title,
              style: TextStyle(
                  color: Theme.of(context).secondaryHeaderColor,
                  fontWeight: FontWeight.w700,
                  fontStyle: FontStyle.normal,
                  fontSize: 18.0),
              textAlign: TextAlign.left),
        ),
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
    );
  }

  Widget bottomSheetSubTitle({required String subTitle}) {
    return Text(subTitle,
        style: TextStyle(
            color: Theme.of(context).secondaryHeaderColor,
            fontWeight: FontWeight.w400,
            fontStyle: FontStyle.normal,
            fontSize: 16.0),
        textAlign: TextAlign.left);
  }
}
