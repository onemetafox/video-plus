import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:videoPlus/Utils/DesignConfig.dart';

import 'StringRes.dart';

class AppUnderMaintenanceDialog extends StatelessWidget {
  const AppUnderMaintenanceDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * (0.275),
              width: MediaQuery.of(context).size.width * (0.8),
              child: SvgPicture.asset(
                DesignConfig.getIconPath("undermaintenance.svg"),
                color: Theme.of(context).primaryColor,
              ),
            ),
            Text(
              StringRes.msgMaintain,
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).secondaryHeaderColor),
            )
          ],
        ),
      ),
    );
  }
}
