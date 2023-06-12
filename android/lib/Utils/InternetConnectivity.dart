import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/services.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class InternetConnectivity {
  static Future<bool> isUserOffline() async {
    final ConnectivityResult connectivityResult =
        await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      return true;
    } else {
      final hasConnection = await InternetConnectionChecker().hasConnection;
      return !hasConnection;
    }
  }
}

class CheckInternet {
  static final Connectivity _connectivity = Connectivity();

  static String _connectionStatus = 'Unknown';

  static Future<String> initConnectivity() async {
    ConnectivityResult result = ConnectivityResult.none;
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException {}
    return updateConnectionStatus(result);
  }

  static Future<String> updateConnectionStatus(
      ConnectivityResult result) async {
    switch (result) {
      case ConnectivityResult.wifi:
      case ConnectivityResult.mobile:
      case ConnectivityResult.none:
        _connectionStatus = result.toString();
        return _connectionStatus;
      // break;
      default:
        _connectionStatus = 'Failed to get connectivity.';
        return _connectionStatus;
      // break;
    }
  }
}
