import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:videoPlus/Utils/DesignConfig.dart';
import 'package:videoPlus/model/CategoryVideoModel.dart';

class GeneralMethods {
  static List<String> getThumbnail(
      {required List<CategoryVideoModel> listData}) {
    print("length of modal List - ${listData.length}");
    List<String> videoThumbnail = [];
    for (int i = 0; i < listData.length; i++) {
      videoThumbnail.add(DesignConfig.getThumbnail(
          videoId: listData[i].videoId!, type: listData[i].videoType!));

      // 'https://img.youtube.com/vi/${freeVideoList[i].videoId}/sddefault.jpg');
    }

    print("length of thumbnail list - ${videoThumbnail.length}");
    return videoThumbnail;
  }

  static setNetworkImage(
      {required String imgUrl,
      required thumbnailImg,
      required BuildContext context}) {
    return Image.network(
      (imgUrl == '' && thumbnailImg != '') ? thumbnailImg : imgUrl,
      /* (videoHistoryList[index].image != null &&
                                            videoHistoryList[index]
                                                .image!
                                                .isNotEmpty) //videoHistoryList
                                        ? */
      //videoHistoryList
      // : videoHistory[index],
      errorBuilder: (
        BuildContext context,
        Object exception,
        StackTrace? stackTrace,
      ) {
        return setSVGImage(
            iconName: 'placeholder.svg',
            context: context); //use placeholder img here
      },
      loadingBuilder: (BuildContext context, Widget? child,
          ImageChunkEvent? loadingProgress) {
        // print('loading builder');
        if (loadingProgress == null) {
          return child!;
        }
        return setSVGImage(
            iconName: 'placeholder.svg',
            context: context); //use placeholder img here
      },
      fit: BoxFit.cover,
      // width: MediaQuery.of(context).size.width,
      // height: MediaQuery.of(context).size.height * .09,
    );
  }

  static setSVGImage(
      {required String iconName, required BuildContext context}) {
    return SvgPicture.asset(
      DesignConfig.getIconPath(iconName),
      fit: BoxFit.contain,
      // alignment: Alignment.center,
      // width: 300, //MediaQuery.of(context).size.width,
      // height: 70,
    );
  }

  static Duration parseDuration(String s) {
    int hours = 0;
    int minutes = 0;
    int micros;
    List<String> parts = s.split(':');
    if (parts.length > 2) {
      hours = int.parse(parts[parts.length - 3]);
    }
    if (parts.length > 1) {
      minutes = int.parse(parts[parts.length - 2]);
    }
    micros = (double.parse(parts[parts.length - 1]) * 1000000).round();
    return Duration(hours: hours, minutes: minutes, microseconds: micros);
  }
}
