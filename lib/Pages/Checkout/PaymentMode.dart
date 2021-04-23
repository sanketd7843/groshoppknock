import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_paystack/flutter_paystack.dart';
import 'package:groshop/Auth/checkout_navigator.dart';
import 'package:groshop/Locale/locales.dart';
import 'package:groshop/Routes/routes.dart';
import 'package:groshop/Theme/colors.dart';
import 'package:groshop/baseurl/baseurlg.dart';
import 'package:groshop/beanmodel/addressbean/showaddress.dart';
import 'package:groshop/beanmodel/cart/cartitembean.dart';
import 'package:groshop/beanmodel/cart/makeorderbean.dart';
import 'package:groshop/beanmodel/paymentbean/paymentbean.dart';
import 'package:groshop/beanmodel/striperes/chargeresponse.dart';
import 'package:groshop/beanmodel/walletbean/walletget.dart';
import 'package:groshop/paypal/paypalpayment.dart';
import 'package:http/http.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stripe_payment/stripe_payment.dart';
import 'package:toast/toast.dart';

class PaymentModePage extends StatefulWidget {
  // final VoidCallback onBackButtonPressed;
  //
  // PaymentModePage(this.onBackButtonPressed);

  @override
  _PaymentModePageState createState() => _PaymentModePageState();
}

class _PaymentModePageState extends State<PaymentModePage> {
  Razorpay _razorpay;
  double walletAmount = 0.0;
  double deWalletAmount = 0.0;
  double previousAmount = 0.0;
  bool isWallet = false;
  var publicKey = '';
  var razorPayKey = '';
  bool razor = false;
  bool paystack = false;
  final _formKey = GlobalKey<FormState>();
  final _verticalSizeBox = const SizedBox(height: 20.0);
  final _horizontalSizeBox = const SizedBox(width: 10.0);
  String _cardNumber;
  String _cvv;
  int _expiryMonth = 0;
  int _expiryYear = 0;
  var http = Client();
  RazorPayBean rpayBean;
  PayPalBean payPalBean;
  PaystackBean paystackBean;
  StripeBean stripeBean;
  bool isLoading = true;
  dynamic cart_id;
  dynamic apCurrency;
  dynamic store_id;
  bool enterFirst = false;
  AddressData addressData;
  List<CartItemData> cartItemd = [];
  CartStoreDetails storeDetails;
  MakeOrderData makeOrderData;

  bool showPaymentDialog = false;
  bool _inProgress = false;
  // bool isLoading = true;


  @override
  void initState() {
    super.initState();
    getWalletAmount();
    getPaymentList();
  }

