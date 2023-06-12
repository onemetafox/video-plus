import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../Provider/ThemeProvider.dart';
import '../../Utils/Constant.dart';
import '../../Utils/DesignConfig.dart';

class ShimmerWidget extends StatelessWidget {
  final int? length;
  final double? width, height;
  const ShimmerWidget({Key? key, this.length, this.width, this.height})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
        baseColor:
            Provider.of<ThemeNotifier>(context).getThemeMode() == ThemeMode.dark
                ? Colors.white30
                : Colors.grey[300]!,
        highlightColor:
            Provider.of<ThemeNotifier>(context).getThemeMode() == ThemeMode.dark
                ? Colors.white30
                : Colors.grey[100]!,
        child: ListView.builder(
            itemCount: length,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).size.height * .01,
              bottom: MediaQuery.of(context).size.height * .1,
            ),
            shrinkWrap: true,
            itemBuilder: (BuildContext context, int index) {
              return Padding(
                padding: const EdgeInsets.only(
                    top: 5, bottom: 5, left: 15, right: 15),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * .27,
                      height: 70,
                      margin: const EdgeInsets.only(left: 8, top: 8, bottom: 8),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(borderRadius),
                          color: DesignConfig.isDark
                              ? Colors.white30
                              : Colors.grey[300]!,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Container(
                        width: MediaQuery.of(context).size.width * .63,
                        margin: const EdgeInsets.only(top: 10),
                        alignment: Alignment.topLeft,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              color: DesignConfig.isDark
                                  ? Colors.white30
                                  : Colors.grey[300]!,
                              height: 5,
                              width: MediaQuery.of(context).size.height,
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * .005,
                            ),
                            Container(
                              color: DesignConfig.isDark
                                  ? Colors.white30
                                  : Colors.grey[300]!,
                              height: 5,
                              width: MediaQuery.of(context).size.height,
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * .005,
                            ),
                            Container(
                              color: DesignConfig.isDark
                                  ? Colors.white30
                                  : Colors.grey[300]!,
                              height: 5,
                              width: MediaQuery.of(context).size.height,
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              )
                  /*Container(
                height: height,
                margin: const EdgeInsets.only(
                    top: 5, bottom: 5, left: 15, right: 15),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(borderRadius),
                    color: Theme.of(context).colorScheme.primary),
              )*/
                  ;
            }));
  }
}
