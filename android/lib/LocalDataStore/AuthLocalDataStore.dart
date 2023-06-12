import 'package:hive/hive.dart';

import '../Utils/Constant.dart';

class AuthLocalDataSource {
  static String getJwtToken() {
    return Hive.box(authBox).get(jwtTokenKey, defaultValue: "");
  }

  Future<void> setJwtToken(String jwtToken) async {
    print("JwtToken:$jwtToken");
    await Hive.box(authBox).put(jwtTokenKey, jwtToken);
  }

  static bool checkIsAuth() {
    return Hive.box(authBox).get(isLoginKey, defaultValue: false);
  }

  static String getAuthType() {
    return Hive.box(authBox).get(authTypeKey, defaultValue: "");
  }

  static String getUserFirebaseId() {
    return Hive.box(authBox).get(firebaseIdBoxKey, defaultValue: "");
  }

  static String getUserId() {
    return Hive.box(authBox).get(userIdKey, defaultValue: "");
  }

  static String getUserName() {
    return Hive.box(authBox).get(userNameKey, defaultValue: "");
  }

  static String getEmail() {
    return Hive.box(authBox).get(emailKey, defaultValue: "");
  }

  static String getProfile() {
    return Hive.box(authBox).get(profileKey, defaultValue: "");
  }

  static String getMobile() {
    return Hive.box(authBox).get(mobileKey, defaultValue: "");
  }

  static String getFcmId() {
    return Hive.box(authBox).get(fcmKey, defaultValue: "");
  }

  static int getIsSubscribe() {
    return Hive.box(authBox).get(isSubscribeKey, defaultValue: "");
  }

  static String getInAppExpDate() {
    return Hive.box(authBox).get(inAppExpDateKey, defaultValue: "");
  }

  static String getInAppCreateDate() {
    return Hive.box(authBox).get(inAppCreateDateKey, defaultValue: "");
  }

  static String getVideoPaymentStatus() {
    return Hive.box(authBox).get(payStatusKey, defaultValue: "");
  }

  static String getVideoCastStatus() {
    return Hive.box(authBox).get(castStatusKey, defaultValue: "");
  }

  static String getScreenRecStatus() {
    return Hive.box(authBox).get(screenRecKey, defaultValue: "");
  }

  static String getAdsModeStatus() {
    return Hive.box(authBox).get(adsModeKey, defaultValue: "");
  }

  static String getAndBanner() {
    return Hive.box(authBox).get(andBannerKey, defaultValue: "");
  }

  static String getIosBanner() {
    return Hive.box(authBox).get(iosBannerKey, defaultValue: "");
  }

  static String getAndInter() {
    return Hive.box(authBox).get(andInterstitialKey, defaultValue: "");
  }

  static String getIosInter() {
    return Hive.box(authBox).get(iosInterstitialKey, defaultValue: "");
  }

  static String getMaintain() {
    return Hive.box(authBox).get(maintainKey, defaultValue: "");
  }

  static String getForceUpdate() {
    return Hive.box(authBox).get(forceUpdateKey, defaultValue: "");
  }

  Future<void> setMaintainMode(String? maintain) async {
    Hive.box(authBox).put(maintainKey, maintain);
  }

  Future<void> setForceUpdateMode(String? forceUpdate) async {
    Hive.box(authBox).put(forceUpdateKey, forceUpdate);
  }

  Future<void> setUserFirebaseId(String? firebaseId) async {
    Hive.box(authBox).put(firebaseIdBoxKey, firebaseId);
  }

  Future<void> setAndBannerId(String? bannerId) async {
    Hive.box(authBox).put(andBannerKey, bannerId);
  }

  Future<void> setIosBannerId(String? bannerIdIos) async {
    Hive.box(authBox).put(iosBannerKey, bannerIdIos);
  }

  Future<void> setAndInterstial(String? Interstial) async {
    Hive.box(authBox).put(andInterstitialKey, Interstial);
  }

  Future<void> setIosInterstial(String? InterstialIos) async {
    Hive.box(authBox).put(iosInterstitialKey, InterstialIos);
  }

  Future<void> setVideoPaymentStatus(String? payStatus) async {
    Hive.box(authBox).put(payStatusKey, payStatus);
  }

  Future<void> setCastVideoStatus(String? castStatus) async {
    Hive.box(authBox).put(castStatusKey, castStatus);
  }

  Future<void> setVideoRecStatus(String? recStatus) async {
    Hive.box(authBox).put(screenRecKey, recStatus);
  }

  Future<void> setAdsModeStatus(String? adsStatus) async {
    Hive.box(authBox).put(adsModeKey, adsStatus);
  }

  Future<void> setAuthType(String? authType) async {
    Hive.box(authBox).put(authTypeKey, authType);
  }

  Future<void> changeAuthStatus(bool? authStatus) async {
    Hive.box(authBox).put(isLoginKey, authStatus);
  }

  Future<void> changeGuestLoginStatus(bool? status) async {
    Hive.box(authBox).put(isGuestLoginKey, status);
  }

  Future<void> setUserId(String? userId) async {
    Hive.box(authBox).put(userIdKey, userId);
  }

  Future<void> setUserName(String? userName) async {
    Hive.box(authBox).put(userNameKey, userName);
  }

  Future<void> setEmail(String? email) async {
    Hive.box(authBox).put(emailKey, email);
  }

  Future<void> setProfile(String? profile) async {
    Hive.box(authBox).put(profileKey, profile);
  }

  Future<void> setMobile(String? mobile) async {
    Hive.box(authBox).put(mobileKey, mobile);
  }

  Future<void> setFcmId(String? fcmId) async {
    Hive.box(authBox).put(fcmKey, fcmId);
  }

  Future<void> setIsSubscribe(int? id) async {
    Hive.box(authBox).put(isSubscribeKey, id);
  }

  Future<void> setInAppExpDate(String? expId) async {
    Hive.box(authBox).put(inAppExpDateKey, expId);
  }

  Future<void> setInAppCreateDate(String? creId) async {
    Hive.box(authBox).put(inAppCreateDateKey, creId);
  }
}
