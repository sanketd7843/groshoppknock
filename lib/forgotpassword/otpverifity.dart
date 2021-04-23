import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:groshop/Auth/login_navigator.dart';
import 'package:groshop/Components/custom_button.dart';
import 'package:groshop/Components/entry_field.dart';
import 'package:groshop/Locale/locales.dart';
import 'package:groshop/Theme/colors.dart';
import 'package:groshop/baseurl/baseurlg.dart';
import 'package:groshop/beanmodel/appinfo.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

class ResetOtpVerify extends StatefulWidget {
  final VoidCallback onVerificationDone;

  ResetOtpVerify(this.onVerificationDone);

  @override
  _ResetOtpVerifyState createState() => _ResetOtpVerifyState();
}

class _ResetOtpVerifyState extends State<ResetOtpVerify> {
  final TextEditingController _controller = TextEditingController();
  FirebaseMessaging messaging;
  bool isDialogShowing = false;
  dynamic token = '';
  var showDialogBox = false;
  var verificaitonPin = "";
  FirebaseAuth firebaseAuth;
  var actualCode;
  AuthCredential _authCredential;
  bool firebaseOtp = false;
  dynamic user_phone;
  dynamic referralcode;
  dynamic country_code;
  dynamic activity;
  AppInfoModel appInfo;

  int firecount = 0;

  @override
  void initState() {
    super.initState();
    Firebase.initializeApp();
    messaging = FirebaseMessaging();
    messaging.getToken().then((value) {
      token = value;
    });
  }

  initilizedFirebaseAuth(userNumber) async {
    firecount = 1;
    Firebase.initializeApp();
    firebaseAuth = await FirebaseAuth.instance;
    PhoneCodeSent codeSent =
        (String verificationId, [int forceResendingToken]) async {
      setState(() {
        if (showDialogBox != null && showDialogBox) {
          showDialogBox = false;
        }
        actualCode = verificationId;
      });
      print(actualCode);
      print('Code sent');
    };
    final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
        (String verificationId) {
      // this.actualCode = verificationId;
      print(verificationId);
      print('Auto retrieval time out');
    };
    final PhoneVerificationFailed verificationFailed =
        (FirebaseAuthException authException) {
      print('${authException.message}');
      // setState(() {
      //
      // });
      if (authException.message.contains('not authorized')) {
      } else if (authException.message.contains('Network')) {
      } else {}
    };
    final PhoneVerificationCompleted verificationCompleted =
        (AuthCredential auth) {
      print('${auth.providerId}');
      // setState(() {});
    };
    firebaseAuth.verifyPhoneNumber(
        phoneNumber: userNumber,
        timeout: Duration(seconds: 60),
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);
  }

