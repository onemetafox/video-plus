import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';

const String appName = "Video plus";
const String packageName = "com.wrteam.videoPlus";
const String androidLink =
    'https://play.google.com/store/apps/details?id=com.wrteam.videoPlus';
const String iosLink = 'https://apps.apple.com/id1627194695';
const String iosAppId = "1627194695";

const String authBox = "auth";
const String userDetailsBox = "userdetails";
const String initialCountryCode = "IN";

/*//all ads is
const String bannerAdsAndroidId = 'ca-app-pub-3940256099942544/6300978111';
const String bannerAdsIos = 'ca-app-pub-3940256099942544/2934735716';
const String nativeAdsAndroid = 'ca-app-pub-3940256099942544/2247696110';
const String nativeAdsIos = 'ca-app-pub-3940256099942544/3986624511';
const String interstitialAdsAndroid = 'ca-app-pub-3940256099942544/1033173712';
const String interstitialAdsIos = 'ca-app-pub-3940256099942544/4411468910';
const String rewardedAdsAndroid = 'ca-app-pub-3940256099942544/5224354917';
const String rewardedAdsIos = 'ca-app-pub-3940256099942544/1712485313';*/

String ISDARK = "";
//authBox keys
const String isLoginKey = "isLogin";
const String isGuestLoginKey = "isGuestLogin";
const String jwtTokenKey = "jwtToken";
const String firebaseIdBoxKey = "firebaseId";
const String authTypeKey = "authType";
const String userIdKey = "userId";
const String userNameKey = "userName";
const String emailKey = "email";
const String profileKey = "profile";
const String mobileKey = "mobile";
const String fcmKey = "fcm";
const String isSubscribeKey = "isSubscribe";
const String inAppExpDateKey = "inAppExpDate";
const String inAppCreateDateKey = "inAppCreateDate";
const String payStatusKey = "payStatusId";
const String castStatusKey = "castStatusId";
const String screenRecKey = "screenRecId";
const String adsModeKey = "adsId";
const String andBannerKey = "andBanner";
const String iosBannerKey = "iosBanner";
const String andInterstitialKey = "andInterstitial";
const String iosInterstitialKey = "iosInterstitial";
const String maintainKey = "maintain";
const String forceUpdateKey = "forceUpdate";

//Setting box
const String settingsBox = "settings";
const String showIntroSliderKey = "showIntroSlider";
const String showThemeSwitchKey = "Theme";
const String settingsThemeKey = "theme";
const String lightThemeKey = "lightTheme";

// APi URL constant
const String databaseUrl =
    /*"http://videos.thewrteam.in/api/"*/
    "https://videos.wrteam.in/api/";

const int otpTimeOutSeconds = 60;
const String defaultError = "something went wrong!!";

const String deepLinkUrlPrefix = 'https://videoplus.page.link';
const String deepLinkName = 'Videoplus';

final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
final GoogleSignIn googleSignIn = GoogleSignIn();
final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
final FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;
const double borderRadius = 10;

// all status key
const String adsStatusVal = "1";
const String paymentStatusVal = "1";
const String paymentModeStatusVal = "0";
const int subscribeStatusVal = 0;
const int viemoVideoType = 2;
const int externalVideoType = 3;
const int youtubeVideoType = 1;

// type text
const String categoryKey = "category";
const String freeKey = "free";
const String paidKey = "paid";
const String videoKey = "video";
const String allKey = "all";

String? getFormatedDate(date) {
  var inputFormat = DateFormat('yyyy-MM-dd');
  var inputDate = inputFormat.parse(date);
  var outputFormat = DateFormat('dd/MM/yyyy');
  return outputFormat.format(inputDate).toString();
}
