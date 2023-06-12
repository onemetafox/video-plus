import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';

//notification handle in this class

class PushNotificationService {
  final FirebaseMessaging _fcm;

  PushNotificationService(this._fcm);

  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future initialise() async {
    if (Platform.isIOS) {
      iospermission();
    }
    _fcm.getToken();
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(myForgroundMessageHandler);
    FirebaseMessaging.onMessage.listen(myForgroundMessageHandler);
    FirebaseMessaging.onMessageOpenedApp.listen(myForgroundMessageHandler);
  }

  void iospermission() {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  Future<dynamic> myForgroundMessageHandler(RemoteMessage? message) async {
    if (message!.data != null) {
      var data = message.data;
      print(
          "myForgroundMessageHandler.....................................$data");
      if (data['type'] == "default" ||
          data['type'] == "category" ||
          data['type'] == "video") {
        var title = data['title'].toString();
        var body = data['body'].toString();
        var image = data['image'].toString();
        var payload = data["type"].toString();
        print(
            "title:$title....body:$body.....image:$image.....payload:$payload");
        if (image != "") {
          generateImageNotication(title, body, image, payload);
        } else {
          generateSimpleNotication(title, body, payload);
        }
      } else {
        var type = data['type'].toString();
        var newsId = data['news_id']?.toString();
        var message = data['message']?.toString();

        generateSimpleNotication(message!, "", newsId!);
        print("*****************************************");
      }
    } else {
      print("no notification");
    }
  }

  Future<String> _downloadAndSaveFile(String url, String fileName) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String filePath = '${directory.path}/$fileName';
    final Response response = await get(Uri.parse(url));
    final File file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return filePath;
  }

  Future<void> generateImageNotication(
      String title, String msg, String image, String type) async {
    var largeIconPath = await _downloadAndSaveFile(image, 'largeIcon');
    var bigPicturePath = await _downloadAndSaveFile(image, 'bigPicture');
    var bigPictureStyleInformation = BigPictureStyleInformation(
        FilePathAndroidBitmap(bigPicturePath),
        hideExpandedLargeIcon: true,
        contentTitle: title,
        htmlFormatContentTitle: true,
        summaryText: msg,
        htmlFormatSummaryText: true);
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'com.wrteam.videoPlus',
      'videoPlus',
      largeIcon: FilePathAndroidBitmap(largeIconPath),
      styleInformation: bigPictureStyleInformation,
    );
    var platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin
        .show(0, title, msg, platformChannelSpecifics, payload: type);
  }

  Future<void> generateSimpleNotication(
      String title, String msg, String type) async {
    var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
      'com.wrteam.videoPlus',
      'videoPlus',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    var platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin
        .show(0, title, msg, platformChannelSpecifics, payload: type);
  }
}
