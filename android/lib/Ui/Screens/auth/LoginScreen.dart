import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:apple_sign_in_safety/apple_sign_in.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart' as fcm;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';
import 'package:videoPlus/Utils/DesignConfig.dart';
import 'package:videoPlus/Utils/StringRes.dart';

import '../../../App/Routes.dart';
import '../../../Exception/AuthException.dart';
import '../../../LocalDataStore/AuthLocalDataStore.dart';
import '../../../LocalDataStore/SettingLocalDataSource.dart';
import '../../../Provider/SettingProvider.dart';
import '../../../Utils/ColorRes.dart';
import '../../../Utils/Constant.dart';
import '../../../Utils/InternetConnectivity.dart';
import '../../../Utils/SlideAnimation.dart';
import '../../../Utils/Validators.dart';
import '../../../Utils/VideoPlusFadeInAnimation.dart';
import '../../../Utils/apiParameters.dart';
import '../../../Utils/apiUtils.dart';
import '../ErrorWidget/NoConErrorWidget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return LoginScreenState();
  }
}

class LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  TextEditingController controllerEmail = TextEditingController()
    ..addListener(() {});
  TextEditingController controllerEmailF = TextEditingController();
  TextEditingController controllerPass = TextEditingController();
  TextEditingController controllerPhone = TextEditingController();
  TextEditingController controllerOtp = TextEditingController();
  late SettingProvider settingProvider;
  final _formKey = GlobalKey<FormState>();
  final _formKeyDialog = GlobalKey<FormState>();
  final _formKeyMobileBottomSheet = GlobalKey<FormState>();
  AnimationController? _animationController;
  String _connectionStatus = 'unKnown', error = "", userVerificationId = "";
  String? selectedCountryCode;
  bool _obscureText = true,
      check = false,
      isSheetOpen = false,
      isLoadingPhone = false,
      isLoadingGmail = false,
      isLoadingLogin = false,
      isLoading = false,
      resend = false,
      codeSuccess = false,
      onComplete = false,
      isSkip = false,
      checkPhone = false;
  Timer? _timer;
  int _start = otpTimeOutSeconds;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> connectivitySubscription;
  late Function sheetSetState;
  late Function sheetSetState1;

//get user by id
  Future getUserById() async {
    try {
      final body = {
        userIdApiKey: AuthLocalDataSource.getUserId(),
      };
      final response = await post(Uri.parse(getUserByIdUrl),
          body: body, headers: await ApiUtils.getHeaders());
      final responseJson = jsonDecode(response.body);
      print("===get user by id========$responseJson");
      context
          .read<SettingProvider>()
          .changeSetIsSubscribe(responseJson["data"]["is_subscribe"] ?? 0);
      context
          .read<SettingProvider>()
          .changeInAppCreateDate(responseJson["data"]["created_at"] ?? "");
      context
          .read<SettingProvider>()
          .changeInAppExDate(responseJson["data"]["inapp_exp_date"] ?? "");
      if (responseJson['error'] == true) {
        setState(() {
          DesignConfig.setSnackbar(responseJson['message'], context, false);
        });
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  // Sign with Apple
  Future<UserCredential> signInWithApple() async {
    try {
      final AuthorizationResult appleResult =
          await AppleSignIn.performRequests([
        const AppleIdRequest(requestedScopes: [Scope.email, Scope.fullName])
      ]);

      if (appleResult.status == AuthorizationStatus.authorized) {
        final appleIdCredential = appleResult.credential!;
        final oAuthProvider = OAuthProvider('apple.com');
        final credential = oAuthProvider.credential(
          idToken: String.fromCharCodes(appleIdCredential.identityToken!),
          accessToken:
              String.fromCharCodes(appleIdCredential.authorizationCode!),
        );
        final UserCredential userCredential =
            await firebaseAuth.signInWithCredential(credential);
        // if (userCredential.additionalUserInfo!.isNewUser) {
        final user = userCredential.user!;
        final String givenName = appleIdCredential.fullName!.givenName ?? "";

        final String familyName = appleIdCredential.fullName!.familyName ?? "";
        await user.updateDisplayName("$givenName $familyName");
        await user.reload();
        //   }
        addUser(
            firebaseId: userCredential.user!.uid,
            name: userCredential.user!.displayName,
            email: userCredential.user!.email,
            mobile: userCredential.user!.phoneNumber,
            profile: userCredential.user!.photoURL,
            type: "apple");
        return userCredential;
      } else if (appleResult.status == AuthorizationStatus.error) {
        throw AuthException(errorMessageCode: defaultError);
      } else {
        throw AuthException(errorMessageCode: defaultError);
      }
    } catch (error) {
      setState(() {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(error.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0)),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          backgroundColor: Theme.of(context).primaryColor,
        ));
      });
      throw AuthException(errorMessageCode: defaultError);
    }
  }

