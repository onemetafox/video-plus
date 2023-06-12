import 'package:flutter/material.dart';

import '../../Utils/Constant.dart';

class CommonDurationWidget extends StatelessWidget {
  final String? durationValue;
  final bool? isBottomRadius;
  const CommonDurationWidget(
      {Key? key, required this.durationValue, this.isBottomRadius = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      right: 0,
      child: Container(
          height: MediaQuery.of(context).size.height * .02,
          alignment: Alignment.center,
          width: durationValue!.length > 5
              ? MediaQuery.of(context).size.width * .12
              : MediaQuery.of(context).size.width * .09,
          decoration: (isBottomRadius!)
              ? const BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(borderRadius)))
              : null,
          child: Text(durationValue!,
              style: const TextStyle(
                  color: Color(0xffffffff),
                  fontWeight: FontWeight.w400,
                  fontStyle: FontStyle.normal,
                  fontSize: 10.0),
              textAlign: TextAlign.left)),
    );
  }
}
