import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:videoPlus/LocalDataStore/AuthLocalDataStore.dart';
import 'package:videoPlus/Utils/StringRes.dart';
import 'package:videoPlus/Utils/convertUrlHelper.dart';

import '../LocalDataStore/SettingLocalDataSource.dart';
import '../Ui/Screens/SplashScreen.dart';
import '../model/urlAndResolutionModel.dart';
import 'Constant.dart';

// common list for all type video
List<UrlAndResolutionModel> commonUrlList = [];
List<UrlAndResolutionModel> autoPlayOffListUrl = [];

class DesignConfig {
  static bool isDark = SettingsLocalDataSource.getThemeSwitch();
  static bool isScroll = false;
  static String connectionStatus = 'unKnown';
  static int maxFailedLoadAttempts = 3;
  static InterstitialAd? _interstitialAd;
  static int _numInterstitialLoadAttempts = 0;
  static String getAdsStatus = AuthLocalDataSource.getAdsModeStatus();
  static String getScreenRec = AuthLocalDataSource.getScreenRecStatus();
  static String getPaymentMode = AuthLocalDataSource.getVideoPaymentStatus();
  static String getCastMode = AuthLocalDataSource.getVideoCastStatus();
  static var androidVersion, IosVersion;
  static VideoApis? quality;

  static void setSnackbar(String msg, BuildContext context, bool showAction,
      {Function? onPressedAction, Duration? duration}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg,
          textAlign: showAction ? TextAlign.start : TextAlign.center,
          style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16.0)),
      behavior: SnackBarBehavior.floating,
      duration: duration ?? const Duration(seconds: 2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      backgroundColor: Theme.of(context).primaryColor,
      action: showAction
          ? SnackBarAction(
              label: "Retry",
              onPressed: onPressedAction as void Function(),
              textColor: Theme.of(context).backgroundColor,
            )
          : null,
      elevation: 2.0,
    ));
  }

  static getThumbnail({required String videoId, required int type}) {
    return type == viemoVideoType
        ? "https://vumbnail.com/$videoId.jpg"
        : type == youtubeVideoType
            ? 'https://img.youtube.com/vi/$videoId/sddefault.jpg'
            : "";
  }

  static onTapLoader(BuildContext context) {
    return Container(
        height: MediaQuery.of(context).size.height * .11,
        margin: const EdgeInsets.only(top: 5, bottom: 5, left: 15, right: 15),
        child: Card(
          color: Theme.of(context).colorScheme.primary,
          shadowColor: Colors.black12,
          margin: EdgeInsets.zero,
          elevation: 20,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).primaryColor,
            ),
          ),
        ));
  }

  static Future<void> disableScreenShot() async {
    await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
  }

  static OutlineInputBorder textFieldBorder({required BuildContext context}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide:
          BorderSide(color: Theme.of(context).colorScheme.onPrimary, width: 1),
    );
  }

  static String getImagePath(String imageName) {
    return "assets/images/$imageName";
  }

  static String getIconPath(String iconName) {
    return "assets/images/icon/$iconName";
  }

  static backButton({required VoidCallback onPress}) {
    return InkWell(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: onPress,
        child: SvgPicture.asset(
          SettingsLocalDataSource().theme() == StringRes.darkThemeKey
              ? DesignConfig.getIconPath("dark_back_button.svg")
              : DesignConfig.getIconPath("back_button.svg"),
        ));
  }

  static gradientButton(
      {required VoidCallback onPress,
      required String name,
      Alignment? align,
      required double width,
      required double height,
      required bool isBlack,
      bool? isLoading}) {
    return Align(
      alignment: align ?? Alignment.center,
      child: InkWell(
        onTap: onPress,
        onDoubleTap: () {},
        borderRadius: const BorderRadius.all(Radius.circular(25)),
        child: Container(
          width: width,
          height: height,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(25)),
              border: Border.all(color: const Color(0x00000000), width: 1),
              gradient: const LinearGradient(
                  begin: Alignment(-0.022495072335004807, 1),
                  end: Alignment(1.1026651859283447, -0.5471386909484863),
                  colors: [Color(0xff415fff), Color(0xff08dcff)])),
          child: isLoading ?? false
              ? const CircularProgressIndicator(
                  color: Color(0xffffffff),
                )
              : Text(name,
                  style: const TextStyle(
                      color: Color(0xffffffff),
                      fontWeight: FontWeight.w700,
                      fontStyle: FontStyle.normal,
                      fontSize: 16.0),
                  textAlign: TextAlign.center),
        ),
      ),
    );
  }

  static iconButton(
      {required dynamic size,
      required Color color,
      required String icon,
      required VoidCallback onPress,
      required Color iconColor,
      double? top,
      double? bottom,
      double? left,
      double? right}) {
    return InkWell(
      onTap: onPress,
      child: Container(
        width: size.width * .1,
        height: size.height * .05,
        margin: EdgeInsets.only(
            top: top ?? 0,
            left: left ?? 0,
            bottom: bottom ?? 0,
            right: right ?? 0),
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: SvgPicture.asset(
            DesignConfig.getIconPath(icon),
            color: iconColor,
          ),
        ),
      ),
    );
  }

