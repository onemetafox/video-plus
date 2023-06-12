import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../LocalDataStore/AuthLocalDataStore.dart';
import '../../Utils/Constant.dart';
import '../../Utils/DesignConfig.dart';

//banner Ads widget
class AdsWidget extends StatefulWidget {
  const AdsWidget({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return AdsWidgetState();
  }
}

class AdsWidgetState extends State<AdsWidget> {
  AdManagerBannerAd? adManagerBannerAd;
  bool adManagerBannerAdIsLoaded = false;
  AdSize? adSize;
  late Orientation currentOrientation;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (DesignConfig.getAdsStatus == adsStatusVal) {
      currentOrientation = MediaQuery.of(context).orientation;

      adManagerBannerAd = AdManagerBannerAd(
        adUnitId: Platform.isAndroid
            ? AuthLocalDataSource.getAndBanner()
            : AuthLocalDataSource.getIosBanner(),
        request: const AdManagerAdRequest(nonPersonalizedAds: true),
        sizes: <AdSize>[AdSize.largeBanner],
        listener: AdManagerBannerAdListener(
          onAdLoaded: (Ad ad) {
            debugPrint('$AdManagerBannerAd loaded.');
            setState(() {
              adManagerBannerAdIsLoaded = true;
            });
          },
          onAdFailedToLoad: (Ad ad, LoadAdError error) {
            debugPrint('$AdManagerBannerAd failedToLoad: $error');
            ad.dispose();
          },
          onAdOpened: (Ad ad) => debugPrint('$AdManagerBannerAd onAdOpened.'),
          onAdClosed: (Ad ad) => debugPrint('$AdManagerBannerAd onAdClosed.'),
        ),
      )..load();
    }
  }

  @override
  void dispose() {
    super.dispose();
    adManagerBannerAd?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width,
        height: 115,
        margin: const EdgeInsets.only(top: 5, bottom: 5, left: 15, right: 15),
        child: AdWidget(
          ad: adManagerBannerAd!,
        ));
  }
}
