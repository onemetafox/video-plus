import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:videoPlus/Utils/DesignConfig.dart';

import '../../../Provider/ThemeProvider.dart';

class NoVideoErrorWidget extends StatelessWidget {
  const NoVideoErrorWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SvgPicture.asset(
            DesignConfig.getIconPath(
                Provider.of<ThemeNotifier>(context).getThemeMode() ==
                        ThemeMode.dark
                    ? "no_video_dark.svg"
                    : "no_video.svg"),
            height: MediaQuery.of(context).size.height * .3,
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * .047,
          ),
          // No Videos Found
          Text("No Videos Found",
              style: TextStyle(
                  color: Theme.of(context).secondaryHeaderColor,
                  fontWeight: FontWeight.w700,
                  fontStyle: FontStyle.normal,
                  fontSize: 22.0),
              textAlign: TextAlign.center)
        ],
      ),
    );
  }
}
