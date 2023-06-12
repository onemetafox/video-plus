import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../Provider/ThemeProvider.dart';
import '../../Utils/Constant.dart';
import '../../Utils/DesignConfig.dart';
import 'commonDurationWidget.dart';
import 'commonPremiumIconWidget.dart';
// import '../../model/CategoryVideoModel.dart';

class CommonCardForAllWidget extends StatelessWidget {
  final List<dynamic> list; //CategoryVideoModel
  final int index;
  final List<String> videoList;
  final bool isDurationRequired, isTimeAgoRequired;
  // final int isSubscribed;

  const CommonCardForAllWidget({
    Key? key,
    required this.list,
    required this.index,
    required this.videoList,
    this.isDurationRequired = true,
    this.isTimeAgoRequired = true,
    // this.isSubscribed = 0
  }) : super(key: key);

  // late AnimationController animationController = AnimationController(
  //     vsync: this, duration: const Duration(milliseconds: 5));

  @override
  Widget build(BuildContext context) {
    return Container(
        height: MediaQuery.of(context).size.height * .11,
        margin: const EdgeInsets.only(top: 5, bottom: 5, left: 15, right: 15),
        child: Card(
            color: Theme.of(context).colorScheme.primary,
            shadowColor: Colors.black12,
            margin: EdgeInsets.zero,
            elevation: 20,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * .33 /*116*/,
                  height: MediaQuery.of(context).size.height * .093,
                  margin: const EdgeInsets.only(left: 8),
                  // margin: EdgeInsets.only(left: 8, top: 8, bottom: 8),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(borderRadius),
                        child: CachedNetworkImage(
                          imageUrl: (list[index].image != null &&
                                  list[index].image!.isNotEmpty)
                              ? list[index].image!
                              : videoList[index],
                          fit: BoxFit.fitWidth,
                          imageBuilder: (context, imageProvider) => Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: imageProvider,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          placeholder: (context, url) => Shimmer.fromColors(
                              baseColor: Provider.of<ThemeNotifier>(context)
                                          .getThemeMode() ==
                                      ThemeMode.dark
                                  ? Colors.white30
                                  : Colors.grey[300]!,
                              highlightColor:
                                  Provider.of<ThemeNotifier>(context)
                                              .getThemeMode() ==
                                          ThemeMode.dark
                                      ? Colors.white30
                                      : Colors.grey[100]!,
                              child: Container(
                                height:
                                    MediaQuery.of(context).size.height * .11,
                                width: MediaQuery.of(context).size.width *
                                    .33 /*116*/,
                                margin: EdgeInsets.all(
                                    MediaQuery.of(context).size.height * .008),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.circular(borderRadius),
                                ),
                              )),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                        ),
                      ),
                      list[index].type == 1
                          ? const CommonPremiumIconWidget()
                          : const SizedBox.shrink(),
                      /*
                          ? Positioned(
                              top: 0,
                              left: 0,
                              child: Container(
                                decoration: const BoxDecoration(
                                    color: Color(0x80000000),
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(borderRadius),
                                        bottomRight:
                                            Radius.circular(borderRadius))),
                                height:
                                    MediaQuery.of(context).size.height * .03,
                                width: MediaQuery.of(context).size.width * .06,
                                padding: const EdgeInsets.all(5.0),
                                child: SvgPicture.asset(
                                    DesignConfig.getIconPath(
                                        "premium_icon.svg")),
                              ))
                          : Container(),

                          */
                      /*  isSubscribed == subscribeStatusVal &&
                              list[index].type == 1
                          ? const SizedBox.shrink()
                          : Align(
                              alignment: Alignment.center,
                              child: Lottie.asset(
                                  "assets/animation/animation.json",
                                  alignment: Alignment.center,
                                  controller: animationController,
                                  onLoaded: (composition) async {
                                animationController.duration =
                                    composition.duration;
                                await animationController.repeat();
                              }),
                            ), */
                      (isDurationRequired)
                          ? CommonDurationWidget(
                              durationValue: list[index].duration,
                              isBottomRadius: true)
                          : const SizedBox.shrink(),
                      /* Positioned(
                        bottom: 0,
                        right: 0,
                        // top: MediaQuery.of(context).size.height * .18,
                        child: Container(
                            height: MediaQuery.of(context).size.height * .02,
                            alignment: Alignment.center,
                            width: list[index].duration!.length > 5
                                ? MediaQuery.of(context).size.width * .12
                                : MediaQuery.of(context).size.width * .09,
                            decoration: const BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.only(
                                    bottomRight:
                                        Radius.circular(borderRadius))),
                            child: Text(list[index].duration!,
                                style: const TextStyle(
                                    color: Color(0xffffffff),
                                    fontWeight: FontWeight.w400,
                                    fontStyle: FontStyle.normal,
                                    fontSize: 10.0),
                                textAlign: TextAlign.left)),
                      ) */
                    ],
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width * .52,
                  margin: const EdgeInsets.only(left: 8, right: 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          list[index].categoryName![0].toUpperCase() +
                              list[index].categoryName!.substring(1),
                          maxLines: 1,
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              height: 1,
                              fontWeight: FontWeight.bold,
                              fontSize: 12.0),
                          textAlign: TextAlign.left),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * .005,
                      ),
                      Text(
                          list[index].title![0].toUpperCase() +
                              list[index].title!.substring(1),
                          maxLines: 1,
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: Theme.of(context).secondaryHeaderColor,
                              height: 1,
                              fontWeight: FontWeight.bold,
                              fontSize: 14.0),
                          textAlign: TextAlign.left),
                      SizedBox(
                        height: (list[index].description!.isNotEmpty ||
                                list[index].description != "")
                            ? MediaQuery.of(context).size.height * .005
                            : 0,
                      ),
                      (list[index].description!.isNotEmpty ||
                              list[index].description != "")
                          ? Text(
                              list[index].description![0].toUpperCase() +
                                  list[index].description!.substring(1),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                  height: 1,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12.0),
                              textAlign: TextAlign.left)
                          : Container(),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * .005,
                      ),
                      (isTimeAgoRequired)
                          ? Text(
                              DesignConfig.timeAgo(
                                  DateTime.parse(list[index].date!)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .secondary
                                      .withOpacity(0.5),
                                  height: 1,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12.0),
                              textAlign: TextAlign.left)
                          : const SizedBox.shrink()
                    ],
                  ),
                )
              ],
            )));
  }
}
