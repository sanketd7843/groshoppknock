import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:groshop/Locale/locales.dart';
import 'package:groshop/Theme/colors.dart';
import 'package:groshop/baseurl/baseurlg.dart';
import 'package:groshop/beanmodel/orderbean/cancelbean.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class CancelPage extends StatefulWidget {
  final dynamic cartid;

  CancelPage(this.cartid);

  @override
  CancelPageState createState() {
    return CancelPageState();
  }
}

class CancelPageState extends State<CancelPage> {
  bool isLoading = false;
  bool isDelete = false;
  String apCurrency = '';
  List<CancelData> rechargeHistory = [];
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

    http.get(cancellingReasonsUri).then((value) {
      print('ppy - ${value.body}');
      if (value.statusCode == 200) {
        CancelMain data1 = CancelMain.fromJson(jsonDecode(value.body));
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
              locale.cancelreason,
              style: TextStyle(color: kMainTextColor),
            ),
            centerTitle: true,
          ),
          RowHistory(locale),
          Expanded(
            child: (!isDelete &&
                    !isLoading &&
                    rechargeHistory != null &&
                    rechargeHistory.length > 0)
                ? ListView.builder(
                    shrinkWrap: true,
                    itemCount: rechargeHistory.length,
                    itemBuilder: (contexts, index) {
                      return GestureDetector(
                        onTap: () {
                          if (!isDelete) {
                            setState(() {
                              isDelete = false;
                            });
                            hitDelete(
                                '${rechargeHistory[index].reason}', context);
                          }
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Card(
                          elevation: 3,
                          color: kWhiteColor,
                          clipBehavior: Clip.hardEdge,
                          child: Container(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Text(
                                  '${index + 1}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline1
                                      .copyWith(fontSize: 16),
                                ),
                                Expanded(
                                    child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    '${rechargeHistory[index].reason}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline1
                                        .copyWith(fontSize: 16),
                                  ),
                                )),
                              ],
                            ),
                          ),
                        ),
                      );
                    })
                : (isDelete || isLoading)
                    ? ListView.builder(
                        shrinkWrap: true,
                        itemCount: 10,
                        itemBuilder: (context, index) {
                          return Card(
                            elevation: 3,
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
                                    Container(
                                      height: 10,
                                      width: 50,
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Container(
                                      height: 10,
                                      width: 150,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        })
                    : Container(
                        alignment: Alignment.center,
                        child: isDelete
                            ? Align(
                                alignment: Alignment.center,
                                heightFactor: 40,
                                widthFactor: 40,
                                child: CircularProgressIndicator(),
                              )
                            : Text(locale.nohistory),
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
        children: [
          Text(locale.sn,
              style: TextStyle(
                  color: Theme.of(context).backgroundColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w700)),
          Expanded(
              child: Padding(
            padding: const EdgeInsets.only(left: 18.0),
            child: Text(locale.reason,
                style: TextStyle(
                    color: Theme.of(context).backgroundColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w700)),
          ))
        ],
      ),
    );
  }

  void hitDelete(dynamic reason, BuildContext context) async {
    http.post(deleteOrderUri, body: {
      'cart_id': '${widget.cartid}',
      'reason': '$reason',
    }).then((value) {
      print('cc - ${value.body}');
      if (value.statusCode == 200) {
        var js = jsonDecode(value.body);
        if ('${js['status']}' == '1') {
          Navigator.of(context).pop(true);
        }
      }
      setState(() {
        isDelete = false;
      });
    }).catchError((e) {
      setState(() {
        isDelete = false;
      });
    });
  }
}