//signIn using google account
  Future<UserCredential> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    if (googleUser == null) {
      throw AuthException(errorMessageCode: defaultError);
    }
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    setState(() {
      isLoadingGmail = true;
    });
    final UserCredential userCredential =
        await firebaseAuth.signInWithCredential(credential);
    if (userCredential.user != null) {
      addUser(
          firebaseId: userCredential.user!.uid,
          name: userCredential.user!.displayName,
          email: userCredential.user!.email,
          mobile: userCredential.user!.phoneNumber,
          profile: userCredential.user!.photoURL,
          type: gmailApiKey);
    }

    Future.delayed(const Duration(milliseconds: 100), () {
      setState(() {
        isLoadingGmail = false;
      });
    });
    return userCredential;
  }

  Future<void> resetPassword(String email) async {
    await firebaseAuth.sendPasswordResetEmail(email: email);
  }

  Future<String> getFCMToken() async {
    try {
      return await fcm.FirebaseMessaging.instance.getToken() ?? "";
    } catch (e) {
      return "";
    }
  }

//sign in with phone number
  Future signInWithPhoneNumber({required String phoneNumber}) async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      timeout: const Duration(seconds: 60),
      phoneNumber: '${selectedCountryCode!} $phoneNumber',
      verificationCompleted: (PhoneAuthCredential credential) {
        debugPrint("Phone number verified");
      },
      verificationFailed: (FirebaseAuthException e) {
        debugPrint("error is :${e.message}");
        setState(() {
          sheetSetState(() {
            sheetSetState1(() {
              DesignConfig.setSnackbar(e.message.toString(), context, false);
            });
          });
        });
        throw AuthException(errorMessageCode: defaultError);
      },
      codeSent: (String verificationId, int? resendToken) {
        debugPrint("Code sent successfully");
        setState(() {
          userVerificationId = verificationId;
        });
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

//signIn using phone number Firebase
  Future signInWithPhoneNumberFirebase(
      {required String verificationId, required String smsCode}) async {
    try {
      setState(() {
        if (mounted) {
          sheetSetState1(() {
            isLoadingPhone = true;
          });
        }
      });
      PhoneAuthCredential phoneAuthCredential = PhoneAuthProvider.credential(
          verificationId: verificationId, smsCode: smsCode);

      final UserCredential userCredential =
          await firebaseAuth.signInWithCredential(phoneAuthCredential);

      if (userCredential.user != null) {
        await addUser(
            type: mobileApiKey,
            profile: userCredential.user!.photoURL ?? "",
            mobile: userCredential.user!.phoneNumber,
            email: userCredential.user!.email ?? "",
            name: userCredential.user!.displayName ?? "",
            firebaseId: userCredential.user!.uid);
      }
      setState(() {
        sheetSetState1(() {
          isLoadingPhone = false;
        });
      });
    } catch (e) {
      error = e.toString();
      setState(() {
        sheetSetState1(() {
          isLoadingPhone = false;
          Navigator.pop(context);
          Navigator.pop(context);
        });
      });
      setState(() {
        sheetSetState1(() {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(error.toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0)),
            behavior: SnackBarBehavior.fixed,
            duration: const Duration(seconds: 3),
            backgroundColor: Theme.of(context).primaryColor,
          ));
          throw AuthException(errorMessageCode: e.toString());
        });
      });
    }
  }

  Future signInWithEmailAndPassword(
      {required String email, required String password}) async {
    try {
      setState(() {
        isLoadingLogin = true;
      });
      //sign in using email
      UserCredential userCredential = await firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);

      if (userCredential.user!.emailVerified) {
        addUser(
            firebaseId: userCredential.user!.uid,
            name: userCredential.user!.displayName,
            email: userCredential.user!.email,
            mobile: userCredential.user!.phoneNumber,
            profile: userCredential.user!.photoURL,
            type: emailApiKey);
        setState(() {
          isLoadingLogin = false;
        });
        return userCredential;
      } else {
        setState(() {
          DesignConfig.setSnackbar(StringRes.msgEmailLink, context, false);
        });
      }
    } catch (e) {
      setState(() {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0)),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          backgroundColor: Theme.of(context).primaryColor,
        ));
        isLoadingLogin = false;
      });
      throw AuthException(errorMessageCode: e.toString());
    }
  }

// Api for login and sign up
  Future addUser({
    String? firebaseId,
    String? type,
    String? name,
    String? email,
    String? profile,
    String? mobile,
  }) async {
    try {
      setState(() {
        name == guestNameApiKey ? isLoading = false : isLoading = true;
      });
      String fcmToken = await getFCMToken();
      final body = {
        firebaseIdApiKey: firebaseId,
        typeApiKey: type,
        nameApiKey: name ?? AuthLocalDataSource.getUserName(),
        emailApiKey: email ?? "",
        profileApiKey: profile ?? "",
        mobileApiKey: mobile ?? "",
        fcmIdApiKey: fcmToken,
      };
      final response = await http.post(Uri.parse(addUserUrl), body: body);
      final responseJson = jsonDecode(response.body);
      debugPrint("==sign Up or login ==:$responseJson");
      final getData = responseJson['data'];
      if (responseJson['error'] == "true") {
        setState(() {
          DesignConfig.setSnackbar(responseJson['message'], context, false);
        });
      } else {
        AuthLocalDataSource().setUserId(getData['id'].toString());
        AuthLocalDataSource().setAuthType(getData['type']).toString();
        AuthLocalDataSource().setEmail(getData['email'].toString());
        AuthLocalDataSource().setFcmId(getData['fcm_id'].toString());
        AuthLocalDataSource()
            .setUserFirebaseId(getData["firebase_id"].toString());
        AuthLocalDataSource().setUserName(getData['name'].toString());
        AuthLocalDataSource()
            .setJwtToken(responseJson['token'] ?? "")
            .toString();
        AuthLocalDataSource().setProfile(getData['profile'].toString());
        AuthLocalDataSource().setMobile(getData['mobile']).toString();
        AuthLocalDataSource().changeAuthStatus(true);

        await getUserById();
        if (mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil(
              Routes.home, (Route<dynamic> route) => false);
          /*await Navigator.of(context).pushReplacementNamed(
            Routes.home,
          );*/
        }
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0)),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          backgroundColor: Theme.of(context).primaryColor,
        ));
      });
      throw AuthException(errorMessageCode: defaultError);
    }
  }

