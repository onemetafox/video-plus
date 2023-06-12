import 'dart:async';

import 'package:flutter/material.dart';
import 'package:videoPlus/Utils/Constant.dart';
import 'package:videoPlus/Utils/StringRes.dart';

import '../../App/Routes.dart';
import '../../LocalDataStore/SettingLocalDataSource.dart';
import '../../Utils/DesignConfig.dart';
import '../../Utils/SlideAnimation.dart';

class IntroSliderScreen extends StatefulWidget {
  const IntroSliderScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return IntroSliderScreenState();
  }
}

class IntroSliderScreenState extends State<IntroSliderScreen>
    with TickerProviderStateMixin {
  bool hideIcon = false;
  late AnimationController timerAnimationController;
  AnimationController? _animationController;
  int currentIndex = 0;
  int _pos = 0;
  late Timer _timer;
  List<String> imageList = [
    "assets/images/splash_img_01.jpg",
    "assets/images/splash_img_02.jpg",
    "assets/images/splash_img_03.jpg"
  ];
  @override
  void initState() {
    timerAnimationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));
    timerAnimationController.forward();
    _timer = Timer.periodic(const Duration(seconds: 2), (Timer t) {
      setState(() {
        _pos = (_pos + 1) % imageList.length;
        currentIndex = _pos;
        if (currentIndex == (imageList.length - 1)) {
          _timer.cancel();
        }
      });
    });
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));
    super.initState();
  }

  @override
  void dispose() {
    timerAnimationController.dispose();
    _animationController!.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: Container(
          height: size.height,
          width: size.width,
          margin:
              EdgeInsets.only(left: size.width * .05, right: size.width * .05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: size.height * .05,
              ),
              Text(StringRes.welcome,
                  style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w700,
                      fontStyle: FontStyle.normal,
                      fontSize: 30.0),
                  textAlign: TextAlign.start),
              indicatorLine(),
              SizedBox(
                height: size.height * .015,
              ),
              SlideAnimation(
                  position: 10,
                  itemCount: 20,
                  slideDirection: SlideDirection.fromLeft,
                  animationController: _animationController,
                  child: Text(StringRes.introText,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                          fontWeight: FontWeight.w400,
                          fontStyle: FontStyle.normal,
                          fontSize: 16.0),
                      textAlign: TextAlign.left)),
              SizedBox(
                height: size.height * .04,
              ),
              SlideAnimation(
                  position: 10,
                  itemCount: 20,
                  slideDirection: SlideDirection.fromRight,
                  animationController: _animationController,
                  child: Container(
                    width: size.width * .9,
                    height: size.height * .5,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(borderRadius)),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(borderRadius),
                      child: Image.asset(
                        imageList[_pos],
                        fit: BoxFit.fill,
                        gaplessPlayback: true,
                      ),
                    ),
                  )),
              SizedBox(
                height: size.height * .05,
              ),
              Align(
                  alignment: Alignment.center,
                  child: DesignConfig.gradientButton(
                    isBlack: false,
                    isLoading: false,
                    width: 270,
                    height: 50,
                    onPress: () async {
                      await SettingsLocalDataSource().setShowIntroSlider(false);
                      await Navigator.of(context)
                          .pushReplacementNamed(Routes.login, arguments: false);
                    },
                    name: StringRes.getStarted,
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget indicatorLine() {
    return Stack(
      children: [
        Container(
          alignment: Alignment.topRight,
          height: 7.0,
          width: MediaQuery.of(context).size.width * .35,
        ),
        AnimatedBuilder(
          animation: timerAnimationController,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              alignment: Alignment.topRight,
              height: 7.0,
              width: currentIndex == 0
                  ? MediaQuery.of(context).size.width * .1
                  : currentIndex == 1
                      ? MediaQuery.of(context).size.width * .2
                      : MediaQuery.of(context).size.width * .35,
            );
          },
        ),
      ],
    );
  }
}
