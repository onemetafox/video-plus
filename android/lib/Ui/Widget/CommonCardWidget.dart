import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:videoPlus/Ui/Widget/commonDurationWidget.dart';

import '../../Provider/ThemeProvider.dart';
import '../../Utils/Constant.dart';
import '../../Utils/DesignConfig.dart';
import '../../model/CategoryVideoModel.dart';
import 'commonPremiumIconWidget.dart';

class CommonCardCategoryWidget extends StatelessWidget {
  final List<CategoryVideoModel> list;
  final int index;
  final List<String> videoList;
  const CommonCardCategoryWidget(
      {Key? key,
      required this.list,
      required this.index,
      required this.videoList})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * .11,
      margin: const EdgeInsets.only(top: 5, bottom: 5),
      child: Card(
          color: Theme.of(context).colorScheme.primary,
          shadowColor: Colors.black12,
          margin: EdgeInsets.zero,
          elevation: 15,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: MediaQuery.of(context).size.width * .33 /*116*/,
                margin:
                    EdgeInsets.all(MediaQuery.of(context).size.height * .008),
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
                            highlightColor: Provider.of<ThemeNotifier>(context)
                                        .getThemeMode() ==
                                    ThemeMode.dark
                                ? Colors.white30
                                : Colors.grey[100]!,
                            child: Container(
                              height: MediaQuery.of(context).size.height * .11,
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
                        /*Center(
                          child: Container(
                              height: 30,
                              width: 30,
                              child: CircularProgressIndicator(
                                color: Theme.of(context).primaryColor,
                              )),
                        ),*/
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                        fit: BoxFit.cover,
                      ), /*Image.network(
                          _videoCat[index],
                        ),*/
                    ),
                    list[index].type == 1
                        ? const CommonPremiumIconWidget()
                        : const SizedBox.shrink(),
                    /*  ? Positioned(
                            top: 0,
                            left: 0,
                            child: Container(
                              decoration: const BoxDecoration(
                                  color: Color(0x80000000),
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(borderRadius),
                                      bottomRight:
                                          Radius.circular(borderRadius))),
                              height: MediaQuery.of(context).size.height * .03,
                              width: MediaQuery.of(context).size.width * .06,
                              padding: const EdgeInsets.all(5.0),
                              child: SvgPicture.asset(
                                  DesignConfig.getIconPath("premium_icon.svg")),
                            ))
                        : Container(), */
                    CommonDurationWidget(
                        durationValue: list[index].duration,
                        isBottomRadius: true),
                    /*
                    return Positioned(
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
                  bottomRight: Radius.circular(borderRadius))),
          child: Text(list[index].duration!,
              style: const TextStyle(
                  color: Color(0xffffffff),
                  fontWeight: FontWeight.w400,
                  fontStyle: FontStyle.normal,
                  fontSize: 10.0),
              textAlign: TextAlign.left)),
    );
                     */
                  ],
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width * .55,
                margin: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * .01,
                    right: MediaQuery.of(context).size.width * .008),
                alignment: Alignment.topLeft,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * .005,
                      ),
                      child: Text(
                          list[index].title![0].toUpperCase() +
                              list[index].title!.substring(1),
                          maxLines: 1,
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: Theme.of(context).secondaryHeaderColor,
                              height: 1,
                              fontWeight: FontWeight.w600,
                              fontStyle: FontStyle.normal,
                              fontSize: 14.0),
                          textAlign: TextAlign.left),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * .005,
                      ),
                      child: Text(
                          (list[index].description!.isNotEmpty &&
                                  list[index].description != "")
                              ? list[index].description![0].toUpperCase() +
                                  list[index].description!.substring(1)
                              : "",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                              height: 1,
                              fontWeight: FontWeight.w400,
                              fontSize: 12.0),
                          textAlign: TextAlign.left),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * .005,
                      ),
                      child: Text(
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
                          textAlign: TextAlign.left),
                    ),
                  ],
                ),
              )
            ],
          )),
    );
  }
}
