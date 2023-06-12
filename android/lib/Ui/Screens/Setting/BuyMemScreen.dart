import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:provider/provider.dart';
import 'package:videoPlus/Provider/SettingProvider.dart';
import 'package:videoPlus/Utils/DesignConfig.dart';

import '../../../LocalDataStore/AuthLocalDataStore.dart';
import '../../../LocalDataStore/SettingLocalDataSource.dart';
import '../../../Provider/inAppPurchaseProvider.dart';
import '../../../Utils/ColorRes.dart';
import '../../../Utils/Constant.dart';
import '../../../Utils/InternetConnectivity.dart';
import '../../../Utils/StringRes.dart';
import '../../../Utils/apiParameters.dart';
import '../../../Utils/apiUtils.dart';
import '../../../model/InAppPurchasseListModel.dart';
import '../../Widget/shimmerNotificationWidget.dart';
import '../ErrorWidget/NoConErrorWidget.dart';

class BuyMemScreen extends StatefulWidget {
  const BuyMemScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return BuyMemScreenState();
  }
}

class BuyMemScreenState extends State<BuyMemScreen> {
  int selectedIndex = 0, currentIndex = 0, getIsSub = 0;
  bool loading = true;
  String? purchasedProductId;
  String _connectionStatus = 'unKnown', createDate = "", expDate = '';

  List<InAppPurchaseListModel> inAppPurchaseList = [];
  List<InAppPurchaseListModel> list = [];
  final List<String> productIds = [];
  List newList = [];
  List<ProductDetails> products = [];
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  List<String> notFoundIds = [];

  InAppPurchaseListModel? item;
  final InAppPurchase inAppPurchase = InAppPurchase.instance;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> connectivitySubscription;

