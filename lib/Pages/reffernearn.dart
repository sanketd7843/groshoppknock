import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:groshop/Components/drawer.dart';
import 'package:groshop/beanmodel/appinfo.dart';
import 'package:groshop/main.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:groshop/Locale/locales.dart';
import 'package:groshop/Theme/colors.dart';
import 'package:groshop/baseurl/baseurlg.dart';

class RefferScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return RefferScreenState();
  }
}

class RefferScreenState extends State<RefferScreen> {
  var refferText = '';
  var appLink = '';
  var userName;
  bool islogin = false;
  var refferCode = '';
  bool isFetchStore = false;

  dynamic elestxt = 'Fetching data..';

  dynamic appname = '';

  @override
  void initState() {
    super.initState();
    hitAppInfo();
  }
  void hitAppInfo() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      islogin = prefs.getBool('islogin');
      userName = prefs.getString('user_name');
      elestxt = 'Fetching reward points';
      isFetchStore = true;
      refferCode = prefs.getString('refferal_code');
    });
    var http = Client();
    http.get(appInfoUri).then((value) {
      // print(value.body);
      if (value.statusCode == 200) {
        AppInfoModel data1 = AppInfoModel.fromJson(jsonDecode(value.body));
        print('data - ${data1.toString()}');
        if (data1.status == "1" || data1.status == 1) {
          setState(() {
            refferText = '${data1.refertext}';
            appLink = '${data1.app_link}';
            appname = '${data1.app_name}';
            prefs.setString('app_currency', '${data1.currency_sign}');
            prefs.setString('app_referaltext', '${data1.refertext}');
          });
        }
      }
      setState(() {
        isFetchStore = false;
      });
    }).catchError((e) {
      setState(() {
        isFetchStore = false;
      });
      print(e);
    });
  }

  void getRefferCode() async {
    // setState(() {
    //   elestxt = 'Fetching share code..';
    //   isFetchStore = true;
    // });
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // int userId = prefs.getInt('user_id');
    // var url = promocode_regenerate;
    // var client = http.Client();
    // client.post(url, body: {
    //   'user_id': '${userId}',
    // }).then((value) {
    //   if (value.statusCode == 200) {
    //     var redemData = jsonDecode(value.body);
    //     print('${value.body}');
    //     if (redemData['status'] == 1) {
    //       prefs.setString('refferal_code', '${redemData['PromoCode']}');
    //       print('${value.body}');
    //       setState(() {
    //         refferCode = redemData['PromoCode'];
    //       });
    //       Toast.show(redemData['message'], context,
    //           duration: Toast.LENGTH_SHORT);
    //     }
    //   }
    //   setState(() {
    //     isFetchStore = false;
    //   });
    // }).catchError((e) {
    //   setState(() {
    //     isFetchStore = false;
    //   });
    //   print(e);
    // });
  }

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: kCardBackgroundColor,
      drawer: buildDrawer(context, '${userName}', islogin,onHit: () {
        SharedPreferences.getInstance().then((pref){
          pref.clear().then((value) {
            Navigator.pushAndRemoveUntil(context,
                MaterialPageRoute(builder: (context) {
                  return GroceryLogin();
                }), (Route<dynamic> route) => false);
          });
        });
      }),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(64.0),
        child: AppBar(
          backgroundColor: kWhiteColor,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                locale.inviteNEarn,
                style: Theme.of(context)
                    .textTheme
                    .bodyText1
                    .copyWith(color: kMainTextColor),
              ),
            ],
          ),
        ),
      ),
      body: (!isFetchStore)
          ? Column(
              // alignment: Alignment.topCenter,
        crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // Positioned(
                //     top: 40,
                //     child: ),
                // Container(
                //   width: 200,
                //   height: 150,
                //   decoration: BoxDecoration(
                //       image: DecorationImage(
                //           image: AssetImage(
                //               'images/refernearn/refernearn.jpg'),
                //           fit: BoxFit.fill)),
                // ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 30),
                        alignment: Alignment.center,
                        child: Text(
                          '${refferText}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 25,
                              color: kMainTextColor),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 30),
                        child: Text(
                          locale.sahreYourCode,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                              color: kHintColor),
                        ),
                      ),
                    ],
                  ),
                ),
                // Positioned(
                //   top: 210,
                //   left: 20,
                //   right: 20,
                //   child: ,
                // ),
                // Positioned(
                //   top: 270,
                //   left: 20,
                //   right: 20,
                //   child:
                // ),
                Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.all(60),
                  child: Align(
                    alignment: Alignment.center,
                    widthFactor: 150,
                    child: GestureDetector(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: refferCode));
                        Toast.show(locale.codeCpied, context,
                            duration: Toast.LENGTH_SHORT);
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Card(
                        child: Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.all(10),
                          // width: 150,
                          // height: 80,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                '${refferCode}',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 18,
                                    letterSpacing: 5,
                                    fontWeight: FontWeight.w600,
                                    color: kWhiteColor),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Text(
                                locale.tapTOCopy,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400,
                                    color: kHintColor),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 50,vertical: 15),
                  child: GestureDetector(
                    onTap: () {
                      if (refferCode != null && refferCode.length > 0) {
                        share(locale.shareheading,locale.sharetext);
                      } else {
                        Toast.show(
                            locale.generateYourSharedCodeFirst, context,
                            gravity: Toast.CENTER,
                            duration: Toast.LENGTH_SHORT);
                        // getRefferCode();
                      }
                    },
                    child: Container(
                      alignment: Alignment.center,
                      height: 52,
                      margin: EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          color: kMainColor),
                      child: Text(
                        locale.inviteFriends,
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                            color: kWhiteColor),
                      ),
                    ),
                  ),
                )
                // Positioned(
                //     bottom: 90,
                //     child: ),
                // Positioned(
                //     bottom: 15,
                //     left: 0.0,
                //     right: 0.0,
                //     child: )
              ],
            )
          : Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    '${elestxt}',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: kMainTextColor),
                  )
                ],
              ),
            ),
    );
  }

  Future<void> share(String share, String sharetext) async {
    await FlutterShare.share(
        title: appname,
        text: '${refferText}\n$sharetext ${refferCode}.',
        linkUrl: '${appLink}',
        chooserTitle: '$share ${appname}');
  }
}
