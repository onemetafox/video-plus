import 'dart:collection';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import 'Constant.dart';

class VideoApis {
  String? videoId;
  int? type;
  VideoApis(this.videoId, this.type);

  /* getVimo() {
    return getVimeoVideoQualityUrls();
  }*/

  getYoutubeViemo() {
    return type == viemoVideoType
        ? getVimeoVideoQualityUrls()
        : getYoutubeVideoQualityUrls();
  }

  Future<SplayTreeMap?> getVimeoVideoQualityUrls() async {
    try {
      final response = await http.get(
        Uri.parse('https://player.vimeo.com/video/$videoId/config'),
      );
      final jsonData =
          jsonDecode(response.body)['request']['files']['progressive'];

      //  print("picture Url:${"https://vumbnail.com/$videoId.jpg"}");
      SplayTreeMap videoList = SplayTreeMap.fromIterable(
        jsonData,
        key: (item) => "${item['quality']} ${item['fps']}",
        value: (item) => item['url'],
      );
      return videoList;
    } catch (error) {
      rethrow;
    }
  }

  Future getYoutubeVideoQualityUrls() async {
    try {
      final yt = YoutubeExplode();

      final muxed = (await yt.videos.streamsClient
              .getManifest("https://youtu.be/$videoId"))
          .muxed;
      SplayTreeMap videoList = SplayTreeMap.fromIterable(
        muxed,
        key: (item) => item.qualityLabel,
        value: (item) => item.url.toString(),
      );
      return videoList;
    } catch (error) {
      rethrow;
    }
  }
}
