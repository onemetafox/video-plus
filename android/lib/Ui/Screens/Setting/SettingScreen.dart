import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:launch_review/launch_review.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:videoPlus/LocalDataStore/AuthLocalDataStore.dart';
import 'package:videoPlus/Utils/DesignConfig.dart';
import 'package:videoPlus/Utils/StringRes.dart';

import '../../../App/Routes.dart';
import '../../../LocalDataStore/SettingLocalDataSource.dart';
import '../../../Provider/ThemeProvider.dart';
import '../../../Utils/Constant.dart';
import '../../../Utils/InternetConnectivity.dart';
import '../../../Utils/apiParameters.dart';
import '../../../Utils/apiUtils.dart';
import '../ErrorWidget/NoConErrorWidget.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return SettingScreenState();
  }
}

class SettingScreenState extends State<SettingScreen>
    with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> modelScaffoldKey = GlobalKey<ScaffoldState>();
  String _connectionStatus = 'unKnown';
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> connectivitySubscription;
  bool _switchValue = SettingsLocalDataSource.getThemeSwitch(),
      no = false,
      yes = true;
  File? image;
  late ThemeNotifier themeNotifier;
  late Function sheetSetState;
  TextEditingController controllerFullName =
      TextEditingController(text: AuthLocalDataSource.getUserName());
  TextEditingController controllerEmail =
      TextEditingController(text: AuthLocalDataSource.getEmail());
  TextEditingController controllerPhone =
      TextEditingController(text: AuthLocalDataSource.getMobile());
  AnimationController? rotationController;

  Future<void> signOut() async {
    firebaseAuth.signOut();
    googleSignIn.signOut();
    AuthLocalDataSource().setUserId("");
    AuthLocalDataSource().setAuthType("");
    AuthLocalDataSource().setEmail("");
    AuthLocalDataSource().setFcmId("");
    AuthLocalDataSource().setUserFirebaseId("");
    AuthLocalDataSource().setUserName("");
    AuthLocalDataSource().changeAuthStatus(false);
    AuthLocalDataSource().setJwtToken("");
    AuthLocalDataSource().setProfile("");
    debugPrint("Sign out");
  }

  //image camera
  _getFromCamera() async {
    XFile? pickedFile = await ImagePicker().pickImage(
      source: ImageSource.camera,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    if (pickedFile != null) {
      setState(() {
        image = File(pickedFile.path);
      });
      uploadImage(image!);
    }
  }

// image gallery
  _getFromGallery() async {
    XFile? pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    if (pickedFile != null) {
      setState(() {
        image = File(pickedFile.path);
      });
      uploadImage(image!);
    }
  }

  Future getUserById() async {
    try {
      final body = {
        userIdApiKey: AuthLocalDataSource.getUserId(),
      };
      final response = await post(Uri.parse(getUserByIdUrl),
          body: body, headers: await ApiUtils.getHeaders());
      final responseJson = jsonDecode(response.body);
      final getData = responseJson['data'];

      debugPrint("===get user by id========$responseJson");
      if (responseJson['error'] == true) {
        if (mounted) {
          DesignConfig.setSnackbar(responseJson['error'], context, false);
        }
      } else {
        setState(() {
          AuthLocalDataSource().setUserName(getData['name']);
          AuthLocalDataSource().setEmail(getData["email"]);
          AuthLocalDataSource().setMobile(getData["mobile"]);
          AuthLocalDataSource().setProfile(getData["profile"]);
        });
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future deleteAccount() async {
    try {
      final body = {
        userIdApiKey: AuthLocalDataSource.getUserId(),
      };
      final response = await post(Uri.parse(deleteAccountUrl),
          body: body, headers: await ApiUtils.getHeaders());
      final responseJson = jsonDecode(response.body);
      debugPrint("==delete account ==$responseJson");
      setState(() {
        AuthLocalDataSource().setUserId("");
        AuthLocalDataSource().setAuthType("");
        AuthLocalDataSource().setEmail("");
        AuthLocalDataSource().setFcmId("");
        AuthLocalDataSource().setUserFirebaseId("");
        AuthLocalDataSource().setUserName("");
        AuthLocalDataSource().changeAuthStatus(false);
        AuthLocalDataSource().setJwtToken("");
        AuthLocalDataSource().setProfile("");
      });
      if (responseJson['error'] == true) {
        if (mounted) {
          DesignConfig.setSnackbar(responseJson['message'], context, false);
        }
      } else {
        setState(() {
          DesignConfig.setSnackbar(responseJson['message'], context, false);
        });
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  // get data from api update profile image
  Future uploadImage(File? images) async {
    Map<String, String> body = {
      userIdApiKey: AuthLocalDataSource.getUserId(),
    };
    Map<String, File> fileList = {
      profileApiKey: images!,
    };
    var response = await postApiFile(Uri.parse(getUploadProfileImageUrl),
        fileList, body, AuthLocalDataSource.getUserId());
    var res = json.decode(response);
  }

  Future postApiFile(Uri url, Map<String, File?> fileList,
      Map<String, String?> body, String? userId) async {
    try {
      var request = MultipartRequest('POST', url);
      request.headers.addAll(await ApiUtils.getHeaders());

      body.forEach((key, value) {
        request.fields[key] = value!;
      });

      for (var key in fileList.keys.toList()) {
        var pic = await MultipartFile.fromPath(key, fileList[key]!.path);
        request.files.add(pic);
      }
      var res = await request.send();
      var responseData = await res.stream.toBytes();
      var response = String.fromCharCodes(responseData);
      if (res.statusCode == 200) {
        print("========response===$response");
        await getUserById();
        return response;
      }
    } catch (e) {
      DesignConfig.setSnackbar(e.toString(), context, false);
    }
  }

  Future profileUpdate(
      {required String userId,
      String? email,
      String? name,
      String? mobile}) async {
    try {
      final body = {
        userIdApiKey: userId,
        emailApiKey: email,
        nameApiKey: name,
        mobileApiKey: mobile,
      };
      final response = await post(Uri.parse(getProfileUpdateUrl),
          body: body, headers: await ApiUtils.getHeaders());
      final responseJson = jsonDecode(response.body);
      debugPrint("===Update profile========$responseJson");
      if (responseJson['error'] == true) {
        DesignConfig.setSnackbar(responseJson['error'], context, false);
      } else {
        if (mounted) {
          setState(() {
            DesignConfig.setSnackbar(responseJson['message'], context, false);
          });
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  void initState() {
    getUserById();
    rotationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    rotationController!.forward(from: 0.0);
    CheckInternet.initConnectivity().then((value) => setState(() {
          _connectionStatus = value;
        }));
    connectivitySubscription =
        _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      CheckInternet.updateConnectionStatus(result).then((value) => setState(() {
            _connectionStatus = value;
          }));
    });
    super.initState();
  }

  @override
  void dispose() {
    controllerFullName.dispose();

    controllerEmail.dispose();
    controllerPhone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    themeNotifier = Provider.of<ThemeNotifier>(context);
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
              toolbarHeight: 0,
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
            body: SingleChildScrollView(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).size.height * .08),
              child: Column(
                children: [
                  topProfile(),
                  DesignConfig.getPaymentMode == paymentStatusVal
                      ? settingListTile(
                          size: size,
                          icon: DesignConfig.getIconPath("membership.svg"),
                          title: StringRes.membership,
                          onPress: () {
                            if (AuthLocalDataSource.getAuthType() == "guest") {
                              Navigator.of(context).pushNamed(Routes.login);
                            } else {
                              Navigator.of(context)
                                  .pushNamed(Routes.buyMembership);
                            }
                          })
                      : Container(),
                  appThemeSwitch(),
                  settingListTile(
                      size: size,
                      icon: DesignConfig.getIconPath("playlist.svg"),
                      title: StringRes.savedVideos,
                      onPress: () {
                        Navigator.of(context).pushNamed(Routes.savedVideos);
                      }),
                  settingListTile(
                      size: size,
                      icon: DesignConfig.getIconPath("about_us.svg"),
                      title: StringRes.aboutUs,
                      onPress: () {
                        Navigator.of(context).pushNamed(Routes.aboutUs,
                            arguments: {
                              'title': StringRes.aboutUs,
                              'type': aboutUsApiKey
                            });
                      }),
                  settingListTile(
                      size: size,
                      icon: DesignConfig.getIconPath("conttect.svg"),
                      title: StringRes.contactUS,
                      onPress: () {
                        Navigator.of(context).pushNamed(Routes.aboutUs,
                            arguments: {
                              'title': StringRes.contactUS,
                              'type': contactUsApiKey
                            });
                      }),
                  settingListTile(
                      size: size,
                      icon: DesignConfig.getIconPath("rate.svg"),
                      title: StringRes.rateUs,
                      onPress: () {
                        LaunchReview.launch(
                          androidAppId: packageName,
                          iOSAppId: iosAppId,
                        );
                      }),
                  settingListTile(
                      size: size,
                      icon: DesignConfig.getIconPath("share (1).svg"),
                      title: StringRes.share,
                      onPress: () {
                        try {
                          //  projectAppID = await GetVersion.appID;
                          // name = await GetVersion.appName;

                          if (Platform.isAndroid) {
                            Share.share(
                                "$appName\nhttps://play.google.com/store/apps/details?id=$packageName");
                          } else {
                            Share.share("$appName \n$iosAppId");
                          }
                        } on Exception {
                          debugPrint("error");
                        }
                      }),
                  settingListTile(
                      size: size,
                      icon: DesignConfig.getIconPath("p_p.svg"),
                      title: StringRes.privacyPolicy,
                      onPress: () {
                        Navigator.of(context).pushNamed(Routes.aboutUs,
                            arguments: {
                              'title': StringRes.privacyPolicy,
                              'type': ppApiKey
                            });
                      }),
                  settingListTile(
                      size: size,
                      icon: DesignConfig.getIconPath("t_c.svg"),
                      title: StringRes.termsCondition,
                      onPress: () {
                        Navigator.of(context).pushNamed(Routes.aboutUs,
                            arguments: {
                              'title': StringRes.termsCondition,
                              'type': termApiKey
                            });
                      }),
                  AuthLocalDataSource.getAuthType() == guestNameApiKey
                      ? Container()
                      : settingListTile(
                          size: size,
                          icon: DesignConfig.getIconPath("logout.svg"),
                          title: StringRes.logOut,
                          onPress: () async {
                            deleteAndLogoutDialog(
                                contxt: context,
                                img: //Provider.of<ThemeNotifier>(context)
                                    themeNotifier.getThemeMode() ==
                                            ThemeMode.dark
                                        ? "image_logout_dark.svg"
                                        : "image_logout.svg",
                                msg: StringRes.logOutText,
                                yesAction: yesBtnAction,
                                noAction: noBtnAction);
                            // logOutDialog();
                          }),
                  AuthLocalDataSource.getAuthType() == guestNameApiKey
                      ? Container()
                      : settingListTile(
                          size: size,
                          icon: DesignConfig.getIconPath("delete.svg"),
                          title: StringRes.deleteAccount,
                          onPress: () async {
                            deleteAndLogoutDialog(
                                contxt: context,
                                img: "delete_account.svg",
                                msg: StringRes.deleteAccountText,
                                yesAction: deleteAccAction,
                                noAction: noBtnAction);
                            // deleteAccountDialog();
                          })
                ],
              ),
            ));
  }

  /*  logOutDialog() {
    return showDialog(
        context: context,
        builder: (context) => StatefulBuilder(
                builder: (BuildContext context, StateSetter setStater) {
              return Container(
                padding: const EdgeInsets.all(10.0),
                // height: MediaQuery.of(context).size.height * .4,
                // width: MediaQuery.of(context).size.width,
                child: AlertDialog(
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20.0))),
                  backgroundColor: Theme.of(context).backgroundColor,
                  content: SizedBox(
                    // height: MediaQuery.of(context).size.height * .4,
                    // width: MediaQuery.of(context).size.width,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SvgPicture.asset(
                            DesignConfig.getIconPath(
                                //Provider.of<ThemeNotifier>(context)
                                themeNotifier.getThemeMode() == ThemeMode.dark
                                    ? "image_logout_dark.svg"
                                    : "image_logout.svg"),
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * .05,
                        ),
                        Text(StringRes.logOutText,
                            style: TextStyle(
                                color: Theme.of(context).secondaryHeaderColor,
                                height: 1,
                                fontWeight: FontWeight.w700,
                                fontStyle: FontStyle.normal,
                                fontSize: 16.0),
                            textAlign: TextAlign.center),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * .05,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                minimumSize: Size(
                                    MediaQuery.of(context).size.width *
                                        .28, //3,
                                    MediaQuery.of(context).size.height * .055),
                                backgroundColor: no
                                    ? Theme.of(context).secondaryHeaderColor
                                    : Theme.of(context).backgroundColor,
                                elevation: 0,
                                alignment: Alignment.center,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25.0),
                                ),
                                side: BorderSide(
                                    color:
                                        Theme.of(context).secondaryHeaderColor,
                                    width: 1),
                              ),
                              onPressed: () {
                                setState(() {
                                  setStater(() {
                                    no = true;
                                    yes = false;
                                    Navigator.pop(context);
                                  });
                                });
                              },
                              child: Text(StringRes.no,
                                  style: TextStyle(
                                      color: no
                                          ? Theme.of(context).backgroundColor
                                          : Theme.of(context)
                                              .secondaryHeaderColor,
                                      fontWeight: FontWeight.w700,
                                      fontFamily: "ProductSans",
                                      fontStyle: FontStyle.normal,
                                      fontSize: 14.0),
                                  textAlign: TextAlign.center),
                            ),
                            /* SizedBox(
                              width: MediaQuery.of(context).size.width * .01,
                            ), */
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                minimumSize: Size(
                                    MediaQuery.of(context).size.width *
                                        .28, //.3,
                                    MediaQuery.of(context).size.height * .055),
                                backgroundColor: yes
                                    ? Theme.of(context).secondaryHeaderColor
                                    : Theme.of(context).backgroundColor,
                                elevation: 0,
                                alignment: Alignment.center,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25.0),
                                ),
                                side: BorderSide(
                                    color:
                                        Theme.of(context).secondaryHeaderColor,
                                    width: 1),
                              ),
                              onPressed: () {
                                setState(() {
                                  setStater(() {
                                    yes = true;
                                    no = false;
                                    signOut();
                                    Navigator.of(context)
                                        .pushNamedAndRemoveUntil('/login',
                                            (Route<dynamic> route) => false);
                                  });
                                });
                              },
                              child: // No
                                  Text(StringRes.yes,
                                      style: TextStyle(
                                          color: yes
                                              ? Theme.of(context)
                                                  .backgroundColor
                                              : Theme.of(context)
                                                  .secondaryHeaderColor,
                                          fontWeight: FontWeight.w700,
                                          fontFamily: "ProductSans",
                                          fontStyle: FontStyle.normal,
                                          fontSize: 14.0),
                                      textAlign: TextAlign.center),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              );
            }));
  } */

  Widget outLinedButton(
      {required String btnText,
      required VoidCallback? btnAction,
      required bool yesOrNo}) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        minimumSize: Size(
            MediaQuery.of(context).size.width * .28, //3,
            MediaQuery.of(context).size.height * .055),
        backgroundColor: yesOrNo //no
            ? Theme.of(context).secondaryHeaderColor
            : Theme.of(context).backgroundColor,
        /* 
                yes
                                  ? Theme.of(context).secondaryHeaderColor
                                  : Theme.of(context).backgroundColor,
                */
        elevation: 0,
        alignment: Alignment.center,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.0),
        ),
        side:
            BorderSide(color: Theme.of(context).secondaryHeaderColor, width: 1),
      ),
      onPressed: btnAction,
      /*  () {
            setState(() {
              setStater(() {
                no = true;
                yes = false;
                Navigator.pop(context);
              });
            });
          }, */
      child: Text(btnText,
          style: TextStyle(
              color: yesOrNo //no
                  ? Theme.of(context).backgroundColor
                  : Theme.of(context).secondaryHeaderColor,
              fontWeight: FontWeight.w700,
              fontFamily: "ProductSans",
              fontStyle: FontStyle.normal,
              fontSize: 14.0),
          textAlign: TextAlign.center),
    );
  }

  Future deleteAndLogoutDialog(
      {required BuildContext contxt,
      required String img,
      required String msg,
      required VoidCallback? yesAction,
      required VoidCallback? noAction}) {
    return showDialog(
        context: contxt,
        builder: (contxt) => StatefulBuilder(
                builder: (BuildContext context, StateSetter setStater) {
              return Container(
                padding: const EdgeInsets.all(10.0),
                child: AlertDialog(
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20.0))),
                  backgroundColor: Theme.of(context).backgroundColor,
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SvgPicture.asset(
                          DesignConfig.getIconPath(img),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * .05,
                      ),
                      Text(msg,
                          style: TextStyle(
                              color: Theme.of(context).secondaryHeaderColor,
                              height: 1,
                              fontWeight: FontWeight.w700,
                              fontStyle: FontStyle.normal,
                              fontSize: 16.0),
                          textAlign: TextAlign.center),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * .05,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          outLinedButton(
                              btnText: StringRes.no,
                              btnAction: noBtnAction,
                              yesOrNo: no),
                          outLinedButton(
                              btnText: StringRes.yes,
                              btnAction: yesBtnAction,
                              yesOrNo: yes),
                          /* OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              minimumSize: Size(
                                  MediaQuery.of(context).size.width * .28, //.3,
                                  MediaQuery.of(context).size.height * .055),
                              backgroundColor: yes
                                  ? Theme.of(context).secondaryHeaderColor
                                  : Theme.of(context).backgroundColor,
                              elevation: 0,
                              alignment: Alignment.center,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25.0),
                              ),
                              side: BorderSide(
                                  color: Theme.of(context).secondaryHeaderColor,
                                  width: 1),
                            ),
                            onPressed: () {
                              setState(() {
                                setStater(() {
                                  yes = true;
                                  no = false;
                                  signOut();
                                  Navigator.of(context).pushNamedAndRemoveUntil(
                                      '/login',
                                      (Route<dynamic> route) => false);
                                });
                              });
                            },
                            child: // No
                                Text(StringRes.yes,
                                    style: TextStyle(
                                        color: yes
                                            ? Theme.of(context).backgroundColor
                                            : Theme.of(context)
                                                .secondaryHeaderColor,
                                        fontWeight: FontWeight.w700,
                                        fontFamily: "ProductSans",
                                        fontStyle: FontStyle.normal,
                                        fontSize: 14.0),
                                    textAlign: TextAlign.center),
                          ), */
                        ],
                      )
                    ],
                  ),
                ),
              );
            }));
  }

  noBtnAction() {
    setState(() {
      no = true;
      yes = false;
      Navigator.pop(context);
    });
  }

  yesBtnAction() {
    setState(() {
      yes = true;
      no = false;
      signOut();
      Navigator.of(context)
          .pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
    });
  }

  bool currentUserCheck = false;
  deleteAccAction() {
    setState(() {
      yes = true;
      no = false;
      User? currentUser = FirebaseAuth.instance.currentUser;
      debugPrint("currentUser is:$currentUser");
      currentUser?.delete().catchError((onError) {
        debugPrint("on error:$onError");
        setState(() {
          currentUserCheck = true;
        });
        Navigator.pop(context);
        DesignConfig.setSnackbar(StringRes.msgRelogin, context, false);
      });
      !currentUserCheck ? deleteAccount() : null;
    });
  }

  /*  bool currentUserCheck = false;
  deleteAccountDialog() {
    return showDialog(
        context: context,
        builder: (context) => StatefulBuilder(
                builder: (BuildContext context, StateSetter setStater) {
              return Container(
                padding: const EdgeInsets.all(10.0),
                height: MediaQuery.of(context).size.height * .46,
                width: MediaQuery.of(context).size.width,
                child: AlertDialog(
                  shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.all(Radius.circular(borderRadius))),
                  backgroundColor: Theme.of(context).backgroundColor,
                  content: SizedBox(
                    height: MediaQuery.of(context).size.height * .46,
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SvgPicture.asset(
                            DesignConfig.getIconPath("delete_account.svg"),
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * .05,
                        ),
                        Text(StringRes.deleteAccountText,
                            style: TextStyle(
                                color: Theme.of(context).secondaryHeaderColor,
                                fontWeight: FontWeight.w700,
                                fontStyle: FontStyle.normal,
                                fontSize: 18.0),
                            textAlign: TextAlign.center),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * .05,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                minimumSize: Size(
                                    MediaQuery.of(context).size.width * .3,
                                    MediaQuery.of(context).size.height * .055),
                                backgroundColor: no
                                    ? Theme.of(context).secondaryHeaderColor
                                    : Theme.of(context).backgroundColor,
                                elevation: 0,
                                alignment: Alignment.center,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25.0),
                                ),
                                side: BorderSide(
                                    color:
                                        Theme.of(context).secondaryHeaderColor,
                                    width: 1),
                              ),
                              onPressed: () {
                                setState(() {
                                  setStater(() {
                                    no = true;
                                    yes = false;
                                    Navigator.pop(context);
                                  });
                                });
                              },
                              child: // No
                                  Text(StringRes.no,
                                      style: TextStyle(
                                          color: no
                                              ? Theme.of(context)
                                                  .backgroundColor
                                              : Theme.of(context)
                                                  .secondaryHeaderColor,
                                          fontWeight: FontWeight.w700,
                                          fontFamily: "ProductSans",
                                          fontStyle: FontStyle.normal,
                                          fontSize: 14.0),
                                      textAlign: TextAlign.center),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * .01,
                            ),
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                minimumSize: Size(
                                    MediaQuery.of(context).size.width * .3,
                                    MediaQuery.of(context).size.height * .055),
                                backgroundColor: yes
                                    ? Theme.of(context).secondaryHeaderColor
                                    : Theme.of(context).backgroundColor,
                                elevation: 0,
                                alignment: Alignment.center,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25.0),
                                ),
                                side: BorderSide(
                                    color:
                                        Theme.of(context).secondaryHeaderColor,
                                    width: 1),
                              ),
                              onPressed: () {
                                setState(() {
                                  setStater(() {
                                    yes = true;
                                    no = false;
                                    User? currentUser =
                                        FirebaseAuth.instance.currentUser;
                                    debugPrint("currentUser is:$currentUser");
                                    currentUser?.delete().catchError((onError) {
                                      debugPrint("on error:$onError");
                                      setState(() {
                                        setStater(() {
                                          currentUserCheck = true;
                                        });
                                      });
                                      Navigator.pop(context);
                                      DesignConfig.setSnackbar(
                                          StringRes.msgRelogin, context, false);
                                    });
                                    !currentUserCheck ? deleteAccount() : null;
                                  });
                                });
                              },
                              child: Text(StringRes.yes,
                                  style: TextStyle(
                                      color: yes
                                          ? Theme.of(context).backgroundColor
                                          : Theme.of(context)
                                              .secondaryHeaderColor,
                                      fontWeight: FontWeight.w700,
                                      fontFamily: "ProductSans",
                                      fontStyle: FontStyle.normal,
                                      fontSize: 14.0),
                                  textAlign: TextAlign.center),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              );
            }));
  } */

  Widget topProfile() {
    return Container(
      height: MediaQuery.of(context).size.height * .18,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
        color: Theme.of(context).colorScheme.primary,
      ),
      child: Card(
        margin: EdgeInsets.zero,
        color: Theme.of(context).colorScheme.primary,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
                radius: 40,
                child: AuthLocalDataSource.getAuthType() ==
                            guestNameApiKey /*||
                        image == null*/
                        ||
                        AuthLocalDataSource.getProfile() == ""
                    ? ClipOval(
                        child: Image.asset(
                          DesignConfig.getImagePath("d_profile.png"),
                          width: 135,
                          height: 135,
                          fit: BoxFit.fill,
                        ),
                      )
                    : /*ClipOval(
                        child: image != null
                            ? ClipOval(
                                child: Image.file(
                                  image!,
                                  width: 135,
                                  height: 135,
                                  fit: BoxFit.fill,
                                ),
                              )
                            :*/
                    ClipOval(
                        child: CachedNetworkImage(
                        imageUrl: AuthLocalDataSource.getProfile(),
                        fadeInDuration: const Duration(milliseconds: 100),
                        placeholder: (context, url) => Image.asset(
                          DesignConfig.getImagePath("d_profile.png"),
                          width: 135,
                          height: 135,
                          fit: BoxFit.fill,
                        ),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                        width: 135,
                        height: 135,
                        fit: BoxFit.fill,
                      ))),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(AuthLocalDataSource.getUserName(),
                    style: TextStyle(
                        color: Theme.of(context).secondaryHeaderColor,
                        fontWeight: FontWeight.w900,
                        fontStyle: FontStyle.normal,
                        fontSize: 20.0),
                    textAlign: TextAlign.center),
                AuthLocalDataSource.getAuthType() == mobileApiKey
                    ? Text(AuthLocalDataSource.getMobile(),
                        style: TextStyle(
                            color: Theme.of(context).hintColor,
                            fontWeight: FontWeight.w400,
                            fontStyle: FontStyle.normal,
                            fontSize: 14.0),
                        textAlign: TextAlign.center)
                    : Text(AuthLocalDataSource.getEmail(),
                        style: TextStyle(
                            color: Theme.of(context).hintColor,
                            fontWeight: FontWeight.w400,
                            fontStyle: FontStyle.normal,
                            fontSize: 14.0),
                        textAlign: TextAlign.center),
                AuthLocalDataSource.getAuthType() == mobileApiKey
                    ? Text(AuthLocalDataSource.getEmail(),
                        style: TextStyle(
                            color: Theme.of(context).hintColor,
                            fontWeight: FontWeight.w400,
                            fontStyle: FontStyle.normal,
                            fontSize: 14.0),
                        textAlign: TextAlign.center)
                    : Text(AuthLocalDataSource.getMobile(),
                        style: TextStyle(
                            color: Theme.of(context).hintColor,
                            fontWeight: FontWeight.w400,
                            fontStyle: FontStyle.normal,
                            fontSize: 14.0),
                        textAlign: TextAlign.center)
                /* getMobile()*/
              ],
            ),
            GestureDetector(
              onTap: () {
                if (AuthLocalDataSource.getAuthType() == guestNameApiKey) {
                  Navigator.of(context).pushNamed(Routes.login);
                } else {
                  chooseImageBottomSheet();
                }
              },
              child: Container(
                margin: EdgeInsets.only(
                    bottom: AuthLocalDataSource.getAuthType() == guestNameApiKey
                        ? MediaQuery.of(context).size.height * .05
                        : 0),
                child: Icon(
                  Icons.edit,
                  size: 20,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget appThemeSwitch() {
    return Column(
      children: [
        ListTile(
          leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(13)),
                  color: Theme.of(context).primaryColor.withOpacity(0.1)),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: RotationTransition(
                  turns:
                      Tween(begin: 0.0, end: 1.0).animate(rotationController!),
                  child: SvgPicture.asset(
                    DesignConfig.getIconPath("theme.svg"),
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              )),
          title: Text(StringRes.appTheme,
              style: TextStyle(
                  color: Theme.of(context).secondaryHeaderColor,
                  fontWeight: FontWeight.w400,
                  fontStyle: FontStyle.normal,
                  fontSize: 16.0),
              textAlign: TextAlign.left),
          trailing: Switch(
            value: _switchValue,
            activeColor: Theme.of(context).primaryColor,
            onChanged: (value) {
              _switchValue = value;
              SettingsLocalDataSource().setThemeSwitch(_switchValue);
              if (_switchValue) {
                themeNotifier.setThemeMode(ThemeMode.dark);
                SettingsLocalDataSource().setTheme(StringRes.darkThemeKey);
                if (mounted) {
                  SystemChrome.setSystemUIOverlayStyle(
                      SystemUiOverlayStyle.light);
                }
              } else {
                themeNotifier.setThemeMode(ThemeMode.light);
                SettingsLocalDataSource().setTheme(StringRes.lightThemeKey);
                if (mounted) {
                  SystemChrome.setSystemUIOverlayStyle(
                      SystemUiOverlayStyle.dark);
                }
              }
            },
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Container(
            height: 0.3,
            margin: const EdgeInsets.only(left: 20, right: 20),
            decoration: BoxDecoration(
                color: Theme.of(context).hintColor.withOpacity(0.5)))
      ],
    );
  }

  Widget settingListTile(
      {dynamic size,
      required String icon,
      required String title,
      required VoidCallback onPress}) {
    return Column(
      children: [
        GestureDetector(
          onTap: onPress,
          child: ListTile(
            leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(13)),
                    color: Theme.of(context).primaryColor.withOpacity(0.1)),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: RotationTransition(
                    turns: Tween(begin: 0.0, end: 1.0)
                        .animate(rotationController!),
                    child: SvgPicture.asset(
                      icon,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                )),
            title: Text(title,
                style: TextStyle(
                    color: Theme.of(context).secondaryHeaderColor,
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.normal,
                    fontSize: 16.0),
                textAlign: TextAlign.left),
            /* trailing: Icon(
              Icons.arrow_forward_ios,
              size: 20,
            ),*/
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Container(
            height: 0.3,
            margin: const EdgeInsets.only(left: 20, right: 20),
            decoration: BoxDecoration(
                color: Theme.of(context).hintColor.withOpacity(0.5)))
      ],
    );
  }

  Future<bool> requestPhotosPermission() async {
    Permission storagePermission = Permission.storage;
    bool permissionsGiven = (await storagePermission.status).isGranted;
    if (permissionsGiven) {
      print(permissionsGiven);
      return permissionsGiven;
    }
    permissionsGiven = (await storagePermission.request()).isGranted;
    print(permissionsGiven);
    return permissionsGiven;
  }

  chooseProfileDialog() {
    showDialog(
        context: context,
        builder: (context) => StatefulBuilder(
                builder: (BuildContext context, StateSetter setStater) {
              sheetSetState = setStater;
              return Container(
                  padding: const EdgeInsets.all(10.0),
                  height: MediaQuery.of(context).size.height * .2,
                  child: AlertDialog(
                      elevation: 0,
                      shape: const RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(borderRadius))),
                      backgroundColor: Theme.of(context).backgroundColor,
                      content: // Are you sure. ?
                          SizedBox(
                              height: MediaQuery.of(context).size.height * .18,
                              child: Column(
                                children: [
                                  bottomSheetTitle(
                                    title: StringRes.chooseProfile,
                                  ),
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        .02,
                                  ),
                                  GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          sheetSetState(() {
                                            Navigator.pop(context);
                                            _getFromCamera();
                                          });
                                        });
                                      },
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: 40,
                                            height: 40,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    const BorderRadius.all(
                                                        Radius.circular(13)),
                                                color: Theme.of(context)
                                                    .primaryColor
                                                    .withOpacity(0.1)),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(12.0),
                                              child: SvgPicture.asset(
                                                  DesignConfig.getIconPath(
                                                      "cemera_icon.svg")),
                                            ),
                                          ),
                                          SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                .03,
                                          ),
                                          Text(StringRes.camera,
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .secondaryHeaderColor,
                                                  fontWeight: FontWeight.w400,
                                                  fontStyle: FontStyle.normal,
                                                  fontSize: 16.0),
                                              textAlign: TextAlign.center),
                                        ],
                                      )),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          sheetSetState(() {
                                            Navigator.pop(context);
                                            _getFromGallery();
                                          });
                                        });
                                      },
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: 40,
                                            height: 40,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    const BorderRadius.all(
                                                        Radius.circular(13)),
                                                color: Theme.of(context)
                                                    .primaryColor
                                                    .withOpacity(0.1)),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(12.0),
                                              child: SvgPicture.asset(
                                                  DesignConfig.getIconPath(
                                                      "gallary.svg")),
                                            ),
                                          ),
                                          SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                .04,
                                          ),
                                          // Gallery
                                          Text(StringRes.gallery,
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .secondaryHeaderColor,
                                                  fontWeight: FontWeight.w400,
                                                  fontStyle: FontStyle.normal,
                                                  fontSize: 16.0),
                                              textAlign: TextAlign.center)
                                        ],
                                      ))
                                ],
                              ))));
            }));
  }

  bool check = false;
  chooseImageBottomSheet() {
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
        builder: (_) => Scaffold(
              //for snackbar
              backgroundColor: Colors.transparent,
              extendBody: false,
              key: modelScaffoldKey,
              resizeToAvoidBottomInset: true,
              bottomSheet: Padding(
                  padding: MediaQuery.of(context).viewInsets,
                  child: StatefulBuilder(
                      builder: (BuildContext context, StateSetter setStater) {
                    sheetSetState = setStater;
                    return Container(
                        height: MediaQuery.of(context).size.height * .36,
                        // width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                            color: Theme.of(context).backgroundColor,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(20.0),
                              topRight: Radius.circular(20.0),
                            )),
                        child: Container(
                            color: Theme.of(context).backgroundColor,
                            margin: EdgeInsets.only(
                                left: MediaQuery.of(context).size.width * .06,
                                right: MediaQuery.of(context).size.width * .06),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        .03,
                                  ),
                                  bottomSheetTitle(
                                      title: StringRes.editProfile),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      InkWell(
                                        onTap: () async {
                                          if (await requestPhotosPermission()) {
                                            Navigator.pop(context);
                                            chooseProfileDialog();
                                          } else {
                                            DesignConfig.setSnackbar(
                                                StringRes.permissionDenied,
                                                context,
                                                false);
                                          }
                                        },
                                        child: Container(
                                          height: 70,
                                          width: 70,
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                          ),
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              CircleAvatar(
                                                  radius: 30,
                                                  child: ClipOval(
                                                      child: AuthLocalDataSource
                                                                      .getAuthType() ==
                                                                  guestNameApiKey &&
                                                              image == null &&
                                                              AuthLocalDataSource
                                                                      .getProfile() ==
                                                                  ""
                                                          ? ClipOval(
                                                              child:
                                                                  Image.asset(
                                                                DesignConfig
                                                                    .getImagePath(
                                                                        "d_profile.png"),
                                                                width: 135,
                                                                height: 135,
                                                                fit:
                                                                    BoxFit.fill,
                                                              ),
                                                            )
                                                          : ClipOval(
                                                              child:
                                                                  CachedNetworkImage(
                                                                imageUrl:
                                                                    AuthLocalDataSource
                                                                        .getProfile(),
                                                                fadeInDuration:
                                                                    const Duration(
                                                                        milliseconds:
                                                                            100),
                                                                placeholder: (context,
                                                                        url) =>
                                                                    Image.asset(
                                                                  DesignConfig
                                                                      .getImagePath(
                                                                          "d_profile.png"),
                                                                  width: 135,
                                                                  height: 135,
                                                                  fit: BoxFit
                                                                      .fill,
                                                                ),
                                                                errorWidget: (context,
                                                                        url,
                                                                        error) =>
                                                                    const Icon(Icons
                                                                        .error),
                                                                width: 135,
                                                                height: 135,
                                                                fit:
                                                                    BoxFit.fill,
                                                              ),
                                                            ))),
                                              Container(
                                                height: 30,
                                                width: 30,
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                decoration: const BoxDecoration(
                                                    color: Colors.black54,
                                                    shape: BoxShape.circle),
                                                child: SvgPicture.asset(
                                                  DesignConfig.getIconPath(
                                                      "cemera_icon.svg"),
                                                  color: Colors.white,
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 30,
                                      ),
                                      Expanded(
                                        flex: 5,
                                        child: TextFormField(
                                          autovalidateMode: AutovalidateMode
                                              .onUserInteraction,
                                          controller: controllerFullName,
                                          cursorColor: const Color(0xffa2a2a2),
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .secondaryHeaderColor),
                                          decoration: InputDecoration(
                                            filled: true,
                                            fillColor: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            contentPadding:
                                                const EdgeInsets.only(
                                                    top: 15,
                                                    bottom: 15,
                                                    left: 15),
                                            hintText: StringRes.hintFullName,
                                            hintStyle: TextStyle(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .secondary
                                                    .withOpacity(0.4),
                                                fontWeight: FontWeight.w400,
                                                fontStyle: FontStyle.normal,
                                                fontSize: 16.0),
                                            focusedBorder:
                                                DesignConfig.textFieldBorder(
                                                    context: context),
                                            focusedErrorBorder:
                                                DesignConfig.textFieldBorder(
                                                    context: context),
                                            errorBorder:
                                                DesignConfig.textFieldBorder(
                                                    context: context),
                                            enabledBorder:
                                                DesignConfig.textFieldBorder(
                                                    context: context),
                                          ),
                                          keyboardType:
                                              TextInputType.emailAddress,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        .02,
                                  ),
                                  TextFormField(
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    controller:
                                        AuthLocalDataSource.getAuthType() ==
                                                mobileApiKey
                                            ? controllerEmail
                                            : controllerPhone,
                                    cursorColor: const Color(0xffa2a2a2),
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .secondaryHeaderColor),
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor:
                                          Theme.of(context).colorScheme.primary,
                                      contentPadding: const EdgeInsets.only(
                                          top: 15, bottom: 15, left: 15),
                                      hintText:
                                          AuthLocalDataSource.getAuthType() ==
                                                  mobileApiKey
                                              ? StringRes.hintEmail
                                              : StringRes.hintMobile,
                                      hintStyle: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary
                                              .withOpacity(0.4),
                                          fontWeight: FontWeight.w400,
                                          fontStyle: FontStyle.normal,
                                          fontSize: 16.0),
                                      focusedBorder:
                                          DesignConfig.textFieldBorder(
                                              context: context),
                                      focusedErrorBorder:
                                          DesignConfig.textFieldBorder(
                                              context: context),
                                      errorBorder: DesignConfig.textFieldBorder(
                                          context: context),
                                      enabledBorder:
                                          DesignConfig.textFieldBorder(
                                              context: context),
                                    ),
                                  ),
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        .015,
                                  ),
                                  Align(
                                      alignment: Alignment.center,
                                      child: DesignConfig.gradientButton(
                                        isBlack: false,
                                        isLoading: check,
                                        width: 131,
                                        height: 44,
                                        onPress: () async {
                                          if (check) return;
                                          setStater(() {
                                            check = true;
                                          });
                                          await profileUpdate(
                                              userId: AuthLocalDataSource
                                                  .getUserId(),
                                              name: controllerFullName.text
                                                  .trim(),
                                              mobile:
                                                  controllerPhone.text.trim(),
                                              email:
                                                  controllerEmail.text.trim());

                                          await getUserById();
                                          Navigator.pop(context);
                                          setStater(() {
                                            check = false;
                                          });
                                        },
                                        name: StringRes.save,
                                      )),
                                ])));
                  })),
            ));
  }

  Widget bottomSheetTitle({required String title}) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * .05,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Text(title,
                style: TextStyle(
                    color: Theme.of(context).secondaryHeaderColor,
                    fontWeight: FontWeight.w700,
                    fontStyle: FontStyle.normal,
                    fontSize: 20.0),
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
      ),
    );
  }
}
