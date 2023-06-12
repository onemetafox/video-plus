import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:videoPlus/Utils/DesignConfig.dart';

import '../../../Provider/ThemeProvider.dart';
import '../../../Utils/StringRes.dart';

class NoConErrorWidget extends StatelessWidget {
  final VoidCallback onTap;
  const NoConErrorWidget({Key? key, required this.onTap}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: Container(
            margin: const EdgeInsets.all(40),
            height: 50,
            width: 270,
            child: DesignConfig.gradientButton(
              isBlack: false,
              align: Alignment.bottomCenter,
              isLoading: false,
              width: 270,
              height: 50,
              onPress: onTap,
              name: StringRes.tryAgain,
            )
            /*ElevatedButton(
            onPressed: onTap,
            child: Text(
              StringRes.tryAgain,
              style: const TextStyle(
                  color: const Color(0xffffffff),
                  fontWeight: FontWeight.w700,
                  fontStyle: FontStyle.normal,
                  fontSize: 18.0),
            ),
            style: ElevatedButton.styleFrom(
              elevation: 0,
              minimumSize: const Size(270, 50),
              primary:
                  SettingsLocalDataSource().theme() == StringRes.darkThemeKey
                      ? Color(0xff272727)
                      : Color(0xff181818),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.0),
              ),
            ),
          ),*/
            ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SvgPicture.asset(
                DesignConfig.getIconPath(
                    Provider.of<ThemeNotifier>(context).getThemeMode() ==
                            ThemeMode.dark
                        ? "no_internet_dark.svg"
                        : "no_internet.svg"),
                height: MediaQuery.of(context).size.height * .3,
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * .04,
              ),
              // No Connection
              Text("No Connection",
                  style: TextStyle(
                      color: Theme.of(context).secondaryHeaderColor,
                      fontWeight: FontWeight.w700,
                      decoration: TextDecoration.none,
                      fontStyle: FontStyle.normal,
                      fontSize: 22.0),
                  textAlign: TextAlign.center),
              SizedBox(
                height: MediaQuery.of(context).size.height * .016,
              ),
              // You are offline. Check your Connection  and try again
              Text("You are offline. Check your Connection and try again ",
                  style: TextStyle(
                      color: Theme.of(context).secondaryHeaderColor,
                      fontWeight: FontWeight.w400,
                      decoration: TextDecoration.none,
                      fontStyle: FontStyle.normal,
                      fontSize: 14.0),
                  textAlign: TextAlign.center),
            ],
          ),
        ));
  }
}