  void _signInWithPhoneNumber(String smsCode, BuildContext context) async {
    print(actualCode);
    print(smsCode);
    _authCredential = await PhoneAuthProvider.credential(
        verificationId: actualCode, smsCode: smsCode);
    firebaseAuth.signInWithCredential(_authCredential).then((value) {
      User uss = value.user;
      if (uss != null) {
        print('${uss.phoneNumber}\n${uss.providerData.toList().toString()}');
        hitFirebaseSuccessLoginStatus('success', context);
      }
      setState(() {
        showDialogBox = false;
      });
    }).catchError((e) {
      print(e);
      setState(() {
        showDialogBox = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);
    if (firecount == 0) {
      final Map<String, Object> dataRecevid =
          ModalRoute.of(context).settings.arguments;
      setState(() {
        user_phone = dataRecevid['number'];
        appInfo = dataRecevid['appinfo'];
        firebaseOtp =
            '${appInfo.firebase}'.toUpperCase() == 'ON' ? true : false;
        country_code = '${appInfo.country_code}';
      });
      if (firebaseOtp) {
        print('firebase otp status - ${firebaseOtp}');
        print('+$country_code$user_phone');
        initilizedFirebaseAuth('+$country_code$user_phone');
      }
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.keyboard_arrow_left_sharp,
            size: 30,
          ),
          onPressed: () {
            widget.onVerificationDone();
          },
        ),
        title: Text(
          locale.verification,
          style: TextStyle(color: kMainTextColor),
        ),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48.0, vertical: 48),
            child: Text(
              locale.pleaseEnterVerificationCodeSentGivenNumber,
              style: Theme.of(context).textTheme.headline3,
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
                top: 28.0, left: 18, right: 18, bottom: 4),
            child: Text(
              locale.enterVerificationCode,
              style: Theme.of(context).textTheme.headline3.copyWith(
                  fontSize: 22,
                  color: Theme.of(context).backgroundColor,
                  fontWeight: FontWeight.w500),
            ),
          ),
          EntryField(
            controller: _controller,
            hint: locale.enterVerificationCode,
            maxLines: 1,
            maxLength: firebaseOtp ? 6 : 4,
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 10.0),
          Align(
            alignment: Alignment.center,
            child: GestureDetector(
              onTap: () {
                if (!showDialogBox) {
                  if (firebaseOtp) {
                    initilizedFirebaseAuth('+$country_code$user_phone');
                  } else {
                    resendOtpM();
                  }
                }
              },
              behavior: HitTestBehavior.opaque,
              child: Text(
                'RESEND OTP',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: kMainColor),
              ),
            ),
          ),
          SizedBox(height: 10.0),
          Spacer(),
          showDialogBox
              ? Container(
                  height: 60,
                  width: MediaQuery.of(context).size.width,
                  alignment: Alignment.center,
                  child: Align(
                    widthFactor: 40,
                    heightFactor: 40,
                    alignment: Alignment.center,
                    child: CircularProgressIndicator(),
                  ),
                )
              : CustomButton(
                  onTap: () {
                    // widget.onVerificationDone();
                    if (!showDialogBox) {
                      setState(() {
                        showDialogBox = true;
                      });
                      verificaitonPin = _controller.text;
                      if (firebaseOtp) {
                        _signInWithPhoneNumber(verificaitonPin, context);
                      } else {
                        hitService(verificaitonPin, context);
                      }
                    }
                  },
                ),
        ],
      ),
    );
  }

  void resendOtpM() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var url = resendOtpUri;
    await http.post(url, body: {
      'user_phone': '${user_phone}',
    }).then((response) {
      print('Response Body: - ${response.body}');
      if (response.statusCode == 200) {
        setState(() {
          showDialogBox = false;
        });
      } else {
        setState(() {
          showDialogBox = false;
        });
      }
    }).catchError((e) {
      print(e);
      setState(() {
        showDialogBox = false;
      });
    });
  }

  void hitService(String verificaitonPin, BuildContext context) async {
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    var url = verifyOtpPPhoneUri;
    await http.post(url, body: {
      'user_phone': '${user_phone}',
      'otp': verificaitonPin,
    }).then((value) {
      print('Response Body: - ${value.body}');
      if (value.statusCode == 200) {
        var jv = jsonDecode(value.body);
        if ('${jv['status']}' == '1') {
          Navigator.popAndPushNamed(context, SignInRoutes.restpassword3, arguments: {
            'appinfo': appInfo,
            'number': user_phone,
          });
        }
        Toast.show(jv['message'], context,
            duration: Toast.LENGTH_SHORT, gravity: Toast.CENTER);
      }
      setState(() {
        showDialogBox = false;
      });
    }).catchError((e) {
      print(e);
      setState(() {
        showDialogBox = false;
      });
    });
  }

  void hitFirebaseSuccessLoginStatus(
      String status, BuildContext context) async {
    var url = verifyOtpPFirebaseUri;
    await http.post(url, body: {
      'user_phone': '${user_phone}',
      'status': status,
    }).then((value) {
      print('Response Body: - ${value.body}');
      if (value.statusCode == 200) {
        var jv = jsonDecode(value.body);
        if ('${jv['status']}' == '1') {
          Navigator.popAndPushNamed(context, SignInRoutes.restpassword3, arguments: {
            'appinfo': appInfo,
            'number': user_phone,
          });
        }
        Toast.show(jv['message'], context,
            duration: Toast.LENGTH_SHORT, gravity: Toast.CENTER);
      }
      setState(() {
        showDialogBox = false;
      });
    }).catchError((e) {
      print(e);
      setState(() {
        showDialogBox = false;
      });
    });
  }
}
