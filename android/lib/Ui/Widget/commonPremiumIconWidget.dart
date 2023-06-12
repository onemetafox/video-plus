import 'package:flutter/material.dart';
import 'package:videoPlus/Utils/generalMethods.dart';

import '../../Utils/Constant.dart';

class CommonPremiumIconWidget extends StatelessWidget {
  const CommonPremiumIconWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
        top: 0,
        left: 0,
        child: Container(
            decoration: const BoxDecoration(
                color: Color(0x80000000),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(borderRadius),
                    bottomRight: Radius.circular(borderRadius))),
            height: MediaQuery.of(context).size.height * .03,
            width: MediaQuery.of(context).size.width * .06,
            padding: const EdgeInsets.all(5.0),
            child: GeneralMethods.setSVGImage(
                iconName: "premium_icon.svg", context: context)
            //SvgPicture.asset(DesignConfig.getIconPath("premium_icon.svg")),
            ));
  }
}
