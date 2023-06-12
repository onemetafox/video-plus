import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:videoPlus/LocalDataStore/AuthLocalDataStore.dart';
import 'package:videoPlus/Ui/Screens/home/HomePageScreen.dart';
import 'package:videoPlus/Utils/DesignConfig.dart';

import '../../../BottomBarHelper/dropNavigation.dart';
import '../../../LocalDataStore/SettingLocalDataSource.dart';
import '../../../Utils/AppUndermaintanDialog.dart';
import '../../../Utils/ColorRes.dart';
import '../../../Utils/InternetConnectivity.dart';
import '../../../Utils/StringRes.dart';
import '../ErrorWidget/NoConErrorWidget.dart';
import '../Notification/NotificationScreen.dart';
import '../Setting/SettingScreen.dart';
import '../SplashScreen.dart';
import '../Video/VideoScreen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return MainScreenState();
  }
}

class MainScreenState extends State<MainScreen> {
  // late PageController pageController;
  int selectedIndex = 0;

  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> connectivitySubscription;
  DateTime oldTime = DateTime.now();
  DateTime newTime = DateTime.now();

  @override
  void initState() {
    CheckInternet.initConnectivity().then((value) => setState(() {
          DesignConfig.connectionStatus = value;
        }));
    connectivitySubscription =
        _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      CheckInternet.updateConnectionStatus(result).then((value) => setState(() {
            DesignConfig.connectionStatus = value;
          }));
    });
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (AuthLocalDataSource.getMaintain() == "1") {
        showDialog(
            context: context,
            builder: (_) => const AppUnderMaintenanceDialog());
      }
      if (AuthLocalDataSource.getForceUpdate() == "1") {
        if (appVersion != packageInfo.version) {
          DesignConfig.forceUpdateDialog(context);
        }
      }
    });
    //  pageController = PageController(initialPage: selectedIndex);

    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    //  pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DesignConfig.connectionStatus == 'ConnectivityResult.none'
        ? NoConErrorWidget(
            onTap: () {
              setState(() {
                CheckInternet.initConnectivity().then((value) => setState(() {
                      DesignConfig.connectionStatus = value;
                    }));
                connectivitySubscription = _connectivity.onConnectivityChanged
                    .listen((ConnectivityResult result) {
                  CheckInternet.updateConnectionStatus(result)
                      .then((value) => setState(() {
                            DesignConfig.connectionStatus = value;
                          }));
                });
              });
            },
          )
        : WillPopScope(
            onWillPop: () async {
              if (selectedIndex != 0) {
                setState(() {
                  selectedIndex = 0;
                  // pageController.jumpTo(0);
                });
                return Future.value(false);
              }
              newTime = DateTime.now();
              int difference = newTime.difference(oldTime).inMilliseconds;
              oldTime = newTime;
              if (difference < 1000) {
                return true;
              } else {
                DesignConfig.setSnackbar(StringRes.msgExit, context, false);
                return false;
              }
            },
            child: Scaffold(
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                extendBody: true,
                bottomNavigationBar: Container(
                  decoration: const BoxDecoration(
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Colors.black54,
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: DropNavigation(
                    backgroundColor: SettingsLocalDataSource().theme() ==
                            StringRes.darkThemeKey
                        ? darkButtonDisable
                        : Colors.white,
                    waterDropColor: Theme.of(context).primaryColor,
                    onItemSelected: (index) {
                      setState(() {
                        selectedIndex = index;
                        //  DesignConfig.showInterstitialAd();
                      });
                      /*pageController.animateToPage(selectedIndex,
                          duration: const Duration(milliseconds: 50),
                          curve: Curves.easeOutQuad);*/
                    },
                    selectedIndex: selectedIndex,
                    barItems: [
                      BarItem(
                        filledIcon: SvgPicture.asset(
                          DesignConfig.getIconPath("home.svg"),
                          color: Theme.of(context).primaryColor,
                        ),
                        title: Text(StringRes.home,
                            style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.w700,
                                fontStyle: FontStyle.normal,
                                fontSize: 12.0),
                            textAlign: TextAlign.center),
                        outlinedIcon: SvgPicture.asset(
                            DesignConfig.getIconPath("home (1).svg"),
                            color: Theme.of(context).secondaryHeaderColor),
                      ),
                      BarItem(
                          filledIcon: SvgPicture.asset(
                            DesignConfig.getIconPath("videos.svg"),
                            color: Theme.of(context).primaryColor,
                          ),
                          title: Text(StringRes.video,
                              style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.w700,
                                  fontStyle: FontStyle.normal,
                                  fontSize: 12.0),
                              textAlign: TextAlign.center),
                          outlinedIcon: SvgPicture.asset(
                            DesignConfig.getIconPath("videos (1).svg"),
                            color: Theme.of(context).secondaryHeaderColor,
                          )),
                      BarItem(
                        filledIcon: SvgPicture.asset(
                          DesignConfig.getIconPath("notofication.svg"),
                          color: Theme.of(context).primaryColor,
                        ),
                        title: Text(StringRes.notification,
                            style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.w700,
                                fontStyle: FontStyle.normal,
                                fontSize: 12.0),
                            textAlign: TextAlign.center),
                        outlinedIcon: SvgPicture.asset(
                            DesignConfig.getIconPath("notification (1).svg"),
                            color: Theme.of(context).secondaryHeaderColor),
                      ),
                      BarItem(
                        filledIcon: SvgPicture.asset(
                          DesignConfig.getIconPath("setting.svg"),
                          color: Theme.of(context).primaryColor,
                        ),
                        title: Text(StringRes.setting,
                            style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.w700,
                                fontStyle: FontStyle.normal,
                                fontSize: 12.0),
                            textAlign: TextAlign.center),
                        outlinedIcon: SvgPicture.asset(
                            DesignConfig.getIconPath("setting (1).svg"),
                            color: Theme.of(context).secondaryHeaderColor),
                      ),
                    ],
                  ),
                ),
                body: //PageView(
                    IndexedStack(
                        index: selectedIndex,
                        //   physics: const NeverScrollableScrollPhysics(),
                        //  controller: pageController,
                        children: const <Widget>[
                      HomePageScreen(),
                      VideoScreen(),
                      NotificationScreen(),
                      SettingScreen(),
                    ])));
  }
}
