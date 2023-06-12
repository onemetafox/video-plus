import 'dart:async';
import 'dart:convert';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:html/dom.dart' as dom;
import 'package:http/http.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../Utils/DesignConfig.dart';
import '../../../Utils/InternetConnectivity.dart';
import '../../../Utils/apiParameters.dart';
import '../../../Utils/apiUtils.dart';
import '../ErrorWidget/NoConErrorWidget.dart';

class AboutUsScreen extends StatefulWidget {
  final String? title, type;
  const AboutUsScreen({Key? key, this.title, this.type}) : super(key: key);
  static Route<dynamic> route(RouteSettings routeSettings) {
    Map arguments = routeSettings.arguments as Map;
    return CupertinoPageRoute(
        builder: (context) => AboutUsScreen(
              title: arguments['title'],
              type: arguments['type'],
            ));
  }

  @override
  State<StatefulWidget> createState() {
    return AboutUsScreenState();
  }
}

class AboutUsScreenState extends State<AboutUsScreen> {
  String? data;
  bool loading = true;
  String _connectionStatus = 'unKnown';
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  Future<void> loadCat() async {
    await getSetting();
  }

  Future getSetting() async {
    try {
      final body = {
        typeApiKey: widget.type,
      };
      final response = await post(Uri.parse(getSettingUrl),
          body: body, headers: await ApiUtils.getHeaders());
      final responseJson = jsonDecode(response.body);
      final getData = responseJson['data'];
      print("===getSetting========$responseJson");
      if (responseJson['error'] == "true") {
        DesignConfig.setSnackbar(responseJson['error'], context, false);
      } else {
        setState(() {
          data = getData['message'];
          print("in Api $data");
        });
      }
      setState(() {
        loading = false;
      });
    } catch (e) {
      setState(() {
        DesignConfig.setSnackbar(e.toString(), context, false);
      });
      print(e.toString());
    }
  }

  @override
  void initState() {
    CheckInternet.initConnectivity().then((value) => setState(() {
          _connectionStatus = value;
        }));
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      CheckInternet.updateConnectionStatus(result).then((value) => setState(() {
            _connectionStatus = value;
          }));
    });
    // if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
    Future.delayed(Duration.zero, () {
      loadCat();
    });
    //DesignConfig.showInterstitialAd();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _connectionStatus == 'ConnectivityResult.none'
        ? NoConErrorWidget(
            onTap: () {
              setState(() {
                loadCat();
              });
            },
          )
        : Scaffold(
            appBar: AppBar(
              elevation: 0,
              leadingWidth: 80,
              titleSpacing: 2,
              backgroundColor: Theme.of(context).colorScheme.primary,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20)),
              ),
              leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DesignConfig.backButton(onPress: () {
                    Navigator.pop(context);
                  })),
              title: // Buy Membership
                  Text(widget.title!,
                      style: TextStyle(
                          color: Theme.of(context).secondaryHeaderColor,
                          fontWeight: FontWeight.w700,
                          fontStyle: FontStyle.normal,
                          fontSize: 16.0),
                      textAlign: TextAlign.left),
            ),
            body: loading
                ? Center(
                    child: CircularProgressIndicator(
                      color: Theme.of(context).primaryColor,
                    ),
                  )
                : SingleChildScrollView(
                    child: Html(
                      data: data!,
                      style: {
                        "body": Style(
                            fontSize: FontSize(16.0),
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).secondaryHeaderColor),
                      },
                      shrinkWrap: true,
                      onLinkTap: (String? url,
                          // RenderContext context,
                          Map<String, String> attributes,
                          dom.Element? element) async {
                        if (await canLaunchUrlString(url!)) {
                          await /*launch*/ launchUrlString(
                            url,
                            /*  forceSafariVC: false,
                            forceWebView: false,*/
                          );
                        } else {
                          throw 'Could not launch $url';
                        }
                      },
                    ),
                  ));
  }
}
