import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../../App/Routes.dart';
import '../../../Provider/ThemeProvider.dart';
import '../../../Provider/categoryProvider.dart';
import '../../../Utils/Constant.dart';
import '../../../Utils/DesignConfig.dart';
import '../../../Utils/InternetConnectivity.dart';
import '../../../Utils/StringRes.dart';
import '../../../Utils/apiParameters.dart';
import '../../../Utils/apiUtils.dart';
import '../../../model/CategoryModel.dart';
import '../../Widget/shimmerWidget.dart';
import '../ErrorWidget/NoConErrorWidget.dart';
import '../ErrorWidget/NoVideoErrorWidget.dart';

class CategoryViewAllScreen extends StatefulWidget {
  const CategoryViewAllScreen({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return CategoryViewAllScreenState();
  }
}

class CategoryViewAllScreenState extends State<CategoryViewAllScreen> {
  List<CategoryModel> categoryList = [];
  bool isLoading = true;
  String _connectionStatus = 'unKnown';
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> connectivitySubscription;
//get category APi
  Future getCategory() async {
    try {
      final body = {};
      final response = await post(Uri.parse(getCategoryUrl),
          body: body, headers: await ApiUtils.getHeaders());
      final responseJson = jsonDecode(response.body);
      if (responseJson['error'] == true) {
        if (responseJson['status'] == "Unauthorized access") {
          Navigator.of(context).pushNamedAndRemoveUntil(
              '/login', (Route<dynamic> route) => false);
        }
        setState(() {
          DesignConfig.setSnackbar(responseJson['error'], context, false);
        });
      } else {
        var parsedList = responseJson["data"];
        categoryList = (parsedList as List)
            .map((data) => CategoryModel.fromJson(data as Map<String, dynamic>))
            .toList();
        if (mounted) {
          context.read<CategoryProvider>().changeCategoryList(categoryList);
        }
      }
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> refresh() async {
    categoryList.clear();
    getCategory();
  }

  @override
  void initState() {
    CheckInternet.initConnectivity().then((value) => setState(() {
          _connectionStatus = value;
        }));
    connectivitySubscription =
        _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      CheckInternet.updateConnectionStatus(result).then((value) => setState(() {
            _connectionStatus = value;
          }));
    });
    getCategory();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return _connectionStatus == 'ConnectivityResult.none'
        ? NoConErrorWidget(
            onTap: () {
              setState(() {
                CheckInternet.initConnectivity().then((value) => setState(() {
                      _connectionStatus = value;
                    }));
                connectivitySubscription = _connectivity.onConnectivityChanged
                    .listen((ConnectivityResult result) {
                  CheckInternet.updateConnectionStatus(result)
                      .then((value) => setState(() {
                            _connectionStatus = value;
                          }));
                });
              });
            },
          )
        : Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Theme.of(context).colorScheme.primary,
              leadingWidth: size.width * .18,
              titleSpacing: 0,
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
              title: Text(StringRes.categories,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: Theme.of(context).secondaryHeaderColor,
                      fontWeight: FontWeight.w700,
                      fontStyle: FontStyle.normal,
                      fontSize: 16.0),
                  textAlign: TextAlign.left),
            ),
            body: playList(size),
          );
  }

  Widget playList(dynamic size) {
    return Container(
      height: size.height,
      padding: EdgeInsets.zero,
      margin: EdgeInsets.only(left: size.width * .04, right: size.width * .04),
      child: isLoading
          ? ShimmerWidget(
              height: MediaQuery.of(context).size.height * .11,
              length: 15,
            )
          : categoryList.isEmpty
              ? const NoVideoErrorWidget()
              : RefreshIndicator(
                  color: Theme.of(context).primaryColor,
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  onRefresh: refresh,
                  child: ListView.builder(
                    itemCount: categoryList.length,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * .01,
                      //bottom: MediaQuery.of(context).size.height * .1,
                    ),
                    shrinkWrap: true,
                    itemBuilder: (BuildContext context, int index) {
                      CategoryModel item = categoryList[index];
                      return GestureDetector(
                        onTap: () async {
                          await Navigator.of(context)
                              .pushNamed(Routes.categoryPlayList, arguments: {
                            "totalVideo": item.totalVideo.toString(),
                            "title": item.categoryName,
                            "description": item.description,
                            "image": item.image,
                            "categoryId": item.id
                          });
                        },
                        onDoubleTap: () {},
                        child: Container(
                            height: MediaQuery.of(context).size.height * .11,
                            margin: EdgeInsets.only(
                              top: size.height * .005,
                              bottom: size.height * .005,
                            ),
                            child: Card(
                              color: Theme.of(context).colorScheme.primary,
                              shadowColor: Colors.black12,
                              margin: EdgeInsets.zero,
                              elevation: 15,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(borderRadius),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width * .33,
                                    margin: EdgeInsets.all(size.height * .008),
                                    child: ClipRRect(
                                      borderRadius:
                                          BorderRadius.circular(borderRadius),
                                      child: CachedNetworkImage(
                                        imageUrl: item.image!,
                                        fit: BoxFit.fill,
                                        height:
                                            MediaQuery.of(context).size.height *
                                                .12,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                .25,
                                        imageBuilder:
                                            (context, imageProvider) =>
                                                Container(
                                          decoration: BoxDecoration(
                                            image: DecorationImage(
                                              image: imageProvider,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        placeholder: (context, url) =>
                                            Shimmer.fromColors(
                                                baseColor:
                                                    Provider.of<ThemeNotifier>(
                                                                    context)
                                                                .getThemeMode() ==
                                                            ThemeMode.dark
                                                        ? Colors.white30
                                                        : Colors.grey[300]!,
                                                highlightColor:
                                                    Provider.of<ThemeNotifier>(
                                                                    context)
                                                                .getThemeMode() ==
                                                            ThemeMode.dark
                                                        ? Colors.white30
                                                        : Colors.grey[100]!,
                                                child: Container(
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      .12,
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      .25,
                                                  margin: EdgeInsets.all(
                                                      MediaQuery.of(context)
                                                              .size
                                                              .height *
                                                          .008),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            borderRadius),
                                                  ),
                                                )),
                                        errorWidget: (context, url, error) =>
                                            const Icon(Icons.error),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width * .53,
                                    margin: EdgeInsets.only(
                                        top: size.height * .01,
                                        right: size.width * .008),
                                    alignment: Alignment.topLeft,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              .005,
                                        ),
                                        Text(
                                            item.categoryName![0]
                                                    .toUpperCase() +
                                                item.categoryName!.substring(1),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                height: 1,
                                                color: Theme.of(context)
                                                    .secondaryHeaderColor,
                                                fontWeight: FontWeight.bold,
                                                fontStyle: FontStyle.normal,
                                                fontSize: 14.0),
                                            textAlign: TextAlign.left),
                                        SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              .005,
                                        ),
                                        Text(
                                            (item.description != null &&
                                                    item.description!
                                                        .isNotEmpty)
                                                ? item.description![0]
                                                        .toUpperCase() +
                                                    item.description!
                                                        .substring(1)
                                                : "",
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                height: 1,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .secondary,
                                                fontWeight: FontWeight.normal,
                                                fontSize: 12.0),
                                            textAlign: TextAlign.left),
                                        SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              .005,
                                        ),
                                        Text(
                                            "${item.totalVideo} ${item.totalVideo.toString() == "0" || item.totalVideo.toString() == "1" ? "Video" : "Videos"}",
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                height: 1,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .secondary
                                                    .withOpacity(0.5),
                                                fontWeight: FontWeight.normal,
                                                fontSize: 12.0)),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            )),
                      );
                    },
                  )),
    );
  }
}