// timer start
  void startTimer() {
    if (isSheetOpen) {
      const oneSec = Duration(seconds: 1);
      _timer = Timer.periodic(
        oneSec,
        (Timer timer) {
          if (_start == 0) {
            if (mounted) {
              sheetSetState1(() {
                resend = true;
              });
            }
          } else {
            if (mounted) {
              sheetSetState1(() {
                _start--;
              });
            }
          }
        },
      );
    }
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
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));

    super.initState();
  }

  @override
  void dispose() {
    controllerEmailF.dispose();
    controllerEmail.removeListener(() {});
    controllerEmail.dispose();
    controllerPhone.dispose();
    controllerPass.dispose();
    //controllerOtp.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    settingProvider = Provider.of<SettingProvider>(context);
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
            body: SafeArea(
              child: Container(
                height: size.height,
                width: size.width,
                margin: EdgeInsets.only(
                    left: size.width * .05, right: size.width * .05),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: size.height * .05,
                        ),
                        VideoPlusFadeInAnimation(delay: 100, child: skipBtn()),
                        SizedBox(
                          height: size.height * .03,
                        ),
                        VideoPlusFadeInAnimation(
                            delay: 100, child: loginTextTitle()),
                        SizedBox(
                          height: size.height * .005,
                        ),
                        VideoPlusFadeInAnimation(
                            delay: 150, child: loginTextSubTitle()),
                        SizedBox(
                          height: size.height * .03,
                        ),
                        VideoPlusFadeInAnimation(
                            delay: 200,
                            child: Text(StringRes.email,
                                style: TextStyle(
                                    color:
                                        Theme.of(context).secondaryHeaderColor,
                                    fontWeight: FontWeight.normal,
                                    fontStyle: FontStyle.normal,
                                    fontSize: 14.0),
                                textAlign: TextAlign.left)),
                        SizedBox(
                          height: size.height * .005,
                        ),
                        VideoPlusFadeInAnimation(
                            delay: 250, child: emailTextField()),
                        SizedBox(
                          height: size.height * .02,
                        ),
                        VideoPlusFadeInAnimation(
                            delay: 300,
                            child: Text(StringRes.pwd,
                                style: TextStyle(
                                    color:
                                        Theme.of(context).secondaryHeaderColor,
                                    fontWeight: FontWeight.normal,
                                    fontStyle: FontStyle.normal,
                                    fontSize: 14.0),
                                textAlign: TextAlign.left)),
                        SizedBox(
                          height: size.height * .005,
                        ),
                        VideoPlusFadeInAnimation(
                            delay: 350, child: passTextField()),
                        SizedBox(
                          height: size.height * .02,
                        ),
                        VideoPlusFadeInAnimation(
                            delay: 400, child: forgotPass()),
                        SizedBox(
                          height: size.height * .04,
                        ),
                        VideoPlusFadeInAnimation(delay: 800, child: loginBtn()),
                        SizedBox(
                          height: size.height * .035,
                        ),
                        VideoPlusFadeInAnimation(
                            delay: 450, child: createAcc()),
                        SizedBox(
                          height: size.height * .035,
                        ),
                        VideoPlusFadeInAnimation(
                            delay: 500, child: continueText()),
                        SizedBox(
                          height: size.height * .035,
                        ),
                        VideoPlusFadeInAnimation(
                            delay: 550, child: socialMedia(size)),
                        SizedBox(
                          height: size.height * .035,
                        ),
                        VideoPlusFadeInAnimation(
                            delay: 650, child: termAndPolicy()),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
  }

  Widget skipBtn() {
    return Align(
      alignment: Alignment.topRight,
      child: InkWell(
        onTap: () async {
          if (isSkip) return;
          setState(() {
            isSkip = true;
          });
          await addUser(
              type: guestNameApiKey,
              email: "guest@gmail.com",
              firebaseId: guestNameApiKey,
              mobile: "",
              name: guestNameApiKey,
              profile: "");
          setState(() {
            isSkip = false;
          });
        },
        onDoubleTap: () {},
        child: Container(
          width: 74.25,
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(15)),
              color: Theme.of(context).primaryColor.withOpacity(0.1)),
          child: isSkip
              ? CircularProgressIndicator(
                  color: Theme.of(context).primaryColor,
                )
              : Text(
                  StringRes.skip,
                  style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w700,
                      fontStyle: FontStyle.normal,
                      fontSize: 14.0),
                ),
        ),
      ),
    );
  }

  Widget loginTextTitle() {
    return Text(StringRes.loginTitle,
        style: TextStyle(
            color: Theme.of(context).secondaryHeaderColor,
            fontWeight: FontWeight.normal,
            // fontStyle: FontStyle.normal,
            fontSize: 28.0),
        textAlign: TextAlign.left);
  }

  Widget loginTextSubTitle() {
    return Text(StringRes.loginSubTitle,
        style: TextStyle(
            color: Theme.of(context).hintColor,
            height: 1,
            fontWeight: FontWeight.normal,
            fontStyle: FontStyle.normal,
            fontSize: 20.0),
        textAlign: TextAlign.left);
  }

  Widget emailTextField() {
    return TextFormField(
      validator: (input) => Validators.validateEmail(
          input!, StringRes.emailEmpty, StringRes.inValidEmail),
      controller: controllerEmail,
      cursorColor: const Color(0xffa2a2a2),
      style: TextStyle(color: Theme.of(context).secondaryHeaderColor),
      onChanged: (text) {
        setState(() {
          controllerEmail.text;
        });
      },
      decoration: InputDecoration(
        filled: true,
        fillColor: Theme.of(context).colorScheme.primary,
        prefixIcon: Padding(
          padding: const EdgeInsets.all(10),
          child: SvgPicture.asset(
            DesignConfig.getIconPath(
              "icon_email.svg",
            ),
            color: controllerEmail.text.isNotEmpty
                ? Theme.of(context).primaryColor
                : SettingsLocalDataSource().theme() == StringRes.darkThemeKey
                    ? Theme.of(context).colorScheme.secondary
                    : Theme.of(context).colorScheme.secondary.withOpacity(0.4),
          ),
        ),
        hintText: StringRes.hintEmail,
        contentPadding: const EdgeInsets.only(top: 15, bottom: 15),
        hintStyle: TextStyle(
            color: Theme.of(context).hintColor,
            fontWeight: FontWeight.w400,
            fontStyle: FontStyle.normal,
            fontSize: 16.0),
        focusedBorder: DesignConfig.textFieldBorder(context: context),
        focusedErrorBorder: DesignConfig.textFieldBorder(context: context),
        errorBorder: DesignConfig.textFieldBorder(context: context),
        enabledBorder: DesignConfig.textFieldBorder(context: context),
      ),
      keyboardType: TextInputType.emailAddress,
    );
  }

