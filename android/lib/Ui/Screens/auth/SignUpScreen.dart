import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:videoPlus/LocalDataStore/AuthLocalDataStore.dart';

import '../../../App/Routes.dart';
import '../../../Exception/AuthException.dart';
import '../../../LocalDataStore/SettingLocalDataSource.dart';
import '../../../Utils/DesignConfig.dart';
import '../../../Utils/InternetConnectivity.dart';
import '../../../Utils/StringRes.dart';
import '../../../Utils/Validators.dart';
import '../../../Utils/VideoPlusFadeInAnimation.dart';
import '../ErrorWidget/NoConErrorWidget.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return SignUpScreenState();
  }
}

class SignUpScreenState extends State<SignUpScreen>
    with TickerProviderStateMixin {
  TextEditingController controllerFullName = TextEditingController();
  TextEditingController controllerEmail = TextEditingController();
  TextEditingController controllerPass = TextEditingController();
  TextEditingController controllerCngPass = TextEditingController();
  AnimationController? animationController;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  String _connectionStatus = 'unKnown';
  final Connectivity _connectivity = Connectivity();
  final _formKey = GlobalKey<FormState>();

  late StreamSubscription<ConnectivityResult> connectivitySubscription;
  bool _obscureText = true,
      _obscureText1 = true,
      check = false,
      isLoading = false;
  //create user account
  Future<void> signUpUser(
      {required String email, required String password}) async {
    try {
      setState(() {
        isLoading = true;
      });
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);
      //verify email address
      await userCredential.user!.sendEmailVerification();
      setState(() {
        isLoading = false;
      });
      DesignConfig.setSnackbar(
          "${StringRes.msgVerifyEmail} $email", context, false);
      Timer(const Duration(seconds: 1), () {
        Navigator.pop(context);
      });
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
      print(e.toString());
      throw AuthException(errorMessageCode: e.toString());
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
    animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    super.initState();
  }

  @override
  void dispose() {
    controllerFullName.dispose();
    controllerEmail.dispose();
    controllerPass.dispose();
    controllerCngPass.dispose();
    super.dispose();
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
                              height: size.height * .04,
                            ),
                            VideoPlusFadeInAnimation(
                                delay: 100, child: backBtn()),
                            SizedBox(
                              height: size.height * .05,
                            ),
                            VideoPlusFadeInAnimation(
                                delay: 150, child: createText()),
                            SizedBox(
                              height: size.height * .02,
                            ),
                            VideoPlusFadeInAnimation(
                                delay: 200, child: commonName(StringRes.name)),
                            SizedBox(
                              height: size.height * .005,
                            ),
                            VideoPlusFadeInAnimation(
                                delay: 250, child: fullName()),
                            SizedBox(
                              height: size.height * .02,
                            ),
                            VideoPlusFadeInAnimation(
                                delay: 300, child: commonName(StringRes.email)),
                            SizedBox(
                              height: size.height * .005,
                            ),
                            VideoPlusFadeInAnimation(
                                delay: 350, child: emailTextField()),
                            SizedBox(
                              height: size.height * .02,
                            ),
                            VideoPlusFadeInAnimation(
                                delay: 400, child: commonName(StringRes.pwd)),
                            SizedBox(
                              height: size.height * .005,
                            ),
                            VideoPlusFadeInAnimation(
                                delay: 450, child: passTextField()),
                            SizedBox(
                              height: size.height * .02,
                            ),
                            VideoPlusFadeInAnimation(
                                delay: 500,
                                child: commonName(StringRes.hintCnfPwd)),
                            SizedBox(
                              height: size.height * .005,
                            ),
                            VideoPlusFadeInAnimation(
                                delay: 550, child: cnfPassTextField()),
                            SizedBox(
                              height: size.height * .0325,
                            ),
                            VideoPlusFadeInAnimation(
                                delay: 600, child: termAndPolicy()),
                            SizedBox(
                              height: size.height * .04,
                            ),
                            VideoPlusFadeInAnimation(
                                delay: 650, child: signUpBtn()),
                            SizedBox(
                              height: size.height * .04,
                            ),
                            VideoPlusFadeInAnimation(
                                delay: 700, child: alreadyAccText()),
                          ]),
                    )))));
  }

  Widget backBtn() {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
      },
      child: Container(
        width: 45,
        height: 45,
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).colorScheme.background),
        child: Icon(
          Icons.close,
          color: Theme.of(context).secondaryHeaderColor,
        ),
      ),
    );
  }

  Widget createText() {
    return Text(StringRes.signUp,
        style: TextStyle(
            color: Theme.of(context).secondaryHeaderColor,
            fontWeight: FontWeight.w700,
            fontStyle: FontStyle.normal,
            fontSize: 30.0),
        textAlign: TextAlign.left);
  }

  Widget fullName() {
    return TextFormField(
      validator: (input) => input!.isEmpty ? StringRes.msgEnterFullName : null,
      controller: controllerFullName,
      cursorColor: const Color(0xffa2a2a2),
      style: TextStyle(color: Theme.of(context).secondaryHeaderColor),
      onChanged: (text) {
        setState(() {
          controllerFullName.text;
        });
      },
      decoration: InputDecoration(
        filled: true,
        fillColor: Theme.of(context).colorScheme.primary,
        contentPadding: const EdgeInsets.only(top: 15, bottom: 15),
        prefixIcon: Padding(
            padding: const EdgeInsets.all(10),
            child: SvgPicture.asset(
              DesignConfig.getIconPath("icon_user.svg"),
              color: controllerFullName.text.isNotEmpty
                  ? Theme.of(context).primaryColor
                  : SettingsLocalDataSource().theme() == StringRes.darkThemeKey
                      ? Theme.of(context).colorScheme.secondary
                      : Theme.of(context)
                          .colorScheme
                          .secondary
                          .withOpacity(0.4),
            )),
        hintText: StringRes.hintFullName,
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
        contentPadding: const EdgeInsets.only(top: 15, bottom: 15),
        prefixIcon: Padding(
            padding: const EdgeInsets.all(10),
            child: SvgPicture.asset(
              DesignConfig.getIconPath("icon_email.svg"),
              color: controllerEmail.text.isNotEmpty
                  ? Theme.of(context).primaryColor
                  : SettingsLocalDataSource().theme() == StringRes.darkThemeKey
                      ? Theme.of(context).colorScheme.secondary
                      : Theme.of(context)
                          .colorScheme
                          .secondary
                          .withOpacity(0.4),
            )),
        hintText: StringRes.hintEmail,
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

  Widget passTextField() {
    return TextFormField(
      obscureText: _obscureText,
      obscuringCharacter: "*",
      validator: (input) => input!.isEmpty ? StringRes.msgEnterValidPWD : null,
      controller: controllerPass,
      cursorColor: const Color(0xffa2a2a2),
      style: TextStyle(color: Theme.of(context).secondaryHeaderColor),
      onChanged: (text) {
        setState(() {
          controllerPass.text;
        });
      },
      decoration: InputDecoration(
        filled: true,
        fillColor: Theme.of(context).colorScheme.primary,
        contentPadding: const EdgeInsets.only(top: 15, bottom: 15),
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

  Widget cnfPassTextField() {
    return TextFormField(
      obscureText: _obscureText1,
      obscuringCharacter: "*",
      validator: (input) =>
          input != controllerPass.text ? StringRes.msgCNFnotMatch : null,
      controller: controllerCngPass,
      cursorColor: const Color(0xffa2a2a2),
      style: TextStyle(color: Theme.of(context).secondaryHeaderColor),
      onChanged: (text) {
        setState(() {
          controllerCngPass.text;
        });
      },
      decoration: InputDecoration(
        filled: true,
        fillColor: Theme.of(context).colorScheme.primary,
        isDense: true,
        contentPadding: const EdgeInsets.only(top: 15, bottom: 15),
        prefixIcon: Padding(
          padding: const EdgeInsets.all(10),
          child: SvgPicture.asset(
            DesignConfig.getIconPath("icon_password.svg"),
            color: controllerCngPass.text.isNotEmpty
                ? Theme.of(context).primaryColor
                : SettingsLocalDataSource().theme() == StringRes.darkThemeKey
                    ? Theme.of(context).colorScheme.secondary
                    : Theme.of(context).colorScheme.secondary.withOpacity(0.4),
          ),
        ),
        suffixIcon: IconButton(
          icon: Padding(
            padding: const EdgeInsets.all(5.0),
            child: SvgPicture.asset(
              _obscureText1
                  ? DesignConfig.getIconPath("icon_close_eye.svg")
                  : DesignConfig.getIconPath("icon_open_eye.svg"),
              color: controllerCngPass.text.isNotEmpty
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
              _obscureText1 = !_obscureText1;
            });
          },
        ),
        hintText: StringRes.hintCnfPwd,
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

  Widget commonName(String name) {
    return Text(
      name,
      style: TextStyle(
          color: Theme.of(context).secondaryHeaderColor,
          fontWeight: FontWeight.normal,
          fontStyle: FontStyle.normal,
          fontSize: 14.0),
    );
  }

  Widget termAndPolicy() {
    return Container(
      alignment: Alignment.topLeft,
      child: ListTile(
          dense: true,
          visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
          contentPadding: EdgeInsets.zero,
          leading: Checkbox(
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
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
                    text: StringRes.agreeText),
                TextSpan(
                    style: TextStyle(
                        decoration: TextDecoration.underline,
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w500,
                        fontStyle: FontStyle.normal,
                        fontSize: 12.0),
                    text: StringRes.termText),
                TextSpan(
                    style: TextStyle(
                        color: Theme.of(context).secondaryHeaderColor,
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.normal,
                        fontSize: 12.0),
                    text: " & "),
                TextSpan(
                    style: TextStyle(
                        decoration: TextDecoration.underline,
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w500,
                        fontStyle: FontStyle.normal,
                        fontSize: 12.0),
                    text: StringRes.ppText)
              ]))),
    );
  }

  Widget signUpBtn() {
    return Align(
      alignment: Alignment.center,
      child: controllerPass.text.isNotEmpty && controllerEmail.text.isNotEmpty
          ? DesignConfig.gradientButton(
              isBlack: false,
              width: 270,
              height: 50,
              onPress: () {
                if (check == true) {
                  if (_formKey.currentState!.validate()) {
                    AuthLocalDataSource()
                        .setUserName(controllerFullName.text.trim());
                    signUpUser(
                        email: controllerEmail.text,
                        password: controllerPass.text);
                    //Navigator.of(context).pushNamed(Routes.home, arguments: false);
                  }
                } else {
                  setState(() {
                    DesignConfig.setSnackbar(StringRes.msgTerm, context, false);
                  });
                }
              },
              name: StringRes.signUp,
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
                child: isLoading
                    ? const CircularProgressIndicator(
                        color: Color(0xffffffff),
                      )
                    : const Text(StringRes.signUp,
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

  Widget alreadyAccText() {
    return Align(
      alignment: Alignment.center,
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).pushNamed(Routes.login, arguments: false);
        },
        child: RichText(
            text: TextSpan(children: [
          TextSpan(
              style: TextStyle(
                  color: Theme.of(context).secondaryHeaderColor,
                  fontWeight: FontWeight.w400,
                  fontStyle: FontStyle.normal,
                  fontSize: 14.0),
              text: StringRes.alreadyAccText),
          TextSpan(
              style: TextStyle(
                  decoration: TextDecoration.underline,
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w500,
                  fontStyle: FontStyle.normal,
                  fontSize: 14.0),
              text: StringRes.login)
        ])),
      ),
    );
  }
}