  void getPaymentList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      apCurrency = prefs.getString('app_currency');
    });
    http.get(paymentGatewaysUri).then((value) {
      print('ppy - ${value.body}');
      if (value.statusCode == 200) {
        PaymentMain data1 = PaymentMain.fromJson(jsonDecode(value.body));
        if (data1.status == "1" || data1.status == 1) {
          setState(() {
            rpayBean = data1.razorpay;
            payPalBean = data1.paypal;
            paystackBean = data1.paystack;
            stripeBean = data1.stripe;
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

  void getWalletAmount() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var url = walletAmountUri;
    var http = Client();
    http.post(url, body: {'user_id': '${pref.getInt('user_id')}'}).then(
            (value) {
          print('resp - ${value.body}');
          if (value.statusCode == 200) {
            // amount
            WalletGet data1 = WalletGet.fromJson(jsonDecode(value.body));
            print('${data1.toString()}');
            if ('${data1.status}' == '1') {
              setState(() {
                walletAmount = double.parse('${data1.data}');
              });
            }
          }
        }).catchError((e) {
          print(e);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);
    Map<String,dynamic> receivedData = ModalRoute.of(context).settings.arguments;
    setState(() {
      if (!enterFirst) {
        enterFirst = true;
        cart_id = receivedData['cart_id'];
        cartItemd = receivedData['cartdetails'];
        storeDetails = receivedData['storedetails'];
        makeOrderData = receivedData['orderdetails'];
        addressData = receivedData['address'];
      }
    });
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Stack(
          children: [
            // Visibility(
            //   visible: isLoading,
            //     child: Container(
            //       height: MediaQuery.of(context).size.height,
            //       width: MediaQuery.of(context).size.width,
            //   child: ,
            // )),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Image.asset(
                      'assets/header.png',
                      height: 200,
                      fit: BoxFit.fitHeight,
                    ),
                    IconButton(
                        padding: EdgeInsets.only(top: 70),
                        icon: Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        }),
                    Positioned.directional(
                        textDirection: Directionality.of(context),
                        top: 70,
                        start: MediaQuery.of(context).size.width / 3.5,
                        child: Text(
                          locale.paymentMode.toUpperCase(),
                          style: TextStyle(
                              letterSpacing: 1,
                              fontWeight: FontWeight.w500,
                              fontSize: 18,
                              color: Theme.of(context).scaffoldBackgroundColor),
                        )),
                    Positioned.directional(
                      top: 130,
                      width: MediaQuery.of(context).size.width,
                      textDirection: Directionality.of(context),
                      child: isLoading? Container(
                        width:MediaQuery.of(context).size.width,
                        height: 60,
                        alignment: Alignment.center,
                        child: Align(
                            widthFactor: 40,
                            heightFactor: 40,
                            alignment: Alignment.center,
                            child: CircularProgressIndicator()
                        ),
                      ):Row(
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
                    child:
                    (!isLoading)?
                    SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Visibility(
                              visible: (walletAmount>0.0),
                              child: buildPaymentHead(context, locale.mywallet)
                          ),
                          Visibility(
                            visible: (walletAmount>0.0),
                            child: buildPaymentType(
                                Icon(
                                  Icons.account_balance_wallet_sharp,
                                  size: 24,
                                  color: Colors.grey[700],
                                ),
                                '${walletAmount}',callback:(){
                              if(!isLoading){
                                setState(() {
                                  isLoading = true;
                                });
                                double amtt;
                                double checkoutAmout = double.parse('${makeOrderData.rem_price}');
                                if(walletAmount>=checkoutAmout){
                                  checkOut('Wallet', 'success', 'yes', '', '');
                                }else{
                                  setState(() {
                                    isLoading = false;
                                  });
                                  Toast.show(locale.paymentmethod1, context,duration: Toast.LENGTH_SHORT,gravity: Toast.CENTER);
                                }
                              }
                            }),
                          ),
                          Visibility(
                            visible: (paystackBean!=null && '${paystackBean.paystack_status}'=='yes' || '${paystackBean.paystack_status}'=='Yes' || '${paystackBean.paystack_status}'=='YES')?true:false,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                buildPaymentHead(context, locale.cards),
                                buildPaymentType(
                                    Icon(
                                      Icons.credit_card,
                                      size: 24,
                                      color: Colors.grey[700],
                                    ),
                                    locale.creditCard,callback:(){
                                      if(!isLoading){
                                        setState(() {
                                          isLoading = true;
                                        });
                                        payStatck("${paystackBean.paystack_public_key}",(double.parse('${makeOrderData.rem_price}')*100).toInt(),context);
                                      }

                                }),
                                buildPaymentType(
                                    Icon(
                                      Icons.credit_card,
                                      size: 24,
                                      color: Colors.grey[700],
                                    ),
                                    locale.debitCard,callback: (){
                                      if(!isLoading){
                                        setState(() {
                                          isLoading = true;
                                        });
                                        payStatck("${paystackBean.paystack_public_key}",(double.parse('${makeOrderData.rem_price}')*100).toInt(),context);
                                      }
                                }),
                                Divider(
                                  thickness: 0.2,
                                  height: 8,
                                ),
                              ],
                            ),
                          ),
                          buildPaymentHead(context, locale.cash),
                          buildPaymentType(Image.asset('assets/PaymentIcons/payment_cod.png'),
                              locale.cashOnDelivery,callback: (){
                                if(!isLoading){
                                  setState(() {
                                    isLoading = true;
                                  });
                                  checkOut('COD', 'success', 'no', '', '');
                                }

                              }),
                          Divider(
                            thickness: 0.2,
                            height: 8,
                          ),
                          buildPaymentHead(context, locale.otherMethods),
                          Visibility(
                            visible: (payPalBean!=null && '${payPalBean.paypal_status}'=='yes' || '${payPalBean.paypal_status}'=='Yes' || '${payPalBean.paypal_status}'=='YES')?true:false,
                            child: buildPaymentType(
                                Image.asset('assets/PaymentIcons/payment_paypal.png'), locale.paypal,callback: (){
                              // PaypalPayment(clientId:'${payPalBean.paypal_client_id}',secret:'${payPalBean.paypal_secret}',amount: '${double.parse('${makeOrderData.rem_price}')}',onFinish:(id,status){
                              //   print('$id $status');
                              //   if(status=='success'){
                              //     checkOut('Card', 'success', 'no', '$id', 'paypal');
                              //   }
                              // });
                              print('done');
                              if(!isLoading){
                                setState(() {
                                  isLoading = true;
                                });
                                Navigator.of(context).push(MaterialPageRoute(builder: (context){
                                  return PaypalPayment(apCurrency:apCurrency,clientId:'${payPalBean.paypal_client_id}',secret:'${payPalBean.paypal_secret}',amount: '${double.parse('${makeOrderData.rem_price}')}',onFinish:(id,status){
                                    print('$id $status');
                                    if(status=='success'){
                                      checkOut('Card', 'success', 'no', '$id', 'paypal');
                                    }else{
                                      setState(() {
                                        isLoading = false;
                                      });
                                    }
                                  });
                                })).catchError((e){
                                  setState(() {
                                    isLoading = false;
                                  });
                                });
                              }
                            }),
                          ),
                          Visibility(
                            visible: (paystackBean!=null && '${paystackBean.paystack_status}'=='yes' || '${paystackBean.paystack_status}'=='Yes' || '${paystackBean.paystack_status}'=='YES')?true:false,
                            child: buildPaymentType(
                                Image.asset('assets/PaymentIcons/payment_paypal.png'), locale.paystack,callback: (){
                              if(!isLoading){
                                setState(() {
                                  isLoading = true;
                                });
                                  payStatck("${paystackBean.paystack_public_key}",(double.parse('${makeOrderData.rem_price}')*100).toInt(),context);
                              }

                            }),
                          ),
                          Visibility(
                            visible: (rpayBean!=null && '${rpayBean.razorpay_status}'=='yes' || '${rpayBean.razorpay_status}'=='Yes' || '${rpayBean.razorpay_status}'=='YES')?true:false,
                            child: buildPaymentType(
                                Image.asset('assets/PaymentIcons/payment_paypal.png'), locale.razorpay,callback:(){
                              if(!isLoading){
                                setState(() {
                                  isLoading = true;
                                });
                                openCheckout('${rpayBean.razorpay_key}', (double.parse('${makeOrderData.rem_price}')*100),'${rpayBean.razorpay_secret}');
                              }

                            }),
                          ),
                          Visibility(
                            visible: (stripeBean!=null && '${stripeBean.stripe_status}'=='yes' || '${stripeBean.stripe_status}'=='Yes' || '${stripeBean.stripe_status}'=='YES')?true:false,
                            child: buildPaymentType(
                                Image.asset('assets/PaymentIcons/payment_stripe.png'), locale.stripe,callback: (){
                              if(!isLoading){
                                setState(() {
                                  isLoading = true;
                                  // showPaymentDialog = true;
                                });
                                StripePayment.setOptions(
                                    StripeOptions(
                                      publishableKey:'${stripeBean.stripe_publishable}',
                                      merchantId: '${stripeBean.stripe_merchant_id}',
                                      androidPayMode: 'test',
                                    ));
                                Navigator.of(context).pushNamed(PageRoutes.stripecard).then((value){
                                  if(value!=null){
                                    CreditCard cardPay = value;
                                    setStripePayment(stripeBean.stripe_secret,double.parse('${makeOrderData.rem_price}'),cardPay);
                                  }else{
                                    Toast.show('Payment cancelled', context,gravity: Toast.CENTER,duration: Toast.LENGTH_SHORT);
                                    setState(() {
                                      isLoading = false;
                                    });
                                  }
                                }).catchError((e){
                                  Toast.show('Payment cancelled', context,gravity: Toast.CENTER,duration: Toast.LENGTH_SHORT);
                                  setState(() {
                                    isLoading = false;
                                  });
                                });
                              }

                            }),
                          ),
                          Visibility(
                            visible: false,
                            child: buildPaymentType(Image.asset('assets/PaymentIcons/payment_payu.png'),
                                locale.payumoney,callback: (){
                                  if(!isLoading){
                                    Toast.show('Comming Soon', context,gravity: Toast.CENTER,duration: Toast.LENGTH_SHORT);
                                  }
                                }),
                          ),
                        ],
                      ),
                    )
                        :Container())
              ],
            ),
          ],
        ),
      ),
    );
  }

  Padding buildPaymentHead(BuildContext context, String name) {
    return Padding(
      padding:
          const EdgeInsets.only(left: 28.0, right: 28.0, top: 14, bottom: 4),
      child: Text(
        name,
        style: Theme.of(context).textTheme.subtitle2.copyWith(
            fontSize: 16,
            color: Color(0xffa9a9a9),
            fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget buildPaymentType(var icon, String name, {Function callback}) {
    return InkWell(
      onTap: (){
        callback();
        // checkOut();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 28.0),
        child: Row(
          children: [
            CircleAvatar(
                backgroundColor: Colors.grey[300], radius: 20, child: icon),
            SizedBox(
              width: 20,
            ),
            Text(
              name,
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
            )
          ],
        ),
      ),
    );
  }

  void checkOut(String paymentMethod, String paymentStatus, String wallet, String paymentid, String paymentGateway){
    var http = Client();
    http.post(checkoutUri,body: {
      'cart_id':'${makeOrderData.cart_id}',
      'payment_method':'$paymentMethod',
      'payment_status':'$paymentStatus',
      'wallet':'$wallet',
      'payment_id':'$paymentid',
      'payment_gateway':'$paymentGateway',
    }).then((value){
      print('payment - ${value.body}');
      if(value.statusCode == 200){
        MakeOrderBean orderBean = MakeOrderBean.fromJson(jsonDecode(value.body));
        if('${orderBean.status}' == '1'){
          Navigator.pushNamed(context, PageRoutes.confirmOrder);
          Toast.show(orderBean.message, context,duration: Toast.LENGTH_SHORT,gravity: Toast.CENTER);
        }else if('${orderBean.status}' == '2'){
          Navigator.pushNamed(context, PageRoutes.confirmOrder);
          Toast.show(orderBean.message, context,duration: Toast.LENGTH_SHORT,gravity: Toast.CENTER);
        }else{
          Toast.show(orderBean.message, context,duration: Toast.LENGTH_SHORT,gravity: Toast.CENTER);
        }
      }else{
        Toast.show('Something went wrong!', context,duration: Toast.LENGTH_SHORT,gravity: Toast.CENTER);
      }
      setState(() {
        isLoading = false;
      });
    }).catchError((e){
      setState(() {
        isLoading = false;
      });
      Toast.show('Something went wrong!', context,duration: Toast.LENGTH_SHORT,gravity: Toast.CENTER);
print(e);
    });
  }


  void payStatck(String key, int price, BuildContext context) async {
    if(key.startsWith("pk_")){
      PaystackPlugin.initialize(publicKey: key).then((value){
        // setState(() {
        //   showPaymentDialog = true;
        //   isLoading = false;
        // });
        _startAfreshCharge((int.parse('${makeOrderData.rem_price}')*100));
      }).catchError((e){
        setState(() {
          isLoading = false;
        });
        print(e);
      });
    }else{
      setState(() {
        isLoading = false;
      });
      Toast.show('Server down please use another payment method.', context,duration: Toast.LENGTH_SHORT,gravity: Toast.CENTER);
    }
  }


  void razorPay(keyRazorPay, amount, String secretKey) async {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    createOrderId(keyRazorPay,secretKey,amount.toInt(),'INR','order_trn_${DateTime.now().millisecond}',_razorpay);
  }

  void openCheckout(keyRazorPay, amount, String secretKey) async {
    razorPay(keyRazorPay, amount,secretKey);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    if(response.paymentId!=null){
      checkOut('Card', 'success', 'no', '${response.paymentId}', 'razorpay');
    }
    setState(() {
      isLoading = false;
    });
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    setState(() {
      isLoading = false;
    });
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    setState(() {
      isLoading = false;
    });
  }

  void createOrderId(dynamic clientid, dynamic secretKey, dynamic amount, dynamic currency, dynamic receiptId, Razorpay razorpay) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var authn = 'Basic ' + base64Encode(utf8.encode('$clientid:$secretKey'));
    Map<String, String> headers = {
      'Authorization': authn,
      'Content-Type': 'application/json'
    };

    var body = {
      'amount':'$amount',
      'currency':'$currency',
      'receipt':'$receiptId',
      'payment_capture':true,
    };

    //
    http.post(orderApiRazorpay,body: jsonEncode(body),headers: headers).then((value){
      print('orderid data - ${value.body}');
      var jsData = jsonDecode(value.body);
      Timer(Duration(seconds: 1), () async {
        var options = {
          'key': '${clientid}',
          'amount': amount,
          'name': '${prefs.getString('user_name')}',
          'description': 'Wallet Recharge',
          'order_id': '${jsData['id']}',
          'prefill': {
            'contact': '${prefs.getString('user_phone')}',
            'email': '${prefs.getString('user_email')}'
          },
          'external': {
            'wallets': ['paytm']
          }
        };

        try {
          _razorpay.open(options);
        } catch (e) {
          setState(() {
            isLoading = false;
          });
          debugPrint(e);
        }
      });
    }).catchError((e){
      print(e);
      setState(() {
        isLoading = false;
      });
    });

  }


  _startAfreshCharge(int price) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // _formKey.currentState.save();

    Charge charge = Charge()
      ..amount = price // In base currency
      ..email = '${prefs.getString('user_email')}'
      ..currency = '${prefs.getString('app_currency')}'
      ..card = _getCardFromUI()
      ..reference = _getReference();

    _chargeCard(charge);
  }

  _chargeCard(Charge charge) async {
    PaystackPlugin.chargeCard(context, charge: charge).then((value) {
      print('${value.status}');
      print('${value.toString()}');
      print('${value.card}');

      if (value.status && value.message == "Success") {
        setState(() {
          // showPaymentDialog = false;
          // _inProgress = false;
          // showDialogBox = true;
        });
        checkOut('Card', 'success', 'no', '${value.reference}', 'paystack');
      }
    }).catchError((e){
      setState(() {
        isLoading = false;
      });
    });
  }

  String _getReference() {
    String platform;
    if (Platform.isIOS) {
      platform = 'iOS';
    } else {
      platform = 'Android';
    }

    return 'ChargedFrom${platform}_${DateTime.now().millisecondsSinceEpoch}';
  }

  PaymentCard _getCardFromUI() {
    return PaymentCard(
      number: _cardNumber,
      cvc: _cvv,
      expiryMonth: _expiryMonth,
      expiryYear: _expiryYear,
    );
  }


  void setStripePayment(dynamic clientScretKey, double amount, CreditCard creditCardPay) {
    print('${creditCardPay.toJson().toString()}');
    Map<String, String> headers = {
      'Authorization': 'Bearer ${clientScretKey}',
      'Content-Type': 'application/x-www-form-urlencoded'
    };
    StripePayment.createPaymentMethod(PaymentMethodRequest(
        card: creditCardPay
    )).then((value){
      print('pt - ${value.toJson().toString()}');
      createPaymentIntent('${amount.toInt()*100}','INR',headers,value,clientScretKey);
    }).catchError((e){
      Toast.show(e.message, context,gravity: Toast.CENTER,duration: Toast.LENGTH_SHORT);
      setState(() {
        isLoading = false;
      });
    });
  }

  void createPaymentIntent(String amount, String currency,Map<String, String> hearder, PaymentMethod paymentMethod, clientScretKey) async {
    try {
      Map<String, dynamic> body = {
        'amount': amount,
        'currency': currency,
        'payment_method_types[]': 'card',
        'description': 'Shopping'
      };
      http.post(
          paymentApiUrl,
          body: body,
          headers: hearder
      ).then((value){
        var js = jsonDecode(value.body);
        print('pIntent - ${value.body}');
        print('pIntent1 - ${paymentMethod.id}');
        StripePayment.confirmPaymentIntent(
          PaymentIntent(
            clientSecret: '${js['client_secret']}',
            paymentMethodId: '${paymentMethod.id}',
          ),
        ).then((paymentIntent) {
          print('cIntent - ${paymentIntent.toJson().toString()}');
          if('${paymentIntent.status}'.toUpperCase()=='succeeded'.toUpperCase()){
            checkOut('Card', 'success', 'no', '${paymentIntent.paymentIntentId}', 'stripe');
          }else{
            setState(() {
              isLoading = false;
            });
          }
          setState(() {
            isLoading = false;
          });
        }).catchError((e){
          print(e);
          Toast.show(e.message, context,gravity: Toast.CENTER,duration: Toast.LENGTH_SHORT);
          setState(() {
            isLoading = false;
          });
        });
      }).catchError((e){
        print('dd ${e}');
        Toast.show(e.message, context,gravity: Toast.CENTER,duration: Toast.LENGTH_SHORT);
        setState(() {
          isLoading = false;
        });
      });
    } catch (err) {
      Toast.show('something went wrong with your payment if any amount deduct please wait for 10-15 working days.', context,gravity: Toast.CENTER,duration: Toast.LENGTH_SHORT);
      setState(() {
        isLoading = false;
      });
    }
  }

  void createCharge(String tokenId,dynamic secretKey,dynamic currency,dynamic amount, Map<String, String> headers) async {
    try {
      Map<String, dynamic> body = {
        'amount': '$amount',
        'currency': '$currency',
        'source': tokenId,
        'description': 'Wallet Recharge'
      };
      http.post(
          'https://api.stripe.com/v1/charges',
          body: body,
          headers: headers
      ).then((value){
        print('ss - ${value.body}');
        if(value.body.toString().contains('error')){
          var jsd = jsonDecode(value.body);
          Error errorResp = Error.fromJson(jsd['error']);
          Toast.show('${errorResp.message}', context,duration: Toast.LENGTH_SHORT,gravity: Toast.CENTER);
          setState(() {
            isLoading = false;
          });
        }else{
          StripeChargeResponse chargeResp = StripeChargeResponse.fromJson(jsonDecode(value.body));
          if('${chargeResp.status}'.toUpperCase()=='succeeded'.toUpperCase()){
            checkOut('Card', 'success', 'no', '${chargeResp.paymentMethod}', 'stripe');
          }else{
            setState(() {
              isLoading = false;
            });
          }
        }
      });
    } catch (err) {
      print('err charging user: ${err.toString()}');
      setState(() {
        isLoading = false;
      });
    }
  }

}