// here only is empty check validator
  Widget passTextField() {
    return TextFormField(
      obscureText: _obscureText,
      obscuringCharacter: "*",
      //autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (input) => input!.isEmpty ? StringRes.msgEnterValidPWD : null,
      controller: controllerPass,
      style: TextStyle(color: Theme.of(context).secondaryHeaderColor),
      onChanged: (data) {
        setState(() {
          controllerPass.text;
        });
      },
      cursorColor: const Color(0xffa2a2a2),
      decoration: InputDecoration(
        filled: true,
        fillColor: Theme.of(context).colorScheme.primary,
        prefixIcon: Padding(
            padding: const EdgeInsets.all(10),
            child: SvgPicture.asset(
              DesignConfig.getIconPath("icon_password.svg"),
              color: controllerPass.text.isNotEmpty
                  ? Theme.of(context).primaryColor
                  : SettingsLocalDataSource().theme() == StringRes.darkThemeKey
                      ? Theme.of(context).colorScheme.secondary
                      : Theme.of(context)
                          .colorScheme
                          .secondary
                          .withOpacity(0.4),
            )),
        contentPadding: const EdgeInsets.only(top: 15, bottom: 15),
        suffixIcon: IconButton(
          icon: Padding(
            padding: const EdgeInsets.all(5.0),
            child: SvgPicture.asset(
              _obscureText
                  ? DesignConfig.getIconPath("icon_close_eye.svg")
                  : DesignConfig.getIconPath("icon_open_eye.svg"),
              color: controllerPass.text.isNotEmpty
                  ? Theme.of(context).primaryColor
                  : SettingsLocalDataSource().theme() == StringRes.darkThemeKey
                      ? Theme.of(context).colorScheme.secondary
                      : Theme.of(context)
                          .colorScheme
                          .secondary
                          .withOpacity(0.4),
            ),
          ),
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
        ),
        hintText: StringRes.hintPass,
        hintStyle: TextStyle(
            color: Theme.of(context).hintColor,
            fontWeight: FontWeight.w400,
            fontStyle: FontStyle.normal,
            fontSize: 16.0),
        focusedBorder: DesignConfig.textFieldBorder(context: context),
        focusedErrorBorder: DesignConfig.textFieldBorder(context: context),
        errorBorder: DesignConfig.textFieldBorder(context: context),
        enabledBorder: DesignConfig.textFieldBorder(context: context),
      ),
    );
  }

  Widget forgotPass() {
    return Align(
      alignment: Alignment.topRight,
      child: InkWell(
        onTap: () {
          showModalBottomSheet(
              elevation: 0,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                topLeft: Radius.circular(50.0),
                topRight: Radius.circular(50.0),
              )),
              context: context,
              builder: (context) => forgotPassBottomSheet()).whenComplete(() {
            controllerEmailF.text = "";
          });
        },
        child: Text(
          StringRes.forgotPwd,
          style: TextStyle(
              decoration: TextDecoration.underline,
              color: Theme.of(context).secondaryHeaderColor,
              fontWeight: FontWeight.normal,
              fontStyle: FontStyle.normal,
              fontSize: 14.0),
        ),
      ),
    );
  }

  Widget continueText() {
    return Align(
      alignment: Alignment.center,
      child: Text(StringRes.continueWithText,
          style: TextStyle(
              color: Theme.of(context).secondaryHeaderColor,
              fontWeight: FontWeight.w500,
              fontStyle: FontStyle.normal,
              fontSize: 18.0),
          textAlign: TextAlign.left),
    );
  }

  Widget socialMedia(dynamic size) {
    return isLoadingGmail || isLoading
        ? Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).primaryColor,
            ),
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SlideAnimation(
                  position: 10,
                  itemCount: 20,
                  slideDirection: SlideDirection.fromLeft,
                  animationController: _animationController,
                  child: InkWell(
                    onTap: () {
                      if (check) {
                        signInWithGoogle();
                      } else {
                        setState(() {
                          DesignConfig.setSnackbar(
                              StringRes.msgTerm, context, false);
                        });
                      }
                    },
                    child: Container(
                      height: 45,
                      width: 45,
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: Theme.of(context).primaryColor, width: 1),
                      ),
                      child: SvgPicture.asset(
                          DesignConfig.getIconPath("google.svg")),
                    ),
                  )),
              SizedBox(
                width: size.width * .04,
              ),
              Platform.isIOS
                  ? SlideAnimation(
                      position: 10,
                      itemCount: 20,
                      slideDirection: SlideDirection.fromBottom,
                      animationController: _animationController,
                      child: InkWell(
                        onTap: () {
                          if (check) {
                            signInWithApple();
                          } else {
                            setState(() {
                              DesignConfig.setSnackbar(
                                  StringRes.msgTerm, context, false);
                            });
                          }
                        },
                        child: Container(
                            height: 45,
                            width: 45,
                            padding: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: Theme.of(context).primaryColor,
                                  width: 1),
                            ),
                            child: SvgPicture.asset(
                              DesignConfig.getIconPath("apple.svg"),
                              color: Theme.of(context).colorScheme.onBackground,
                            )),
                      ))
                  : Container(),
              SizedBox(
                width: size.width * .04,
              ),
              SlideAnimation(
                position: 10,
                itemCount: 20,
                slideDirection: SlideDirection.fromRight,
                animationController: _animationController,
                child: InkWell(
                    onTap: () {
                      if (check) {
                        showModalBottomSheet(
                                elevation: 0,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(50.0),
                                  topRight: Radius.circular(50.0),
                                )),
                                context: context,
                                builder: (context) => phoneLoginBottomSheet())
                            .whenComplete(() {
                          controllerPhone.text = "";
                        });
                      } else {
                        setState(() {
                          DesignConfig.setSnackbar(
                              StringRes.msgTerm, context, false);
                        });
                      }
                    },
                    child: Container(
                        height: 45,
                        width: 45,
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: Theme.of(context).primaryColor, width: 1),
                        ),
                        child: SvgPicture.asset(
                          DesignConfig.getIconPath("phone.svg"),
                          color: Theme.of(context).colorScheme.onBackground,
                        ))),
              )
            ],
          );
  }

  Widget loginBtn() {
    return Align(
      alignment: Alignment.center,
      child: controllerPass.text.isNotEmpty && controllerEmail.text.isNotEmpty
          ? DesignConfig.gradientButton(
              isBlack: false,
              isLoading: isLoadingLogin,
              width: 270,
              height: 50,
              onPress: () {
                if (check) {
                  if (_formKey.currentState!.validate()) {
                    signInWithEmailAndPassword(
                        email: controllerEmail.text,
                        password: controllerPass.text);
                  }
                } else {
                  setState(() {
                    DesignConfig.setSnackbar(StringRes.msgTerm, context, false);
                  });
                }
              },
              name: StringRes.login,
            )
          : Align(
              alignment: Alignment.center,
              child: Container(
                width: 270,
                height: 50,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(25)),
                    border:
                        Border.all(color: const Color(0x00000000), width: 1),
                    gradient: LinearGradient(
                        begin: const Alignment(-0.022495072335004807, 1),
                        end: const Alignment(
                            1.1026651859283447, -0.5471386909484863),
                        colors: [
                          const Color(0xff415fff).withOpacity(0.5),
                          const Color(0xff08dcff).withOpacity(0.5)
                        ])),
                child: const Text(StringRes.login,
                    style: TextStyle(
                        color: Color(0xffffffff),
                        fontWeight: FontWeight.w700,
                        fontStyle: FontStyle.normal,
                        fontSize: 18.0),
                    textAlign: TextAlign.center),
              ),
            ),
    );
  }

  Widget createAcc() {
    return Align(
      alignment: Alignment.center,
      child: InkWell(
        onTap: () {
          Navigator.of(context).pushNamed(Routes.signUp, arguments: false);
        },
        child: RichText(
            text: TextSpan(children: [
          TextSpan(
              style: TextStyle(
                  color: Theme.of(context).secondaryHeaderColor,
                  fontWeight: FontWeight.w400,
                  fontStyle: FontStyle.normal,
                  fontSize: 14.0),
              text: "${StringRes.newUser} "),
          TextSpan(
              style: TextStyle(
                  decoration: TextDecoration.underline,
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w500,
                  fontStyle: FontStyle.normal,
                  fontSize: 14.0),
              text: StringRes.createAcc)
        ])),
      ),
    );
  }

  Widget termAndPolicy() {
    return Container(
      alignment: Alignment.topLeft,
      child: ListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          horizontalTitleGap: 5,
          leading: Checkbox(
              value: check,
              activeColor: Theme.of(context).primaryColor,
              side: MaterialStateBorderSide.resolveWith(
                (states) => BorderSide(
                    width: 1.0,
                    color: check
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).secondaryHeaderColor),
              ),
              onChanged: (value) {
                setState(() {
                  check = !check;
                });
              }),
          title: RichText(
              maxLines: 2,
              text: TextSpan(children: [
                TextSpan(
                    style: TextStyle(
                        color: Theme.of(context).secondaryHeaderColor,
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.normal,
                        fontSize: 12.0),
                    text: StringRes.agreement),
                TextSpan(
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.pushNamed(context, Routes.aboutUs,
                            arguments: {
                              'title': StringRes.termsCondition,
                              'type': termApiKey
                            });
                      },
                    style: TextStyle(
                        decoration: TextDecoration.underline,
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w500,
                        fontStyle: FontStyle.normal,
                        fontSize: 12.0),
                    text: StringRes.teamsOfService),
                TextSpan(
                    style: TextStyle(
                        color: Theme.of(context).secondaryHeaderColor,
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.normal,
                        fontSize: 12.0),
                    text: " & "),
                TextSpan(
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.pushNamed(context, Routes.aboutUs,
                            arguments: {
                              'title': StringRes.privacyPolicy,
                              'type': ppApiKey
                            });
                      },
                    style: TextStyle(
                        decoration: TextDecoration.underline,
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w500,
                        fontStyle: FontStyle.normal,
                        fontSize: 12.0),
                    text: StringRes.privacyPolicy)
              ]))),
    );
  }

  Widget forgotPassBottomSheet() {
    return commonBottomSheetDesign(
        child: Form(
      key: _formKeyDialog,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * .03,
          ),
          bottomSheetTitle(title: StringRes.forgotPwd),
          SizedBox(
            height: MediaQuery.of(context).size.height * .01,
          ),
          bottomSheetSubTitle(subTitle: StringRes.resetLink),
          SizedBox(
            height: MediaQuery.of(context).size.height * .03,
          ),
          TextFormField(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (input) => Validators.validateEmail(
                input!, StringRes.emailEmpty, StringRes.inValidEmail),
            controller: controllerEmailF,
            cursorColor: const Color(0xffa2a2a2),
            style: TextStyle(color: Theme.of(context).secondaryHeaderColor),
            onChanged: (text) {
              setState(() {
                text;
              });
            },
            decoration: InputDecoration(
              fillColor:
                  SettingsLocalDataSource().theme() == StringRes.darkThemeKey
                      ? darkButtonDisable
                      : Theme.of(context).scaffoldBackgroundColor,
              filled: true,
              prefixIcon: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SvgPicture.asset(
                  DesignConfig.getIconPath("icon_email.svg"),
                  color: controllerEmailF.text.isNotEmpty
                      ? Theme.of(context).primaryColor
                      : Theme.of(context)
                          .colorScheme
                          .secondary
                          .withOpacity(0.4),
                ),
              ),
              contentPadding: const EdgeInsets.only(top: 15, bottom: 15),
              hintText: StringRes.hintEmail,
              hintStyle: TextStyle(
                  color:
                      Theme.of(context).colorScheme.secondary.withOpacity(0.4),
                  fontWeight: FontWeight.w400,
                  fontStyle: FontStyle.normal,
                  fontSize: 16.0),
              focusedBorder: DesignConfig.textFieldBorder(context: context),
              focusedErrorBorder:
                  DesignConfig.textFieldBorder(context: context),
              errorBorder: DesignConfig.textFieldBorder(context: context),
              enabledBorder: DesignConfig.textFieldBorder(context: context),
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * .041,
          ),
          Align(
            alignment: Alignment.center,
            child: controllerEmailF.text.isNotEmpty
                ? DesignConfig.gradientButton(
                    width: 131,
                    height: 44,
                    onPress: () {
                      if (_formKeyDialog.currentState!.validate()) {
                        _formKeyDialog.currentState!.save();
                        DesignConfig.setSnackbar(
                            StringRes.resetPassLink, context, false);
                        resetPassword(controllerEmailF.text.trim());
                        Future.delayed(const Duration(seconds: 1), () {
                          Navigator.pop(context, 'Cancel');
                        });
                      }
                    },
                    name: StringRes.sendLink,
                    isBlack: true,
                  )
                : Container(
                    width: 131,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(25)),
                        border: Border.all(
                            color: const Color(0x00000000), width: 1),
                        gradient: LinearGradient(
                            begin: const Alignment(-0.022495072335004807, 1),
                            end: const Alignment(
                                1.1026651859283447, -0.5471386909484863),
                            colors: [
                              const Color(0xff415fff).withOpacity(0.5),
                              const Color(0xff08dcff).withOpacity(0.5)
                            ])),
                    child: const Text(StringRes.sendLink,
                        style: TextStyle(
                            color: Color(0xffffffff),
                            fontWeight: FontWeight.w700,
                            fontStyle: FontStyle.normal,
                            fontSize: 16.0),
                        textAlign: TextAlign.center),
                  ),
          )
        ],
      ),
    ));
  }

  Widget _buildMobileNumberWithCountryCode() {
    return IntlPhoneField(
      controller: controllerPhone,
      initialCountryCode: initialCountryCode,
      style: TextStyle(color: Theme.of(context).secondaryHeaderColor),
      dropdownTextStyle:
          TextStyle(color: Theme.of(context).secondaryHeaderColor),
      pickerDialogStyle: PickerDialogStyle(
          countryCodeStyle:
              TextStyle(color: Theme.of(context).secondaryHeaderColor),
          countryNameStyle:
              TextStyle(color: Theme.of(context).secondaryHeaderColor),
          searchFieldCursorColor: Theme.of(context).hintColor,
          searchFieldInputDecoration: const InputDecoration()),
      cursorColor: Theme.of(context).hintColor,
      decoration: InputDecoration(
        filled: true,
        fillColor: Theme.of(context).colorScheme.primary,
        contentPadding: const EdgeInsets.only(top: 15, bottom: 15),
        focusedBorder: DesignConfig.textFieldBorder(context: context),
        focusedErrorBorder: DesignConfig.textFieldBorder(context: context),
        errorBorder: DesignConfig.textFieldBorder(context: context),
        enabledBorder: DesignConfig.textFieldBorder(context: context),
        hintStyle: TextStyle(
          color: Theme.of(context).hintColor,
        ),
        hintText: StringRes.hintMobile,
      ),
      onChanged: (phone) {
        setState(() {
          sheetSetState(() {
            selectedCountryCode = phone.countryCode.toString();
            controllerPhone.text;
            debugPrint("onchange.....................${controllerPhone.text}");
          });
        });
      },
    );
  }

  Widget phoneLoginBottomSheet() {
    return commonBottomSheetDesign(
        child: Form(
      key: _formKeyMobileBottomSheet,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * .03,
          ),
          bottomSheetTitle(title: StringRes.phoneTitle),
          SizedBox(
            height: MediaQuery.of(context).size.height * .02,
          ),
          bottomSheetSubTitle(subTitle: StringRes.phoneSubTitle),
          SizedBox(
            height: MediaQuery.of(context).size.height * .03,
          ),
          _buildMobileNumberWithCountryCode(),
          SizedBox(
            height: MediaQuery.of(context).size.height * .041,
          ),
          Align(
              alignment: Alignment.center,
              child: DesignConfig.gradientButton(
                isBlack: true,
                width: 131,
                height: 44,
                onPress: () async {
                  if (_formKeyMobileBottomSheet.currentState!.validate()) {
                    await signInWithPhoneNumber(
                        phoneNumber: controllerPhone.text);
                    isSheetOpen = true;
                    startTimer();
                    showModalBottomSheet(
                        elevation: 0,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(50.0),
                          topRight: Radius.circular(50.0),
                        )),
                        context: context,
                        builder: (context) {
                          return verifyOtpBottomSheet();
                        }).whenComplete(() {
                      controllerOtp.dispose();
                      //controllerOtp = TextEditingController();
                      _timer!.cancel();
                      _start = otpTimeOutSeconds;
                      isSheetOpen = false;
                    }); /*.then((value) {
                      //SHEET IS CLOSED
                      _start = 0;
                      _start = otpTimeOutSeconds;
                      isSheetOpen = false;
                    });*/
                  } else {
                    DesignConfig.setSnackbar(
                        StringRes.msgMobileValidate, context, false);
                  }
                },
                name: StringRes.sendOtpBtn,
              ))
        ],
      ),
    ));
  }

  Widget verifyOtpBottomSheet() {
    return Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setStater) {
          sheetSetState1 = setStater;
          return Container(
              height: MediaQuery.of(context).size.height * .41,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                  color: Theme.of(context).backgroundColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20.0),
                    topRight: Radius.circular(20.0),
                  )),
              child: Container(
                  margin: EdgeInsets.only(
                      left: MediaQuery.of(context).size.width * .06,
                      right: MediaQuery.of(context).size.width * .06),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * .035,
                        ),
                        bottomSheetTitle(title: StringRes.verifyOtpTitle),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * .02,
                        ),
                        bottomSheetSubTitle(
                            subTitle: StringRes.verifyOtpSunTitle +
                                selectedCountryCode! +
                                controllerPhone.text.trim()),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * .035,
                        ),
                        PinCodeTextField(
                          appContext: context,
                          length: 6,
                          hintCharacter: "0",
                          textStyle: TextStyle(
                              color: Theme.of(context).secondaryHeaderColor),
                          hintStyle: TextStyle(
                              color: Theme.of(context).hintColor,
                              fontWeight: FontWeight.w400,
                              fontStyle: FontStyle.normal,
                              fontSize: 14.0),
                          blinkWhenObscuring: true,
                          animationType: AnimationType.fade,
                          pinTheme: PinTheme(
                            shape: PinCodeFieldShape.underline,
                            fieldWidth: 50,
                            borderWidth: 1,
                            inactiveFillColor:
                                Theme.of(context).backgroundColor,
                            activeColor: Theme.of(context).primaryColor,
                            selectedColor: Theme.of(context).primaryColor,
                            selectedFillColor:
                                Theme.of(context).backgroundColor,
                            inactiveColor: Theme.of(context).primaryColor,
                            activeFillColor: Theme.of(context).backgroundColor,
                          ),
                          cursorColor: Theme.of(context).secondaryHeaderColor,
                          animationDuration: const Duration(milliseconds: 300),
                          enableActiveFill: true,
                          controller: controllerOtp,
                          keyboardType: TextInputType.number,
                          onCompleted: (v) {
                            setState(() {
                              setStater(() {
                                onComplete = true;
                              });
                            });
                            debugPrint("Completed");
                          },
                          onChanged: (value) {
                            debugPrint(value);
                            setState(() {});
                          },
                          beforeTextPaste: (text) {
                            return true;
                          },
                        ),
                        timerText(),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * .003,
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: onComplete
                              ? DesignConfig.gradientButton(
                                  isBlack: true,
                                  width: 131,
                                  height: 44,
                                  isLoading: isLoadingPhone,
                                  onPress: () async {
                                    if (isLoadingPhone) return;
                                    _timer!.cancel();
                                    await signInWithPhoneNumberFirebase(
                                        smsCode: controllerOtp.text,
                                        verificationId: userVerificationId);
                                  },
                                  name: StringRes.verify,
                                )
                              : Container(
                                  width: 131,
                                  height: 44,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(25)),
                                      border: Border.all(
                                          color: const Color(0x00000000),
                                          width: 1),
                                      gradient: LinearGradient(
                                          begin: const Alignment(
                                              -0.022495072335004807, 1),
                                          end: const Alignment(
                                              1.1026651859283447,
                                              -0.5471386909484863),
                                          colors: [
                                            const Color(0xff415fff)
                                                .withOpacity(0.5),
                                            const Color(0xff08dcff)
                                                .withOpacity(0.5)
                                          ])),
                                  child: const Text(StringRes.verify,
                                      style: TextStyle(
                                          color: Color(0xffffffff),
                                          fontWeight: FontWeight.w700,
                                          fontStyle: FontStyle.normal,
                                          fontSize: 18.0),
                                      textAlign: TextAlign.center),
                                ),
                        )
                      ])));
        }));
  }

  Widget bottomSheetTitle({required String title}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: Text(title,
              style: TextStyle(
                  color: Theme.of(context).secondaryHeaderColor,
                  fontWeight: FontWeight.w700,
                  fontStyle: FontStyle.normal,
                  fontSize: 18.0),
              textAlign: TextAlign.left),
        ),
        InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Align(
            alignment: Alignment.topRight,
            child: Container(
              height: 30,
              width: 30,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xffb9b9b9),
                  )),
              child: const Icon(
                Icons.close,
                color: Color(0xffb9b9b9),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget bottomSheetSubTitle({required String subTitle}) {
    return Text(subTitle,
        style: TextStyle(
            color: Theme.of(context).hintColor,
            fontWeight: FontWeight.w400,
            fontStyle: FontStyle.normal,
            fontSize: 14.0),
        textAlign: TextAlign.left);
  }

  Widget timerText() {
    return Align(
      alignment: Alignment.center,
      child: GestureDetector(
        onTap: () {
          if (resend == true) {
            setState(() {
              _timer!.cancel();
              resend = false;
              codeSuccess = true;
              signInWithPhoneNumber(phoneNumber: controllerPhone.text);
            });
          }
        },
        child: Text(
            resend
                ? StringRes.resendCode
                : codeSuccess
                    ? StringRes.codeSuccessText
                    : "00:$_start",
            style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w500,
                fontStyle: FontStyle.normal,
                fontSize: 14.0),
            textAlign: TextAlign.left),
      ),
    );
  }

  Widget commonBottomSheetDesign({required Widget child}) {
    return Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: StatefulBuilder(builder: (BuildContext context,
            StateSetter setStater /*You can rename this! */) {
          sheetSetState = setStater;
          return Container(
              height: MediaQuery.of(context).size.height * .41,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                  color: Theme.of(context).backgroundColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20.0),
                    topRight: Radius.circular(20.0),
                  )),
              child: Container(
                  margin: EdgeInsets.only(
                      left: MediaQuery.of(context).size.width * .06,
                      right: MediaQuery.of(context).size.width * .06),
                  child: child));
        }));
  }
}
