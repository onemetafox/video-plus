import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:provider/provider.dart';
import 'package:videoPlus/Provider/saveVideoListProvider.dart';
import 'package:videoPlus/Utils/DesignConfig.dart';
import 'package:wakelock/wakelock.dart';

import 'App/Routes.dart';
import 'LocalDataStore/SettingLocalDataSource.dart';
import 'Provider/SettingProvider.dart';
import 'Provider/ThemeProvider.dart';
import 'Provider/categoryProvider.dart';
import 'Provider/categoryVideoProvider.dart';
import 'Provider/inAppPurchaseProvider.dart';
import 'Provider/videoHistoryProvider.dart';
import 'Utils/ColorRes.dart';
import 'Utils/Constant.dart';
import 'Utils/PushNotification.dart';
import 'Utils/StringRes.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Wakelock.enable();
  // if (Firebase.apps.isNotEmpty) {
  //   await Firebase.initializeApp(
  //     options: DefaultFirebaseOptions.currentPlatform,
  //   );
  // } else {
  //   await Firebase.initializeApp();
  // }
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await Hive.initFlutter();
  await Hive.openBox(authBox);
  await Hive.openBox(userDetailsBox);
  await Hive.openBox(settingsBox);
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness:
        DesignConfig.isDark ? Brightness.light : Brightness.dark,

    // status bar color
  ));
  // final pushNotificationService = PushNotificationService(firebaseMessaging);
  // pushNotificationService.initialise();

  //set test device for admob ads
  /* RequestConfiguration configuration =
      RequestConfiguration(testDeviceIds: ["4B704FDDDBF8B0C282C54018BB513B4E"]);
  MobileAds.instance.updateRequestConfiguration(configuration); */

  runApp(ChangeNotifierProvider<ThemeNotifier>(
      create: (BuildContext context) {
        String? theme = SettingsLocalDataSource().theme();

        if (theme == StringRes.darkThemeKey) {
          ISDARK = "true";
        } else {
          ISDARK = "false";
        }
        var brightness = SchedulerBinding.instance.window.platformBrightness;
        ISDARK = (brightness == Brightness.dark).toString();
        return ThemeNotifier(theme == StringRes.lightThemeKey
            ? ThemeMode.light
            : ThemeMode.dark);
      },
      child: const MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return Shortcuts(
        shortcuts: <LogicalKeySet, Intent>{
          LogicalKeySet(LogicalKeyboardKey.select): const ActivateIntent(),
        },
        child: MultiProvider(
            providers: [
              ChangeNotifierProvider(
                create: (_) => SettingProvider(),
              ),
              ChangeNotifierProvider(
                create: (_) => SaveVideoProvider(),
              ),
              ChangeNotifierProvider(
                create: (_) => CategoryVideoProvider(),
              ),
              ChangeNotifierProvider(
                create: (_) => InAppPurchaseProvider(),
              ),
              ChangeNotifierProvider(
                create: (_) => CategoryProvider(),
              ),
              ChangeNotifierProvider(
                create: (_) => VideoHistoryProvider(),
              ),
            ],
            child: MaterialApp(
              builder: (context, widget) {
                return Directionality(
                    textDirection:
                        TextDirection.ltr, // set here your text direction
                    child: ScrollConfiguration(
                        behavior: GlobalScrollBehavior(), child: widget!));
              },
              title: appName,
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                      shadowColor: primaryColor.withOpacity(0.25),
                      brightness: Brightness.light,
                      primaryColor: primaryColor,
                      scaffoldBackgroundColor: scaffoldBackgroundColor,
                      backgroundColor: backgroundColor,
                      // canvasColor: blackColor,
                      secondaryHeaderColor:
                          blackColor, //used for Font/Text color
                      hintColor: iconHintColor,
                      bottomSheetTheme: const BottomSheetThemeData(
                          backgroundColor: Colors.transparent),
                      colorScheme: ThemeData().colorScheme.copyWith(
                          onPrimary: borderColor,
                          onBackground: blackColor,
                          secondary: secondaryColor,
                          background: buttonDisable,
                          primary: backgroundColor))
                  .copyWith(
                textTheme:
                    GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
              ),
              darkTheme: ThemeData(
                      shadowColor: darkPrimaryColor.withOpacity(0.25),
                      brightness: Brightness.dark,
                      primaryColor: darkPrimaryColor,
                      scaffoldBackgroundColor: darkScaffoldBackgroundColor,
                      backgroundColor: darkBackgroundColor,
                      // canvasColor: darkBlackColor,
                      secondaryHeaderColor:
                          darkBlackColor, //used for Font/Text color
                      hintColor: darkIconHint,
                      bottomSheetTheme: const BottomSheetThemeData(
                          backgroundColor: Colors.transparent),
                      colorScheme: ThemeData().colorScheme.copyWith(
                          brightness: Brightness.dark,
                          onPrimary: darkborderColor,
                          onBackground: darkBlackColor,
                          secondary: darkIconHint,
                          background: darkButtonDisable,
                          primary: darkButtonDisable))
                  .copyWith(
                textTheme:
                    GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
              ),
              themeMode: themeNotifier.getThemeMode(),
              initialRoute: Routes.splash,
              onGenerateRoute: Routes.onGenerateRoute,
            )));
  }
}

class GlobalScrollBehavior extends ScrollBehavior {
  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const BouncingScrollPhysics();
  }
}
