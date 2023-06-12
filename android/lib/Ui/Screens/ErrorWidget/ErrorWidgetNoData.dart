import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../Utils/DesignConfig.dart';

class ErrorWidgetNoData extends StatelessWidget {
  const ErrorWidgetNoData({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SvgPicture.asset(
            DesignConfig.getIconPath("image_no_result_found.svg"),
            height: MediaQuery.of(context).size.height * .3,
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * .04,
          ),
          // No Connection
          Text("No Result Found",
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
          Text("Please check spelling or try different keyword",
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
