import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:groshop/Auth/checkout_navigator.dart';
import 'package:groshop/Locale/locales.dart';
import 'package:groshop/Pages/Other/offers.dart';
import 'package:groshop/Routes/routes.dart';
import 'package:groshop/Theme/colors.dart';
import 'package:groshop/baseurl/baseurlg.dart';
import 'package:groshop/beanmodel/addressbean/showaddress.dart';
import 'package:groshop/beanmodel/cart/cartitembean.dart';
import 'package:groshop/beanmodel/cart/makeorderbean.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrderDeatilsPage extends StatefulWidget {
  // final VoidCallback onBackButtonPressed;
  //
  // OrderDeatilsPage(this.onBackButtonPressed);

  @override
  _OrderDeatilsPageState createState() => _OrderDeatilsPageState();
}

class _OrderDeatilsPageState extends State<OrderDeatilsPage> {
  bool enterFirst = false;
  AddressData addressData;
  dynamic cart_id;
  List<CartItemData> cartItemd = [];
  CartStoreDetails storeDetails;
  MakeOrderData makeOrderData;

  dynamic apcurrency;

  bool progressadd = false;

  String addressshow;

  double promocodeprice = 0.0;

  TextEditingController promoC = TextEditingController();

  @override
  void initState() {
    super.initState();
    getAppCurrency();
  }

