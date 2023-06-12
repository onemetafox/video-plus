import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:http/http.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:videoPlus/LocalDataStore/AuthLocalDataStore.dart';
import 'package:videoPlus/Utils//SlideAnimation.dart';

import '../../App/Routes.dart';
import '../../LocalDataStore/SettingLocalDataSource.dart';
import '../../Provider/SettingProvider.dart';
import '../../Utils/DesignConfig.dart';
import '../../Utils/InternetConnectivity.dart';
import '../../Utils/apiParameters.dart';
import '../../Utils/apiUtils.dart';
import 'ErrorWidget/NoConErrorWidget.dart';

String? appVersion;

PackageInfo packageInfo = PackageInfo(
  appName: 'Unknown',
  packageName: 'Unknown',
  version: 'Unknown',
  buildNumber: 'Unknown',
  buildSignature: 'Unknown',
);

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return SplashScreenState();
  }
}

class SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 500));
  String _connectionStatus = 'unKnown';
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> connectivitySubscription;
  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      packageInfo = info;
    });
  }

  @override
  void initState() {
    adsInit();
    CheckInternet.initConnectivity().then((value) => setState(() {
          _connectionStatus = value;
        }));
    connectivitySubscription =
        _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      CheckInternet.updateConnectionStatus(result).then((value) => setState(() {
            _connectionStatus = value;
          }));
    });
    print("JWT:${AuthLocalDataSource.getJwtToken()}");
    startTime();
    _initPackageInfo();
    getSystemSetting();

    super.initState();
  }

  Future getSystemSetting() async {
    try {
      final body = {};
      final response = await post(Uri.parse(getSystemSettingUrl),
          body: body, headers: await ApiUtils.getHeaders());
      final responseJson = jsonDecode(response.body);
      print("get system setting***$responseJson");
      if (responseJson['error'] == true) {
        debugPrint(responseJson['message']);
      } else {
        final getData = responseJson['data'];
        AuthLocalDataSource().setAdsModeStatus(getData["ads_mode"]);
        AuthLocalDataSource().setVideoRecStatus(getData["screen_shot_recoder"]);
        AuthLocalDataSource().setCastVideoStatus(getData["video_cast"]);
        AuthLocalDataSource().setVideoPaymentStatus(getData["video_payment"]);

        /*   context
            .read<SettingProvider>()
            .changeVideoPayment(getData["video_payment"] ?? "");
        context
            .read<SettingProvider>()
            .changeVideoCast(getData["video_cast"] ?? "");
        context
            .read<SettingProvider>()
            .changeScreenRec(getData["screen_shot_recoder"] ?? "");
        context
            .read<SettingProvider>()
            .changeAdsMode(getData["ads_mode"] ?? "");*/
        AuthLocalDataSource()
            .setAndBannerId(getData["android_banner_id"] ?? "");
        AuthLocalDataSource().setIosBannerId(getData["ios_banner_id"] ?? "");
        AuthLocalDataSource()
            .setAndInterstial(getData["android_interstitial_id"] ?? "");
        AuthLocalDataSource()
            .setIosInterstial(getData["ios_interstitial_id"] ?? "");

        DesignConfig.getScreenRec == "1"
            ? DesignConfig.disableScreenShot()
            : null;
        DesignConfig.getAdsStatus == "1" ? adsLoad() : null;
        if (Platform.isIOS) {
          DesignConfig.IosVersion = getData['app_version_ios'];
          appVersion = DesignConfig.IosVersion;
        } else {
          DesignConfig.androidVersion = getData['app_version_android'];
          appVersion = DesignConfig.androidVersion;
        }
        // AuthLocalDataSource().setMaintainMode(getData['app_maintenance'] ?? "");
        AuthLocalDataSource().setForceUpdateMode(getData['force_update'] ?? "");
      }
    } catch (e) {
      print(e.toString());
    }
  }

  adsInit() async {
    await MobileAds.instance.initialize();
  }

  adsLoad() async {
    DesignConfig.createInterstitialAd();
  }

  Future getUserById() async {
    try {
      final body = {
        userIdApiKey: AuthLocalDataSource.getUserId(),
      };
      final response = await post(Uri.parse(getUserByIdUrl),
          body: body, headers: await ApiUtils.getHeaders());
      final responseJson = jsonDecode(response.body);
      print("===get user by Id ===$responseJson");
      if (responseJson['error'] == true) {
        if (mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil(
              '/login', (Route<dynamic> route) => false);
        }
      } else {
        final getData = responseJson['data'];

        context
            .read<SettingProvider>()
            .changeSetIsSubscribe(responseJson["data"]["is_subscribe"] ?? 0);
        context
            .read<SettingProvider>()
            .changeInAppCreateDate(responseJson["data"]["created_at"] ?? "");
        context
            .read<SettingProvider>()
            .changeInAppExDate(responseJson["data"]["inapp_exp_date"] ?? "");
        context.read<SettingProvider>().changeProfile(getData["profile"] ?? "");
      }
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  startTime() async {
    var duration = const Duration(seconds: 3);

    return Timer(duration, navigationPage);
  }

  void navigationPage() async {
    if (SettingsLocalDataSource.showIntroSlider()) {
      if (mounted) {
        await Navigator.of(context)
            .pushReplacementNamed(Routes.introSlider, arguments: false);
      }
    } else {
      if (AuthLocalDataSource.checkIsAuth()) {
        await getUserById();
        await Navigator.of(context)
            .pushReplacementNamed(Routes.home, arguments: false);
      } else {
        await Navigator.of(context).pushReplacementNamed(Routes.login);
      }
    }
  }

  Future<void> loadCat() async {
    getUserById();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: _connectionStatus == 'ConnectivityResult.none'
            ? NoConErrorWidget(
                onTap: () {
                  setState(() {
                    loadCat();
                  });
                },
              )
            : Container(
                width: double.infinity,
                height: double.infinity,
                alignment: Alignment.center,
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Opacity(
                        opacity: 0.20000000298023224,
                        child: Container(
                            width: 69,
                            height: 69,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                border: Border.all(
                                    color: const Color(0xff707070), width: 1),
                                gradient: const LinearGradient(
                                    begin: Alignment(-0.0475597158074379,
                                        -0.18908551335334778),
                                    end: Alignment(0.21307022869586945,
                                        1.5810182094573975),
                                    colors: [
                                      Color(0xff415fff),
                                      Color(0xff08dcff)
                                    ]))),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Opacity(
                        opacity: 0.15,
                        child: Container(
                            width: 80.61663818359375,
                            height: 222.38592529296875,
                            decoration: BoxDecoration(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(50)),
                                //  shape: BoxShape.circle,
                                border: Border.all(
                                    color: const Color(0xff707070), width: 1),
                                gradient: const LinearGradient(
                                    begin: Alignment(-0.0475597158074379,
                                        -0.18908551335334778),
                                    end: Alignment(0.21307022869586945,
                                        1.5810182094573975),
                                    colors: [
                                      Color(0xff415fff),
                                      Color(0xff08dcff)
                                    ]))),
                      ),
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: Opacity(
                        opacity: 0.30000000298023224,
                        child: Container(
                            width: 69,
                            height: 69,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                border: Border.all(
                                    color: const Color(0xff707070), width: 1),
                                gradient: const LinearGradient(
                                    begin: Alignment(-0.0475597158074379,
                                        -0.18908551335334778),
                                    end: Alignment(0.21307022869586945,
                                        1.5810182094573975),
                                    colors: [
                                      Color(0xff415fff),
                                      Color(0xff08dcff)
                                    ]))),
                      ),
                    ),
                    BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                            width: double.infinity,
                            height: double.infinity,
                            color: DesignConfig.isDark
                                ? const Color(0xff0c2e5b).withOpacity(0.5)
                                : Colors.white38,
                            alignment: Alignment.center,
                            child: Align(
                              alignment: Alignment.center,
                              child: SlideAnimation(
                                  position: 10,
                                  itemCount: 20,
                                  slideDirection: SlideDirection.fromTop,
                                  animationController: _animationController,
                                  child: Padding(
                                    padding: const EdgeInsets.all(50.0),
                                    child: SvgPicture.asset(
                                      DesignConfig.getImagePath(
                                          DesignConfig.isDark
                                              ? "logo_01 (1).svg"
                                              : "logo_01.svg"),
                                    ),
                                  )),
                            ))),
                    SlideAnimation(
                        position: 10,
                        itemCount: 20,
                        slideDirection: SlideDirection.fromLeft,
                        animationController: _animationController,
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: SvgPicture.asset(
                              DesignConfig.getIconPath(DesignConfig.isDark
                                  ? "Wrteam_Logodark.svg"
                                  : "Wrteam_Logolight.svg"),
                              height: 30,
                            ),
                          ),
                        ))
                  ],
                ),
              ));
  }
}