// youtube vimeo and external link generate url  and resolution/qulity here
  static Future<UrlAndResolutionModel?> youtubeCheck(
      {required String videoUrl, required int type}) async {
    Map<String, String> resolutionsMap = {};
    UrlAndResolutionModel? data = UrlAndResolutionModel();
    quality = VideoApis(videoUrl, type);
    if (type == externalVideoType) {
      data.url = videoUrl;
      data.resolutionData = {};
      return data;
    } else {
      await quality!.getYoutubeViemo().then((value) {
        data.url = value[value.lastKey()];
        value.keys.forEach((key) {
          String processedKey = key.split(" ")[0];
          resolutionsMap[processedKey] = value[key];
          data.resolutionData = resolutionsMap;
        });
      });
      return data;
    }
  }

  static noDataFound(BuildContext context) {
    return Center(
      child: Text(
        "No data found!!",
        style: TextStyle(color: Theme.of(context).primaryColor),
      ),
    );
  }

  static String timeAgo(DateTime d) {
    Duration diff = DateTime.now().difference(d);
    if (diff.inDays > 365) {
      return "${(diff.inDays / 365).floor()} ${(diff.inDays / 365).floor() == 1 ? "year" : "years"} ago";
    }
    if (diff.inDays > 30) {
      return "${(diff.inDays / 30).floor()} ${(diff.inDays / 30).floor() == 1 ? "month" : "months"} ago";
    }
    if (diff.inDays > 7) {
      return "${(diff.inDays / 7).floor()} ${(diff.inDays / 7).floor() == 1 ? "week" : "weeks"} ago";
    }
    if (diff.inDays > 0) {
      return "${diff.inDays} ${diff.inDays == 1 ? "day" : "days"} ago";
    }
    if (diff.inHours > 0) {
      return "${diff.inHours} ${diff.inHours == 1 ? "hour" : "hours"} ago";
    }
    if (diff.inMinutes > 0) {
      return "${diff.inMinutes} ${diff.inMinutes == 1 ? "minute" : "minutes"} ago";
    }
    return "just now";
  }

  static forceUpdateDialog(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: AlertDialog(
          title: Text(StringRes.title),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                    'Update your version ${packageInfo.version} to $appVersion.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                StringRes.update,
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
              onPressed: () async {
                String url = Platform.isIOS ? iosLink : androidLink;
                if (url.isEmpty) {
                  DesignConfig.setSnackbar(
                      StringRes.msgFailtoGetUrl, context, false);
                  return;
                }
                bool canLaunchUrl = await canLaunchUrlString(url);
                if (canLaunchUrl) {
                  launchUrlString(url);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  static createInterstitialAd() {
    InterstitialAd.load(
        adUnitId: Platform.isAndroid
            ? AuthLocalDataSource.getAndInter()
            : AuthLocalDataSource.getIosInter(),
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            debugPrint('$ad loaded');
            _interstitialAd = ad;
            _numInterstitialLoadAttempts = 0;
            _interstitialAd!.setImmersiveMode(true);
          },
          onAdFailedToLoad: (LoadAdError error) {
            debugPrint('InterstitialAd failed to load: $error.');
            _numInterstitialLoadAttempts += 1;
            _interstitialAd = null;
            if (_numInterstitialLoadAttempts < maxFailedLoadAttempts) {
              createInterstitialAd();
            }
          },
        ));
  }

  static showInterstitialAd() {
    if (_interstitialAd == null) {
      debugPrint('Warning: attempt to show interstitial before loaded.');
      return;
    }
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) =>
          debugPrint('ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        debugPrint('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        createInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        debugPrint('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        createInterstitialAd();
      },
    );
    _interstitialAd!.show();
    _interstitialAd = null;
  }
}