  void getAppCurrency() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      apcurrency = prefs.getString('app_currency');
    });
  }

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);
    Map<String, dynamic> receivedData =
        ModalRoute
            .of(context)
            .settings
            .arguments;
    setState(() {
      if (!enterFirst) {
        enterFirst = true;
        cart_id = receivedData['cart_id'];
        cartItemd = receivedData['cartdetails'];
        storeDetails = receivedData['storedetails'];
        makeOrderData = receivedData['orderdetails'];
        addressData = receivedData['address'];
        addressshow = '${locale.name} - ${addressData.receiver_name}\n${locale.cnumber} - ${addressData.receiver_phone}\n${addressData.house_no}${addressData.landmark}${addressData.society}${addressData.city}(${addressData.pincode})${addressData.state}';
      }
    });
    return Scaffold(
      body: Container(
        height: MediaQuery
            .of(context)
            .size
            .height,
        width: MediaQuery
            .of(context)
            .size
            .width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Image.asset(
                  'assets/header.png',
                  height: 170,
                  fit: BoxFit.fitHeight,
                ),
                IconButton(
                    padding: EdgeInsets.only(top: 50),
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                    ),
                    onPressed: () {
                     Navigator.of(context).pop();
                    }),
                Positioned.directional(
                    textDirection: Directionality.of(context),
                    top: 50,
                    start: MediaQuery
                        .of(context)
                        .size
                        .width / 3.5,
                    child: Text(
                      locale.orderDetails.toUpperCase(),
                      style: TextStyle(
                          letterSpacing: 1,
                          fontWeight: FontWeight.w500,
                          fontSize: 18,
                          color: Theme
                              .of(context)
                              .scaffoldBackgroundColor),
                    )),
                Positioned.directional(
                  top: 120,
                  width: MediaQuery
                      .of(context)
                      .size
                      .width,
                  textDirection: Directionality.of(context),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Icon(
                        Icons.location_on,
                        color: Colors.white,
                      ),
                      Text(
                        '......',
                        style: TextStyle(fontSize: 40, color: Colors.white),
                      ),
                      Icon(
                        Icons.credit_card,
                        color: Colors.white,
                      ),
                      Text(
                        '......',
                        style: TextStyle(fontSize: 40, color: Colors.grey[400]),
                      ),
                      Image.asset(
                        'assets/ic_check.png',
                        height: 22,
                        color: Colors.grey[400],
                      )
                    ],
                  ),
                )
              ],
            ),
            Expanded(
                child: (enterFirst)
                    ? SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      (cartItemd != null && cartItemd.length > 0) ? ListView
                          .builder(
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: cartItemd.length,
                          shrinkWrap: true,
                          primary: false,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.network(
                                        cartItemd[index].varient_image,
                                        height: 95,
                                        width: 80,
                                      )),
                                  SizedBox(
                                    width: 15,
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment
                                          .start,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          cartItemd[index].product_name,
                                          style: Theme
                                              .of(context)
                                              .textTheme
                                              .subtitle1,
                                        ),
                                        SizedBox(
                                          height: 8,
                                        ),
                                        Text(
                                          '${cartItemd[index]
                                              .quantity} ${cartItemd[index]
                                              .unit}',
                                          style: Theme
                                              .of(context)
                                              .textTheme
                                              .subtitle2,
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment
                                              .start,
                                          children: [
                                            SizedBox(
                                              width: 15,
                                            ),
                                            Text('${cartItemd[index].qty}',
                                                style: Theme
                                                    .of(context)
                                                    .textTheme
                                                    .subtitle1),
                                            SizedBox(
                                              width: 15,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text('$apcurrency ${cartItemd[index].price}',
                                      textAlign: TextAlign.right,
                                      style: Theme
                                          .of(context)
                                          .textTheme
                                          .subtitle1),
                                ],
                              ),
                            );
                          }) : Container(),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        margin: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                            border: Border.all(color: kMainColor,width: 1.0)
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                                width: MediaQuery.of(context).size.width,
                                color:kMainColor,
                                padding: EdgeInsets.only(left: 20,top: 5,bottom: 5),
                                child: Text(locale.orderdetail1,style: TextStyle(
                                    color:kWhiteColor
                                ),)
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(locale.orderdetail2,style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600
                                  ),),
                                  Text('${makeOrderData.order_date}',style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600
                                  ),),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(locale.orderdetail3,style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600
                                  ),),
                                  Text('${makeOrderData.delivery_date}',style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600
                                  ),),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(locale.orderdetail4,style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600
                                  ),),
                                  Text('${makeOrderData.time_slot}',style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600
                                  ),),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        margin: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                            border: Border.all(color: kMainColor,width: 1.0)
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                                width: MediaQuery.of(context).size.width,
                                color:kMainColor,
                                padding: EdgeInsets.only(left: 20,top: 5,bottom: 5),
                                child: Text(locale.orderdetail5,style: TextStyle(
                                    color:kWhiteColor
                                ),)
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Text(
                                        '${addressData.type}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .button
                                            .copyWith(color: Colors.black)
                                    ),
                                  ),
                                  SizedBox(height: 10,),
                                  Text(
                                    '${addressshow}',
                                    textAlign: TextAlign.start,
                                    softWrap: true,
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        margin: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                            border: Border.all(color: kMainColor,width: 1.0)
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                                width: MediaQuery.of(context).size.width,
                                color:kMainColor,
                                padding: EdgeInsets.only(left: 20,top: 5,bottom: 5),
                                child: Text(locale.orderdetail6,style: TextStyle(
                                    color:kWhiteColor
                                ),)
                            ),
                            buildAmountRow(locale.cartTotal, '$apcurrency ${makeOrderData.price_without_delivery}'),
                            buildAmountRow(locale.deliveryFee, '$apcurrency ${makeOrderData.delivery_charge}'),
                            Visibility(
                              visible: (makeOrderData.coupon_discount!=null && double.parse('${makeOrderData.coupon_discount}')>0)?true:false,
                                child: buildAmountRow(locale.promoCode, '-$apcurrency $promocodeprice')
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(
                            horizontal: 2, vertical: 10),
                        padding: EdgeInsets.symmetric(
                            horizontal: 5, vertical: 10),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(2)),
                            border: Border.all(color: kMainColor, width: 1.0)
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(locale.orderdetail7, style: TextStyle(
                              color: kMainTextColor,
                              fontSize: 16,
                            ),),
                            GestureDetector(
                              onTap: () {
                                // OffersPage()
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                      return OffersPage();
                                    })).then((value) {
                                  if (value != null || value != 'null') {
                                    print('code - ${value}');
                                    applyCoupon(value);
                                  }
                                }).catchError((e) {

                                });
                              },
                              behavior: HitTestBehavior.opaque,
                              child: Row(
                                children: [
                                  Text(locale.viewAll),
                                  SizedBox(width: 5,),
                                  Icon(Icons.arrow_right, size: 25,
                                    color: kMainColor,)
                                ],
                              ),
                            )
                          ],),
                      ),
                      TextField(
                        decoration: InputDecoration(
                            hintText: locale.addPromocode,
                            fillColor: Colors.grey[100],
                            filled: true,
                            suffixIcon: FlatButton(
                              onPressed: () {
//                            Scaffold.of(context).showSnackBar(new SnackBar(
//                                content: new Text('Promo Code Applied!')
//                            ));
                              if(promoC.text!=null && promoC.text.length>0){
                                applyCoupon(promoC.text);
                              }
                              },
                              child: Text(
                                (makeOrderData.coupon_discount!=null && double.parse('${makeOrderData.coupon_discount}')>0)?locale.applied:locale.apply,
                                textAlign: TextAlign.center,
                                style: TextStyle(color: kMainColor),
                              ),
                            ),
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                            )),
                          readOnly: progressadd,
                          controller:promoC,
                      ),
                    ],
                  ),
                )
                    : Align(
                  alignment: Alignment.center,
                  widthFactor: 50,
                  heightFactor: 50,
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: CircularProgressIndicator(),
                  ),
                )),
            SizedBox(
              height: 5,
            ),
            (!progressadd)?GestureDetector(
              onTap: (){
                Navigator.pushNamed(context, PageRoutes.paymentMode,arguments: {
                'cart_id':'${cart_id}',
                'cartdetails':cartItemd,
                'storedetails':storeDetails,
                'orderdetails':makeOrderData,
                'address':addressData,
                });
              },
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: 60,
                color: kMainColor,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      Text(
                        locale.checkoutNow,
                        style: Theme.of(context).textTheme.button,
                      ),
                      Spacer(
                        flex: 6,
                      ),
                      Text(locale.total,
                          style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[100],
                              fontWeight: FontWeight.w500)),
                      Spacer(
                        flex: 1,
                      ),
                      Text(
                        '$apcurrency ${makeOrderData.rem_price}',
                        style: Theme.of(context).textTheme.button,
                      )
                    ],
                  ),
                ),
              ),
            ):
            Container(
              height: 52,
              alignment: Alignment.center,
              child: SizedBox(
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator()
              ),
            ),
          ],
        ),
      ),
    );
  }

  Padding buildAmountRow(String text, String price) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
      child: Row(
        children: [
          Text(
            text,
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
          ),
          Spacer(),
          Text(
            price,
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
          ),
        ],
      ),
    );
  }

  void applyCoupon(String couponCode){
    setState(() {
      progressadd = true;
    });
    var http = Client();
    http.post(applyCouponUri,body: {
      'cart_id':'$cart_id',
      'coupon_code':'${couponCode}',
    }).then((value){
      print('cc value ${value.body}');
      if(value.statusCode == 200){
        MakeOrderBean orderBean = MakeOrderBean.fromJson(jsonDecode(value.body));
        if('${orderBean.status}' == '1'){
          setState(() {
            makeOrderData = orderBean.data;
            promocodeprice = double.parse('${makeOrderData.coupon_discount}');
            promoC.text = '$couponCode';
          });
          // Navigator.pushNamed(context, CheckOutRoutes.paymentMode,arguments: {
          //   'cart_id':'${orderBean.data.cart_id}',
          //   'cartdetails':cartItemd,
          //   'storedetails':storeDetails,
          //   'orderdetails':orderBean.data,
          //   'address':selectedAddrs,
          // });
        }
      }
      setState(() {
        progressadd = false;
      });
    }).catchError((e){
      setState(() {
        progressadd = false;
      });
      print(e);
    });
  }

}