  Future setInAppPurchase(int inAppId) async {
    try {
      final body = {
        userIdApiKey: AuthLocalDataSource.getUserId(),
        inappIdApiKey: inAppId.toString()
      };
      final response = await post(Uri.parse(setInAppListUrl),
          body: body, headers: await ApiUtils.getHeaders());
      final responseJson = jsonDecode(response.body);
      debugPrint("===set in App purchaseList ========$responseJson");
      if (responseJson['error'] == "true") {
        setState(() {
          DesignConfig.setSnackbar(responseJson['error'], context, false);
        });
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

//get user by id
  Future getUserById() async {
    try {
      final body = {
        userIdApiKey: AuthLocalDataSource.getUserId(),
      };
      final response = await post(Uri.parse(getUserByIdUrl),
          body: body, headers: await ApiUtils.getHeaders());
      final responseJson = jsonDecode(response.body);
      debugPrint("===get user by id========$responseJson");

      if (responseJson['error'] == true) {
        DesignConfig.setSnackbar(responseJson['error'], context, false);
      } else {
        context
            .read<SettingProvider>()
            .changeSetIsSubscribe(responseJson["data"]["is_subscribe"] ?? 0);
        context
            .read<SettingProvider>()
            .changeInAppCreateDate(responseJson["data"]["created_at"] ?? "");
        context
            .read<SettingProvider>()
            .changeInAppExDate(responseJson["data"]["inapp_exp_date"] ?? "");
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> initializePurchase(
    List<String> productIds,
  ) async {
    _subscription =
        inAppPurchase.purchaseStream.listen(purchaseUpdate, onDone: () {
      _subscription.cancel();
    }, onError: (e) {
      print("Errors:${e.toString()}");
    });

    //to confirm in-app purchase is available or not
    final isAvailable = await inAppPurchase.isAvailable();
    if (!isAvailable) {
      print("in app purchase not Available");
    } else {
      //if in-app purchase is available then load products with given id
      _loadProducts(productIds);
    }
  }

  //it will load products form store
  void _loadProducts(List<String> productIds) async {
    //load products for purchase (consumable product)
    ProductDetailsResponse productDetailResponse =
        await inAppPurchase.queryProductDetails(productIds.toSet());
    if (productDetailResponse.error != null) {
      //error while getting products from store
      print("ERROR:${productDetailResponse.error!}");
    }
    //if there is not any product to purchase (consumable)
    else if (productDetailResponse.productDetails.isEmpty) {
      print("id is empty");
    } else {
      for (var element in productDetailResponse.productDetails) {
        print("Product Id : ${element.id}");
      }

      productDetailResponse.productDetails
          .sort((first, second) => first.rawPrice.compareTo(second.rawPrice));

      products = productDetailResponse.productDetails;
      notFoundIds = productDetailResponse.notFoundIDs;
    }
  }

//will listen purchase stream
  purchaseUpdate(
    List<PurchaseDetails> purchaseDetails,
  ) async {
    for (var purchaseDetail in purchaseDetails) {
      //product purchased successfully
      if (purchaseDetail.status == PurchaseStatus.purchased) {
        products;
        purchasedProductId = purchaseDetail.productID;
        await setInAppPurchase(list[selectedIndex].id!);
        await getUserById();
        if (mounted) {
          Navigator.of(context, rootNavigator: true).pop();
        }
      } else if (purchaseDetail.status == PurchaseStatus.pending) {
        print("Purchase is pending");
      } else if (purchaseDetail.status == PurchaseStatus.error) {
        print("Error occurred");
        print(purchaseDetail.error?.message);
      }

      //
      if (purchaseDetail.pendingCompletePurchase) {
        print("Mark the product delivered to the user");
        inAppPurchase.completePurchase(purchaseDetail);
      }
    }
  }

  //to buy product
  Future<void> buyConsumableProducts(ProductDetails productDetails) async {
    final PurchaseParam purchaseParam =
        PurchaseParam(productDetails: productDetails);
    InAppPurchase.instance.buyConsumable(purchaseParam: purchaseParam);
  }

  Future getInAppPurchase(String type) async {
    try {
      final body = {
        userIdApiKey: AuthLocalDataSource.getUserId(),
        typeApiKey: type
      };
      final response = await post(Uri.parse(getInAppListUrl),
          body: body, headers: await ApiUtils.getHeaders());
      final responseJson = jsonDecode(response.body);
      print("===get in App purchaseList ========$responseJson");
      if (responseJson['error'] == "true") {
        setState(() {
          DesignConfig.setSnackbar(responseJson['error'], context, false);
        });
      } else {
        if (mounted) {
          setState(() {
            var parsedList = responseJson["data"];
            inAppPurchaseList = (parsedList as List)
                .map((data) => InAppPurchaseListModel.fromJson(
                    data as Map<String, dynamic>))
                .toList();
            context
                .read<InAppPurchaseProvider>()
                .changeCategoryVideo(inAppPurchaseList);
            for (int i = 0; i < inAppPurchaseList.length; i++) {
              currentIndex = i;
              productIds.add(inAppPurchaseList[i].productId!);
            }
          });
        }
      }
      setState(() {
        loading = false;
      });
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> callApi() async {
    await getInAppPurchase(Platform.isIOS ? iosApiKey : androidApiKey);
    await initializePurchase(
      productIds,
    );
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
    getUserById();
    callApi();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // inAppPurchaseProvider = context.read<InAppPurchaseProvider>();
    list = Provider.of<InAppPurchaseProvider>(context).getInAppPurchaseList;
    getIsSub = Provider.of<SettingProvider>(context).getIsSubscribe;
    createDate = Provider.of<SettingProvider>(context).getinAppCreateDate;
    expDate = Provider.of<SettingProvider>(context).getinAppExDate;
    return _connectionStatus == 'ConnectivityResult.none'
        ? NoConErrorWidget(
            onTap: () {
              setState(() {
                callApi();
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
                  Text(
                      getIsSub == 1
                          ? StringRes.yourPlan
                          : StringRes.buyMembership,
                      style: TextStyle(
                          color: Theme.of(context).secondaryHeaderColor,
                          fontWeight: FontWeight.w700,
                          fontStyle: FontStyle.normal,
                          fontSize: 16.0),
                      textAlign: TextAlign.left),
            ),
            bottomNavigationBar: getIsSub == 1
                ? const SizedBox.shrink()
                : Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Container(
                        alignment: Alignment.center,
                        height: 50,
                        width: 270,
                        child: DesignConfig.gradientButton(
                          isBlack: false,
                          isLoading: false,
                          width: 270,
                          height: 50,
                          onPress: () async {
                            await buyConsumableProducts(
                                products[selectedIndex]);
                          },
                          name: StringRes.buyNow,
                        )),
                  ),
            body: loading
                ? ShimmerNotificationWidget(
                    height: MediaQuery.of(context).size.height * .11,
                    length: 15,
                  )
                : Padding(
                    padding: const EdgeInsets.all(20),
                    child: ListView.builder(
                        itemCount: getIsSub == 1 ? 1 : list.length,
                        physics: const AlwaysScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemBuilder: (BuildContext context, int index) {
                          newList.addAll(
                              list.where((element) => element.isActive == 1));
                          item = getIsSub == 1 ? newList[index] : list[index];
                          var month = double.parse(item!.days!);
                          var month1 = (month / 30).floor();
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedIndex = index;
                              });
                            },
                            child: Container(
                                margin:
                                    const EdgeInsets.only(top: 10, bottom: 10),
                                decoration: BoxDecoration(
                                    color: SettingsLocalDataSource().theme() ==
                                            StringRes.darkThemeKey
                                        ? darkButtonDisable
                                        : backgroundColor,
                                    border: Border.all(
                                        color: selectedIndex == index
                                            ? Theme.of(context).primaryColor
                                            : Theme.of(context)
                                                .backgroundColor),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(15))),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "\$${item!.productId!}",
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .secondaryHeaderColor,
                                                fontWeight: FontWeight.w700,
                                                fontStyle: FontStyle.normal,
                                                fontSize: 24.0),
                                          ),
                                          item!.isActive == 1
                                              ? Text(
                                                  StringRes.active,
                                                  style: const TextStyle(
                                                      color: Colors.green),
                                                )
                                              : const SizedBox.shrink()
                                        ],
                                      ),
                                      item!.isActive == 1
                                          ? Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(StringRes.startOn,
                                                        style: TextStyle(
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .secondary,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            fontStyle: FontStyle
                                                                .normal,
                                                            fontSize: 14.0),
                                                        textAlign:
                                                            TextAlign.left),
                                                    Text(
                                                        getFormatedDate(
                                                                createDate
                                                                    .substring(
                                                                        0,
                                                                        10)) ??
                                                            "",
                                                        style: TextStyle(
                                                            color: Theme
                                                                    .of(context)
                                                                .colorScheme
                                                                .secondary,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            fontStyle: FontStyle
                                                                .normal,
                                                            fontSize: 14.0),
                                                        textAlign:
                                                            TextAlign.left),
                                                  ],
                                                ),
                                                SizedBox(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      .02,
                                                ),
                                                Container(
                                                  alignment: Alignment.topLeft,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .secondary,
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      .05,
                                                  width: 1,
                                                ),
                                                SizedBox(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      .02,
                                                ),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(StringRes.expOn,
                                                        style: TextStyle(
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .secondary,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            fontStyle: FontStyle
                                                                .normal,
                                                            fontSize: 14.0),
                                                        textAlign:
                                                            TextAlign.left),
                                                    Text(
                                                        getFormatedDate(expDate) ??
                                                            "",
                                                        style: TextStyle(
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .secondary,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            fontStyle: FontStyle
                                                                .normal,
                                                            fontSize: 14.0),
                                                        textAlign:
                                                            TextAlign.left),
                                                  ],
                                                ),
                                              ],
                                            )
                                          : const SizedBox.shrink(),
                                      Text(
                                          "For $month1 ${month1.toString() == "1" ? "Month" : "Months"} only",
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .secondary
                                                  .withOpacity(0.5),
                                              fontWeight: FontWeight.w400,
                                              fontStyle: FontStyle.normal,
                                              fontSize: 14.0),
                                          textAlign: TextAlign.left),
                                    ],
                                  ),
                                )),
                          );
                        }),
                  ),
          );
  }
}
