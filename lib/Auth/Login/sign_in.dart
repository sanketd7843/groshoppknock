import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:groshop/Auth/login_navigator.dart';
import 'package:groshop/Components/custom_button.dart';
import 'package:groshop/Components/entry_field.dart';
import 'package:groshop/Locale/locales.dart';
import 'package:groshop/Routes/routes.dart';
import 'package:groshop/Theme/colors.dart';
import 'package:groshop/baseurl/baseurlg.dart';
import 'package:groshop/beanmodel/appinfo.dart';
import 'package:groshop/beanmodel/signinmodel.dart';
import 'package:groshop/language_cubit.dart';
import 'package:groshop/main.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  LanguageCubit _languageCubit;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  static final FacebookLogin facebookSignIn = new FacebookLogin();
  GoogleSignIn _googleSignIn;
  bool showProgress = false;
  bool enteredFirst = false;
  int numberLimit = 10;
  var countryCodeController = TextEditingController();
  var phoneNumberController = TextEditingController();
  AppInfoModel appInfoModeld;
  int checkValue = -1;
  List<String> languages = [];
  String selectLanguage = '';
  var passwordController = TextEditingController();

  FirebaseMessaging messaging;
  dynamic token;

  int count = 0;

  @override
  void initState() {
    super.initState();
    _languageCubit = BlocProvider.of<LanguageCubit>(context);
    Firebase.initializeApp();
    hitAppInfo();
    messaging = FirebaseMessaging();
    messaging.getToken().then((value) {
      token = value;
    });
    _googleSignIn = GoogleSignIn(
      scopes: [
        'email',
      ],
    );
  }

  void hitAppInfo() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      showProgress = true;
    });
    var http = Client();
    http.get(appInfoUri).then((value) {
      // print(value.body);
      if (value.statusCode == 200) {
        AppInfoModel data1 = AppInfoModel.fromJson(jsonDecode(value.body));
        print('data - ${data1.toString()}');
        if (data1.status == "1" || data1.status == 1) {
          setState(() {
            appInfoModeld = data1;
            countryCodeController.text = '${data1.country_code}';
            numberLimit = int.parse('${data1.phone_number_length}');
            prefs.setString('app_currency', '${data1.currency_sign}');
            prefs.setString('app_referaltext', '${data1.refertext}');
            showProgress = false;
          });
        } else {
          setState(() {
            showProgress = false;
          });
        }
      } else {
        setState(() {
          showProgress = false;
        });
      }
    }).catchError((e) {
      setState(() {
        showProgress = false;
      });
      print(e);
    });
  }

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);
    if(!enteredFirst){
      setState(() {
        enteredFirst = true;
        selectLanguage = locale.language;
        languages = [
          locale.englishh,
          locale.arabicc,
          locale.frenchh,
          locale.indonesiann,
          locale.portuguesee,
          locale.spanishh,
        ];
      });
    }
    return Scaffold(
      key: _scaffoldKey,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 28.0, left: 0, right: 0),
          child: SingleChildScrollView(
            primary: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  locale.welcomeTo,
                  style: Theme.of(context).textTheme.headline3,
                  textAlign: TextAlign.center,
                ),
                Divider(
                  thickness: 1.0,
                  color: Colors.transparent,
                ),
                Image.asset(
                  "assets/userrlogo.png",
                  scale: 2.5,
                  height: 150,
                ),
                Divider(
                  thickness: 1.0,
                  color: Colors.transparent,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10.0, vertical: 1),
                  child: Text(
                    locale.selectPreferredLanguage.toUpperCase(),
                    style: Theme.of(context).textTheme.headline6.copyWith(
                        color: kMainTextColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 21.7),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: DropdownButton<String>(
                    hint: Text(
                      selectLanguage,
                      overflow: TextOverflow.clip,
                      maxLines: 1,
                    ),
                    isExpanded: true,
                    iconEnabledColor: kMainTextColor,
                    iconDisabledColor: kMainTextColor,
                    iconSize: 30,
                    items: languages.map((value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value.toString(),
                            overflow: TextOverflow.clip),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectLanguage = value;
                        if (selectLanguage == locale.englishh) {
                          _languageCubit.selectEngLanguage();
                        } else if (selectLanguage == locale.arabicc) {
                          _languageCubit.selectArabicLanguage();
                        } else if (selectLanguage == locale.portuguesee) {
                          _languageCubit.selectPortugueseLanguage();
                        } else if (selectLanguage == locale.frenchh) {
                          _languageCubit.selectFrenchLanguage();
                        } else if (selectLanguage == locale.spanishh) {
                          _languageCubit.selectSpanishLanguage();
                        } else if (selectLanguage == locale.indonesiann) {
                          _languageCubit.selectIndonesianLanguage();
                        }
                      });
                      print(value);
                    },
                  ),
                ),
                Divider(
                  thickness: 1.0,
                  color: Colors.transparent,
                ),
                EntryField(
                  label: locale.selectCountry,
                  hint: locale.selectCountry,
                  controller: countryCodeController,
                  readOnly: true,
                  // suffixIcon: (Icons.arrow_drop_down),
                ),
                EntryField(
                  label: locale.phoneNumber,
                  hint: locale.enterPhoneNumber,
                  maxLength: numberLimit,
                  controller: phoneNumberController,
                ),
                Visibility(
                  visible: (checkValue == -1) ? true : false,
                  child: EntryField(
                    label: locale.password1,
                    hint: locale.password2,
                    controller: passwordController,
                  ),
                ),
                Visibility(
                  visible: (checkValue == -1) ? true : false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          locale.or,
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontSize: 18,
                            color: kMainTextColor,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        GestureDetector(
                          onTap: (){
                            Navigator.pushNamed(context, SignInRoutes.restpassword1, arguments: {
                              'appinfo': appInfoModeld,
                            });
                          },
                          behavior: HitTestBehavior.opaque,
                          child: Text(
                            locale.resetpassword,
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              fontSize: 18,
                              color: kMainTextColor,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Container(
                    width: MediaQuery.of(context).size.width,
                    alignment: Alignment.center,
                    margin: EdgeInsets.only(right: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Radio(
                              value: 0,
                              groupValue: checkValue,
                              toggleable: true,
                              onChanged: (value) {
                                // print(value);
                                setState(() {
                                  if (checkValue == 0) {
                                    checkValue = -1;
                                  } else {
                                    checkValue = 0;
                                  }
                                });
                                // print(checkValue);
                              },
                            ),
                            Container(
                              width: 5,
                            ),
                            Text(
                              locale.loginotp,
                              style: TextStyle(
                                fontSize: 18,
                                color: kMainTextColor,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () async {
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            prefs.setBool('skip', true);
                            prefs.setBool('islogin', false);
                            Navigator.pushAndRemoveUntil(_scaffoldKey.currentContext,
                                MaterialPageRoute(builder: (context) {
                                  return GroceryHome();
                                }), (Route<dynamic> route) => false);
                          },
                          child: Row(
                            children: [
                              Text(
                                locale.skiptext,
                                style: TextStyle(
                                  fontSize: 20,
                                  color: kMainColor,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward,
                                color: kMainColor,
                                size: 27,
                              )
                            ],
                          ),
                        )
                      ],
                    )),
                CustomButton(
                  onTap: () {
                    if (!showProgress) {
                      setState(() {
                        showProgress = true;
                      });
                      if (checkValue == 0) {
                        // checkNumber
                        hitLoginUrl('${phoneNumberController.text}', '', 'otp',
                            context);
                        // hitAppInfo();
                      } else {
                        if (phoneNumberController.text != null &&
                            phoneNumberController.text.length == 10) {
                          if (passwordController.text != null &&
                              passwordController.text.length >= 5) {
                            hitLoginUrl('${phoneNumberController.text}',
                                passwordController.text, 'password', context);
                          } else {
                            Toast.show(locale.incorectPassword, context,gravity: Toast.CENTER,duration: Toast.LENGTH_SHORT);
                            setState(() {
                              showProgress = false;
                            });
                          }
                        } else {
                          Toast.show(locale.incorectMobileNumber, context,gravity: Toast.CENTER,duration: Toast.LENGTH_SHORT);
                          setState(() {
                            showProgress = false;
                          });
                        }
                      }
                    }
                    // else{
                    //   setState(() {
                    //     showProgress = false;
                    //   });
                    // }
                  },
                ),
                Divider(
                  thickness: 1.0,
                  color: Colors.transparent,
                ),
                Visibility(
                    visible: showProgress,
                    child: Column(
                      children: [
                        Container(
                            alignment: Alignment.center,
                            margin: EdgeInsets.only(top: 10, bottom: 10),
                            child: CircularProgressIndicator()),
                        Divider(
                          thickness: 1.0,
                          color: Colors.transparent,
                        ),
                      ],
                    )),
                Text(
                  locale.wellSendOTPForVerification,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                Text(
                  locale.orContinueWith,
                  textAlign: TextAlign.center,
                ),
                Divider(
                  thickness: 1.2,
                  color: Colors.transparent,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: CustomButton(
                        label: 'Facebook',
                        color: Color(0xff3b45c1),
                        onTap: () {
                          if (!showProgress) {
                            setState(() {
                              showProgress = true;
                            });
                            _login(context);
                          }
                        },
                      ),
                    ),
                    Expanded(
                      child: CustomButton(
                        label: 'Google',
                        color: Color(0xffff452c),
                        onTap: () {
                          if (!showProgress) {
                            setState(() {
                              showProgress = true;
                            });
                            _handleSignIn(context);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleSignIn(BuildContext contextd) async {
    _googleSignIn.isSignedIn().then((value) async {
      print('${value}');
      if (value) {
        if (_googleSignIn.currentUser != null) {
          socialLogin('google', '${_googleSignIn.currentUser.email}', '',contextd);
        } else {
          _googleSignIn.signOut().then((value) async {
            await _googleSignIn.signIn().then((value) {
              var email = value.email;
              socialLogin('google', '$email', '',contextd);
              // print('${email} - ${value.id}');
            }).catchError((e) {
              setState(() {
                showProgress = false;
              });
            });
          }).catchError((e) {
            setState(() {
              showProgress = false;
            });
          });
        }
      } else {
        try {
          await _googleSignIn.signIn().then((value) {
            var email = value.email;
            socialLogin('google', '$email', '',contextd);
            // print('${email} - ${value.id}');
          });
        } catch (error) {
          setState(() {
            showProgress = false;
          });
          print(error);
        }
      }
    }).catchError((e) {
      setState(() {
        showProgress = false;
      });
    });
  }

  void socialLogin(dynamic loginType, dynamic email, dynamic fb_id, BuildContext contextd) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var client = Client();
    client.post(socialLoginUri, body: {
      'type': '$loginType',
      'user_email': '$email',
      'fb_id': '$fb_id',
    }).then((value) {
      print('${value.statusCode} - ${value.body}');
      var jsData = jsonDecode(value.body);
      SignInModel signInData = SignInModel.fromJson(jsData);
      if ('${signInData.status}' == '1') {
        var userId = int.parse('${signInData.data.user_id}');
        prefs.setInt("user_id", userId);
        prefs.setString("user_name", '${signInData.data.user_name}');
        prefs.setString("user_email", '${signInData.data.user_email}');
        prefs.setString("user_image", '${signInData.data.user_image}');
        prefs.setString("user_phone", '${signInData.data.user_phone}');
        prefs.setString("user_password", '${signInData.data.user_password}');
        prefs.setString("wallet_credits", '${signInData.data.wallet}');
        prefs.setString("user_city", '${signInData.data.user_city}');
        prefs.setString("user_area", '${signInData.data.user_area}');
        prefs.setString("block", '${signInData.data.block}');
        prefs.setString("app_update", '${signInData.data.app_update}');
        prefs.setString("reg_date", '${signInData.data.reg_date}');
        prefs.setBool("phoneverifed", true);
        prefs.setBool("islogin", true);
        prefs.setString("refferal_code", '${signInData.data.referral_code}');
        prefs.setString("reward", '${signInData.data.rewards}');
        Navigator.pushAndRemoveUntil(contextd,
            MaterialPageRoute(builder: (context) {
              return GroceryHome();
            }), (Route<dynamic> route) => false);
      } else {
        if (loginType == 'google') {
          Navigator.pushNamed(contextd, SignInRoutes.signUp, arguments: {
            'user_email': '${email}',
            'numberlimit': numberLimit,
            'appinfo': appInfoModeld,
          });
        } else {
          Navigator.pushNamed(contextd, SignInRoutes.signUp, arguments: {
            'fb_id': '${fb_id}',
            'numberlimit': numberLimit,
            'appinfo': appInfoModeld,
          });
        }
      }
      setState(() {
        showProgress = false;
      });
    }).catchError((e) {
      setState(() {
        showProgress = false;
      });
      print(e);
    });
  }

  void _login(BuildContext contextt) async {
    await facebookSignIn.logIn(['email']).then((result) {
      switch (result.status) {
        case FacebookLoginStatus.loggedIn:
          final FacebookAccessToken accessToken = result.accessToken;
          socialLogin('facebook', '', '${accessToken.userId}',contextt);
          break;
        case FacebookLoginStatus.cancelledByUser:
          setState(() {
            showProgress = false;
          });
          break;
        case FacebookLoginStatus.error:
          setState(() {
            showProgress = false;
          });
          break;
      }
    }).catchError((e) {
      setState(() {
        showProgress = false;
      });
      print(e);
    });
  }

  void hitLoginUrl(dynamic user_phone, dynamic user_password, dynamic logintype,
      BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (token != null) {
      var http = Client();
      http.post(loginUri, body: {
        'user_phone': '$user_phone',
        'user_password': '$user_password',
        'device_id': '$token',
        'logintype': '$logintype',
      }).then((value) {
        print('sign - ${value.body}');
        if (value.statusCode == 200) {
          var jsData = jsonDecode(value.body);
          LoginModel signInData = LoginModel.fromJson(jsData);
          print('${signInData.toString()}');
          if (signInData.status == "0" || signInData.status == 0) {
            Toast.show(signInData.message, context,
                duration: Toast.LENGTH_SHORT, gravity: Toast.CENTER);
            Navigator.pushNamed(context, SignInRoutes.signUp, arguments: {
              'user_phone': '${user_phone}',
              'numberlimit': numberLimit,
              'appinfo': appInfoModeld,
            });
          } else if (signInData.status == "1" || signInData.status == 1) {
            var userId = int.parse('${signInData.data.user_id}');
            prefs.setInt("user_id", userId);
            prefs.setString("user_name", '${signInData.data.user_name}');
            prefs.setString("user_email", '${signInData.data.user_email}');
            prefs.setString("user_image", '${signInData.data.user_image}');
            prefs.setString("user_phone", '${signInData.data.user_phone}');
            prefs.setString(
                "user_password", '${signInData.data.user_password}');
            prefs.setString("wallet_credits", '${signInData.data.wallet}');
            prefs.setString("user_city", '${signInData.data.user_city}');
            prefs.setString("user_area", '${signInData.data.user_area}');
            prefs.setString("block", '${signInData.data.block}');
            prefs.setString("app_update", '${signInData.data.app_update}');
            prefs.setString("reg_date", '${signInData.data.reg_date}');
            prefs.setBool("phoneverifed", true);
            prefs.setBool("islogin", true);
            prefs.setString(
                "refferal_code", '${signInData.data.referral_code}');
            prefs.setString("reward", '${signInData.data.rewards}');
            Navigator.pushAndRemoveUntil(context,
                MaterialPageRoute(builder: (context) {
                  return GroceryHome();
                }), (Route<dynamic> route) => false);
            // Navigator.popAndPushNamed(context, SignInRoutes.home);
          } else if (signInData.status == "2" || signInData.status == 2) {
            Navigator.pushNamed(context, SignInRoutes.verification, arguments: {
              'token': '${token}',
              'user_phone': '${user_phone}',
              'firebase': '${appInfoModeld.firebase}',
              'country_code': '${appInfoModeld.country_code}',
              'activity': 'login',
            });
          } else if (signInData.status == "3" || signInData.status == 3) {
            Navigator.pushNamed(context, SignInRoutes.verification, arguments: {
              'token': '${token}',
              'user_phone': '${user_phone}',
              'firebase': '${appInfoModeld.firebase}',
              'country_code': '${appInfoModeld.country_code}',
              'activity': 'login',
            });
          }else{
            Toast.show(signInData.message, context,
                duration: Toast.LENGTH_SHORT, gravity: Toast.CENTER);
          }
        }
        setState(() {
          showProgress = false;
        });
      }).catchError((e) {
        setState(() {
          showProgress = false;
        });
        print(e);
      });
    } else {
      if (count == 0) {
        count = 1;
        messaging.getToken().then((value) {
          setState(() {
            token = value;
            hitLoginUrl(user_phone, user_password, logintype, context);
          });
        });
      } else {
        setState(() {
          showProgress = false;
        });
      }
    }
  }
}
