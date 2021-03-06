import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:groshop/Locale/locales.dart';
import 'package:groshop/Theme/colors.dart';
import 'package:groshop/baseurl/baseurlg.dart';
import 'package:groshop/beanmodel/walletbean/rechargehistory.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class WalletHistory extends StatefulWidget {
  @override
  WalletHistoryState createState() {
    return WalletHistoryState();
  }
}

class WalletHistoryState extends State<WalletHistory> {
  bool isLoading = false;
  String apCurrency = '';
  List<RechargeData> rechargeHistory = [];
  var http = Client();


  @override
  void initState() {
    super.initState();
    getHistoryList();
  }

  @override
  void dispose() {
    http.close();
    super.dispose();
  }

  void getHistoryList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isLoading = true;
      apCurrency = prefs.getString('app_currency');
    });

    http.post(walletRechargeHistoryUri,
        body: {'user_id': '${prefs.getInt('user_id')}'}).then((value) {
      print('ppy - ${value.body}');
      if (value.statusCode == 200) {
        WalletRechargeHistory data1 =
            WalletRechargeHistory.fromJson(jsonDecode(value.body));
        if ('${data1.status}' == '1') {
          setState(() {
            rechargeHistory.clear();
            rechargeHistory = List.from(data1.data);
          });
        }
      }
      setState(() {
        isLoading = false;
      });
    }).catchError((e) {
      print(e);
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);

    return Scaffold(
      body: Column(
        children: [
          AppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_back_sharp),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            title: Text(
              locale.rechargehistory,
              style: TextStyle(color: kMainTextColor),
            ),
            centerTitle: true,
          ),
          RowHistory(locale),
          Expanded(
            child: (!isLoading && rechargeHistory!=null && rechargeHistory.length>0)?ListView.builder(
                shrinkWrap: true,
                itemCount: rechargeHistory.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 3,
                    color: kWhiteColor,
                    clipBehavior: Clip.hardEdge,
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Text('${index + 1}',style: Theme.of(context)
                            .textTheme
                            .subtitle2
                            .copyWith(fontSize: 16),),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left:10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  RichText(
                                    text: TextSpan(
                                      text: locale.rechargeDate,
                                      style: Theme.of(context)
                                          .textTheme
                                          .subtitle2
                                          .copyWith(fontSize: 14),
                                      children: <TextSpan>[
                                        TextSpan(
                                            text:
                                                ' ${rechargeHistory[index].dateOfRecharge}',
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .backgroundColor,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500)),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 5,),
                                  RichText(
                                    text: TextSpan(
                                      text: locale.amount,
                                      style: Theme.of(context)
                                          .textTheme
                                          .subtitle2
                                          .copyWith(fontSize: 14),
                                      children: <TextSpan>[
                                        TextSpan(
                                            text:
                                                ' $apCurrency ${rechargeHistory[index].amount}',
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .backgroundColor,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500)),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 5,),
                                  RichText(
                                    text: TextSpan(
                                      text: locale.paymentstatus,
                                      style: Theme.of(context)
                                          .textTheme
                                          .subtitle2
                                          .copyWith(fontSize: 14),
                                      children: <TextSpan>[
                                        TextSpan(
                                            text:
                                                ' - ${rechargeHistory[index].rechargeStatus}',
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .backgroundColor,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500)),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                          Text('${rechargeHistory[index].paymentGateway}'.toUpperCase(),style: Theme.of(context)
                              .textTheme
                              .subtitle2
                              .copyWith(fontSize: 16),),
                        ],
                      ),
                    ),
                  );
                }):
            (isLoading)?ListView.builder(
                shrinkWrap: true,
                itemCount: 10,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 3,
                    color: kWhiteColor,
                    clipBehavior: Clip.hardEdge,
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      child: Shimmer(
                        duration: Duration(seconds: 3),
                        color: Colors.white,
                        enabled: true,
                        direction: ShimmerDirection.fromLTRB(),
                        child: Row(
                          children: [
                            Container(height: 10,width: 20,),
                            Column(
                              children: [
                                Container(
                                  height: 10,
                                  width: 100,
                                ),
                                Container(
                                  height: 10,
                                  width: 100,
                                ),
                                Container(
                                  height: 10,
                                  width: 100,
                                ),
                              ],
                            ),
                        Container(
                          height: 10,
                          width: 50,
                        ),
                          ],
                        ),
                      ),
                    ),
                  );
                }):Align(
              alignment: Alignment.center,
              child: Text(locale.nohistory),
            ),
          )
        ],
      ),
    );
  }

  Widget RowHistory(AppLocalizations locale) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        children: [Text(locale.sn,
            style: TextStyle(
                color: Theme.of(context)
                    .backgroundColor,
                fontSize: 16,
                fontWeight: FontWeight.w700)), Expanded(child: Padding(
                  padding: const EdgeInsets.only(left:18.0),
                  child: Text('#',
            style: TextStyle(
                  color: Theme.of(context)
                      .backgroundColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w700)),
                )), Text(locale.paymentMode,
            style: TextStyle(
                color: Theme.of(context)
                    .backgroundColor,
                fontSize: 16,
                fontWeight: FontWeight.w700))],
      ),
    );
  }
}
