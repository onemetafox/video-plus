import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:videoPlus/Ui/Screens/SaveVideo/SaveVideoScreen.dart';
import 'package:videoPlus/Ui/Screens/Setting/AboutUsScreen.dart';
import 'package:videoPlus/Ui/Screens/Setting/BuyMemScreen.dart';
import 'package:videoPlus/Ui/Screens/Video/VideoScreen.dart';

import '../Ui/Screens/CategoryPlayList/CategoryScreen.dart';
import '../Ui/Screens/CategoryPlayList/CategoryViewAllScreen.dart';
import '../Ui/Screens/FreeAndPaid/FreeAndPaidAllScreen.dart';
import '../Ui/Screens/IntroSliderScreen.dart';
import '../Ui/Screens/SaveVideo/SaveVideoDetail.dart';
import '../Ui/Screens/SearchScreen.dart';
import '../Ui/Screens/SplashScreen.dart';
import '../Ui/Screens/VideoHistory/historyScreen.dart';
import '../Ui/Screens/VideoPlayArea/VideoPlayAreaScreen.dart';
import '../Ui/Screens/auth/LoginScreen.dart';
import '../Ui/Screens/auth/SignUpScreen.dart';
import '../Ui/Screens/home/MainScreen.dart';

class Routes {
  static const String home = "/";
  static const splash = 'splash';
  static const login = '/login';
  static const signUp = "signUp";
  static const introSlider = "introSlider";
  static const search = "search";
  static const categoryPlayList = "playList";
  static const saveVideoDetail = "saveVideoDetail";
  static const topNewList = "topNewList";
  static const topNewListDetail = "topNewListDetail";
  static const savedVideos = "savedVideos";
  static const video = "video";
  static const buyMembership = "buyMembership";
  static const aboutUs = "aboutUs";
  static const categoryAll = "categoryAll";
  static const historyAll = "historyAll";
  static const freeAndPaidVideo = "FreeAndPaidVideo";

  static String currentRoute = splash;
  static Route<dynamic> onGenerateRoute(RouteSettings routeSettings) {
    currentRoute = routeSettings.name ?? "";
    debugPrint("Current Route is $currentRoute");
    switch (routeSettings.name) {
      case splash:
        return CupertinoPageRoute(builder: (context) => const SplashScreen());
      case introSlider:
        return CupertinoPageRoute(
            builder: (context) => const IntroSliderScreen());
      case home:
        return CupertinoPageRoute(builder: (context) => const MainScreen());
      case login:
        return CupertinoPageRoute(builder: (context) => const LoginScreen());
      case signUp:
        return CupertinoPageRoute(builder: (context) => const SignUpScreen());
      case search:
        return CupertinoPageRoute(builder: (context) => const SearchScreen());
      case categoryPlayList:
        return CategoryScreen.route(routeSettings);
      case saveVideoDetail:
        return SaveVideoDetailScreen.route(routeSettings);
      case topNewList:
        return VideoPlayAreaScreen.route(routeSettings);
      case savedVideos:
        return CupertinoPageRoute(
            builder: (context) => const SaveVideoScreen());
      case video:
        return CupertinoPageRoute(builder: (context) => const VideoScreen());
      case buyMembership:
        return CupertinoPageRoute(builder: (context) => const BuyMemScreen());
      case aboutUs:
        return AboutUsScreen.route(routeSettings);
      case categoryAll:
        return CupertinoPageRoute(
            builder: (context) => const CategoryViewAllScreen());
      case historyAll:
        return HistoryScreen.route(routeSettings);
      case freeAndPaidVideo:
        return FreeAndPaidAllScreen.route(routeSettings);
      default:
        return CupertinoPageRoute(builder: (context) => const Scaffold());
    }
  }
}
