import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:groshop/Auth/checkout_navigator.dart';
import 'package:groshop/Components/drawer.dart';
import 'package:groshop/Locale/locales.dart';
import 'package:groshop/Pages/Search/search_history.dart';
import 'package:groshop/Pages/locpage/locationpage.dart';
import 'package:groshop/Routes/routes.dart';
import 'package:groshop/Theme/colors.dart';
import 'package:groshop/baseurl/baseurlg.dart';
import 'package:groshop/beanmodel/appinfo.dart';
import 'package:groshop/beanmodel/appnotice/appnotice.dart';
import 'package:groshop/beanmodel/banner/bannerdeatil.dart';
import 'package:groshop/beanmodel/category/topcategory.dart';
import 'package:groshop/beanmodel/deal/dealproduct.dart';
import 'package:groshop/beanmodel/productbean/productwithvarient.dart';
import 'package:groshop/beanmodel/productbean/recentsale.dart';
import 'package:groshop/beanmodel/storefinder/storefinderbean.dart';
import 'package:groshop/beanmodel/whatsnew/whatsnew.dart';
import 'package:groshop/beanmodel/wishlist/wishdata.dart';
import 'package:groshop/main.dart';
import 'package:groshop/nav_bloc/navigation_bloc.dart';
import 'package:http/http.dart';
import 'package:marquee/marquee.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:toast/toast.dart';

class HomePage extends StatefulWidget with NavigationStates {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  var _current = 0;
  bool islogin = false;
  dynamic _scanBarcode;
  String store_id = '';
  String storeName = '';
  String shownMessage = '';
  StoreFinderData storeFinderData;
  List<BannerDataModel> bannerList = [];
  List<WhatsNewDataModel> whatsNewList = [];
  List<WhatsNewDataModel> recentSaleList = [];
  List<WhatsNewDataModel> topSaleList = [];
  List<DealProductDataModel> dealProductList = [];
  List<TopCategoryDataModel> topCategoryList = [];
  List<WishListDataModel> wishModel = [];
  dynamic userName;
  bool bannerLoading = true;
  bool topCatLoading = true;
  bool topSellingLoading = true;
  bool whatsnewLoading = true;
  bool recentSaleLoading = true;
  bool dealProductLoading = true;

  dynamic lat;
  dynamic lng;
  CameraPosition kGooglePlex = CameraPosition(
    target: LatLng(40.866813,34.566688),
    zoom: 19.151926,
  );
  String currentAddress = "";
  Completer<GoogleMapController> _controller = Completer();

  String apCurrency;

  String appnoticetext = '';
  bool appnoticeStatus = false;
  Future<void> _goToTheLake(lat, lng) async {
    // final CameraPosition _kLake = CameraPosition(
    //     bearing: 192.8334901395799,
    //     target: LatLng(lat, lng),
    //     tilt: 59.440717697143555,
    //     zoom: 19.151926040649414);
    setState(() {
      this.lat = lat;
      this.lng = lng;
    });
    kGooglePlex = CameraPosition(
      target: LatLng(lat,lng),
      zoom: 19.151926,
    );
    getStoreId();
    // final GoogleMapController controller = await _controller.future;
    // controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
  }

  // GlobalKey<ScaffoldState> scafKey = new GlobalKey<ScaffoldState>();

  void scanProductCode(BuildContext context) async {
    await FlutterBarcodeScanner.scanBarcode(
            "#ff6666", "Cancel", true, ScanMode.DEFAULT)
        .then((value) {
      setState(() {
        _scanBarcode = value;
      });
      print('scancode - ${_scanBarcode}');
      Navigator.pushNamed(context, PageRoutes.search, arguments: {
        'ean_code': _scanBarcode,
        'storedetails': storeFinderData,
      });
    }).catchError((e) {});
  }

  void getSharedValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      islogin = prefs.getBool('islogin');
      userName = prefs.getString('user_name');
      apCurrency = prefs.getString('app_currency');
    });
  }

  @override
  void initState() {
    super.initState();
    getSharedValue();
    hitAppInfo();
    hitAppNotice();
    _getLocation();

    // hitAsyncList();
  }

  void hitAsyncList() async {
    getWislist();
    getBannerList();
    getWhatsNewList();
    getDealProductsList();
    getTopCategoryList();
    getRecentSaleList();
    getTopSellingList();
  }

  void getWislist() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    dynamic userId = prefs.getInt('user_id');
    var url = showWishlistUri;
    var http = Client();
    http.post(url, body: {
      'user_id': '${userId}',
      'store_id':'${store_id}'
    }).then((value){
      print('resp - ${value.body}');
      if(value.statusCode == 200){
        WishListModel data1 = WishListModel.fromJson(jsonDecode(value.body));
        if(data1.status=="1" || data1.status==1){
          setState(() {
            wishModel.clear();
            wishModel = List.from(data1.data);
          });
        }
      }
    }).catchError((e){
    });
  }

  void getBannerList() async {
    // SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      bannerLoading = true;
    });
    var http = Client();
    http.post(storeBannerUri, body: {'store_id': '${store_id}'}).then((value) {
      if (value.statusCode == 200) {
        BannerModel data1 = BannerModel.fromJson(jsonDecode(value.body));
        if (data1.status == "1" || data1.status == 1) {
          setState(() {
            bannerList.clear();
            bannerList = List.from(data1.data);
          });
        }
      }
      setState(() {
        bannerLoading = false;
      });
    }).catchError((e) {
      setState(() {
        bannerLoading = false;
      });
      print(e);
    });
  }

  void getWhatsNewList() async {
    // SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      whatsnewLoading = true;
    });
    var http = Client();
    http.post(whatsNewUri, body: {'store_id': '${store_id}'}).then((value) {
      if (value.statusCode == 200) {
        WhatsNewModel data1 = WhatsNewModel.fromJson(jsonDecode(value.body));
        if (data1.status == "1" || data1.status == 1) {
          setState(() {
            whatsNewList.clear();
            whatsNewList = List.from(data1.data);
          });
        }
      }
      setState(() {
        whatsnewLoading = false;
      });
    }).catchError((e) {
      setState(() {
        whatsnewLoading = false;
      });
      print(e);
    });
  }

  void getDealProductsList() async {
    // SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      dealProductLoading = true;
    });
    var http = Client();
    http.post(dealProductUri, body: {'store_id': '${store_id}'}).then((value) {
      if (value.statusCode == 200) {
        DealProductModel data1 =
            DealProductModel.fromJson(jsonDecode(value.body));
        if (data1.status == "1" || data1.status == 1) {
          setState(() {
            dealProductList.clear();
            dealProductList = List.from(data1.data);
          });
        }
      }
      setState(() {
        dealProductLoading = false;
      });
    }).catchError((e) {
      setState(() {
        dealProductLoading = false;
      });
      print(e);
    });
  }

  void getTopCategoryList() async {
    // SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      topCatLoading = true;
    });
    var http = Client();
    http.post(topCatUri, body: {'store_id': '${store_id}'}).then((value) {
      if (value.statusCode == 200) {
        TopCategoryModel data1 =
            TopCategoryModel.fromJson(jsonDecode(value.body));
        if (data1.status == "1" || data1.status == 1) {
          setState(() {
            topCategoryList.clear();
            topCategoryList = List.from(data1.data);
          });
        }
      }
      setState(() {
        topCatLoading = false;
      });
    }).catchError((e) {
      setState(() {
        topCatLoading = false;
      });
      print(e);
    });
  }

  void getRecentSaleList() async {
    // SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      recentSaleLoading = true;
    });
    var http = Client();
    http.post(recentSellingUri, body: {'store_id': '${store_id}'}).then((value) {
      if (value.statusCode == 200) {
        WhatsNewModel data1 =
        WhatsNewModel.fromJson(jsonDecode(value.body));
        if ('${data1.status}' == '1') {
          setState(() {
            recentSaleList.clear();
            recentSaleList = List.from(data1.data);
          });
        }
      }
      setState(() {
        recentSaleLoading = false;
      });
    }).catchError((e) {
      setState(() {
        recentSaleLoading = false;
      });
      print(e);
    });
  }

  void getTopSellingList() async {
    // SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      topSellingLoading = true;
    });
    var http = Client();
    http.post(topSellingUri, body: {'store_id': '${store_id}'}).then((value) {
      if (value.statusCode == 200) {
        WhatsNewModel data1 =
        WhatsNewModel.fromJson(jsonDecode(value.body));
        if ('${data1.status}' == '1') {
          setState(() {
            topSaleList.clear();
            topSaleList = List.from(data1.data);
          });
        }
      }
      setState(() {
        topSellingLoading = false;
      });
    }).catchError((e) {
      setState(() {
        topSellingLoading = false;
      });
      print(e);
    });
  }

  void hitAppInfo() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var http = Client();
    http.get(appInfoUri).then((value) {
      // print(value.body);
      if (value.statusCode == 200) {
        AppInfoModel data1 = AppInfoModel.fromJson(jsonDecode(value.body));
        print('data - ${data1.toString()}');
        if (data1.status == "1" || data1.status == 1) {
          setState(() {
            apCurrency = '${data1.currency_sign}';
          });
          prefs.setString('app_name', '${data1.app_name}');
          prefs.setString('app_currency', '${data1.currency_sign}');
          prefs.setString('country_code', '${data1.country_code}');
          prefs.setString('numberlimit', '${data1.phone_number_length}');
          prefs.setString('app_referaltext', '${data1.refertext}');
          prefs.setInt('last_loc', int.parse('${data1.last_loc}'));
        }
      }
    }).catchError((e) {
      print(e);
    });
  }

  void hitAppNotice() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var http = Client();
    http.get(appNoticeUri).then((value) {
      // print(value.body);
      if (value.statusCode == 200) {
        AppNotice data1 = AppNotice.fromJson(jsonDecode(value.body));
        print('data - ${data1.toString()}');
        if ('${data1.status}' == '1') {
          setState(() {
            appnoticetext = '${data1.data.notice}';
            appnoticeStatus = ('${data1.data.status}' == '1');
            print('notice text - $appnoticetext');
          });
        }
      }
    }).catchError((e) {
      print(e);
    });
  }

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);
    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        drawer: buildDrawer(context, userName, islogin,onHit: () {
         SharedPreferences.getInstance().then((pref){
            pref.clear().then((value) {
              Navigator.pushAndRemoveUntil(_scaffoldKey.currentContext,
                  MaterialPageRoute(builder: (context) {
                    return GroceryLogin();
                  }), (Route<dynamic> route) => false);
            });
          });
        }),
        body: Column(
          children: [
            // SizedBox(height: 12.0),
            Container(
              height: 80,
              width: MediaQuery.of(context).size.width,
              color: kMainTextColor,
              child:  Stack(
                children: [
                  // Image.asset('assets/header.png',fit: BoxFit.fill,),
                  Container(
                    height: 52,
                    margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
                    decoration: BoxDecoration(
                      color: kWhiteColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: AppBar(
                      actions: [
                        Visibility(
                          visible: (storeFinderData!=null && storeFinderData.store_id!=null),
                          child: IconButton(
                            icon: ImageIcon(AssetImage(
                              'assets/scanner_logo.png',
                            )),
                            onPressed: () async {
                              scanProductCode(context);
                            },
                          ),
                        ),
                        IconButton(
                          icon: ImageIcon(AssetImage(
                            'assets/ic_cart.png',
                          )),
                          onPressed: () async{
                            SharedPreferences prefs = await SharedPreferences.getInstance();
                            if(prefs.containsKey('islogin') && prefs.getBool('islogin')){
                              Navigator.pushNamed(context,PageRoutes.cartPage);
                            }else{
                              Toast.show(locale.loginfirst, context,gravity: Toast.CENTER,duration: Toast.LENGTH_SHORT);
                            }
                          },
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.my_location,
                          ),
                          iconSize: 25,
                          onPressed: () {
                            showAlertDialog(context,locale, currentAddress);
                            // _getLocation();
                          },
                        )
                      ],
                      title: TextFormField(
                        readOnly: true,
                        onTap: () {
                          if(storeFinderData!=null){
                            Navigator.pushNamed(context, PageRoutes.searchhistory,arguments: {
                              'category':topCategoryList,
                              'recentsale':recentSaleList,
                              'storedetails':storeFinderData,
                              'wishlist':wishModel,
                            }).then((value){
                              getWislist();
                            });
                          }
                        },
                        style: Theme.of(context)
                            .textTheme
                            .headline6
                            .copyWith(color: Colors.black, fontSize: 18),
                        decoration: InputDecoration(
                            hintText: '${locale.searchOnGroShop}$appname',
                            hintStyle: Theme.of(context).textTheme.subtitle2,
                            contentPadding:
                            EdgeInsets.symmetric(vertical: 10),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Visibility(
              visible: (appnoticeStatus && appnoticetext!=null && appnoticetext.length>15),
              child: Container(
                height: 50,
                // margin: EdgeInsets.only(top: 1),
                decoration: BoxDecoration(
                    color: kMainTextColor,
                  // image: DecorationImage(
                  //   image: AssetImage('assets/header.png'),
                  //   fit: BoxFit.fill
                  // )
                ),
                alignment: Alignment.center,
                child: (appnoticeStatus && appnoticetext!=null && appnoticetext.length>15)?Marquee(
                  text: appnoticetext,
                  style: TextStyle(fontWeight: FontWeight.bold,color: kMarqueeColor),
                  scrollAxis: Axis.horizontal,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  blankSpace: 5.0,
                  velocity: 100.0,
                  pauseAfterRound: Duration(seconds: 1),
                  startPadding: 10.0,
                  accelerationDuration: Duration(seconds: 1),
                  accelerationCurve: Curves.linear,
                  decelerationDuration: Duration(milliseconds: 500),
                  decelerationCurve: Curves.easeOut,
                ):SizedBox.shrink(),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(top: 10),
                child: (storeFinderData!=null || (topCatLoading || bannerLoading || topSellingLoading || whatsnewLoading || recentSaleLoading || dealProductLoading))
                    ?SingleChildScrollView(
                  primary: true,
                  child: Column(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width,
                        alignment: Alignment.centerRight,
                        margin: EdgeInsets.only(right: 10, bottom: 5),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, PageRoutes.all_category,arguments: {
                              'store_id':storeFinderData.store_id,
                              'storedetail':storeFinderData,
                            });
                          },
                          behavior: HitTestBehavior.opaque,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Container(
                              alignment: Alignment.centerRight,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    'View All',
                                    style: TextStyle(
                                      color: kMainTextColor,
                                    ),
                                  ),
                                  SizedBox(width: 5,),
                                  Icon(Icons.arrow_forward_ios_sharp,size: 15,)
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        height: 96,
                        child: ListView.builder(
                            physics: BouncingScrollPhysics(),
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            itemCount: topCategoryList.length,
                            itemBuilder: (contexts, index) {
                              return buildCategoryRow(
                                  context, topCategoryList[index],storeFinderData);
                            }),
                      ),
                      SizedBox(height: 16.0),
                      Stack(
                        children: [
                          CarouselSlider(
                            items: bannerList.map((i) {
                              return Builder(
                                builder: (BuildContext context) {
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.pushNamed(context, PageRoutes.cat_product, arguments: {
                                        'title': i.title,
                                        'storeid': storeFinderData.store_id,
                                        'cat_id': i.cat_id,
                                        'storedetail':storeFinderData,
                                      });
                                    },
                                    child: Container(
                                        child: CachedNetworkImage(
                                          imageUrl: '${i.banner_image}',
                                          placeholder: (context, url) => Align(
                                            widthFactor: 50,
                                            heightFactor: 50,
                                            alignment: Alignment.center,
                                            child: Container(
                                              padding: const EdgeInsets.all(5.0),
                                              width: 50,
                                              height: 50,
                                              child: CircularProgressIndicator(),
                                            ),
                                          ),
                                          errorWidget: (context, url, error) => Image.asset('assets/icon.png'),
                                        )
                                    //     Image(
                                    //   image: NetworkImage(i.banner_image),
                                    // )
                                    ),
                                  );
                                },
                              );
                            }).toList(),
                            options: CarouselOptions(
                                autoPlay: true,
                                viewportFraction: 1.0,
                                enlargeCenterPage: false,
                                onPageChanged: (index, reason) {
                                  setState(() {
                                    _current = index;
                                  });
                                }),
                          ),
                          Positioned.directional(
                            textDirection: Directionality.of(context),
                            start: 20.0,
                            bottom: 0.0,
                            child: Row(
                              children: bannerList.map((i) {
                                int index = bannerList.indexOf(i);
                                return Container(
                                  width: 12.0,
                                  height: 3.0,
                                  margin: EdgeInsets.symmetric(
                                      vertical: 16.0, horizontal: 4.0),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.rectangle,
                                    color: _current == index
                                        ? Colors.white /*.withOpacity(0.9)*/
                                        : Colors.white.withOpacity(0.5),
                                  ),
                                );
                              }).toList(),
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      (!whatsnewLoading)?Visibility(
                        visible: (whatsNewList!=null && whatsNewList.length>0),
                        child: buildCompleteVerticalList(
                            locale, context, whatsNewList, locale.fresharrived,wishModel,(){
                              getWislist();
                        },storeFinderData),
                      ):buildCompleteVerticalSHList(context),
                      (!topSellingLoading)?Visibility(
                        visible: (topSaleList!=null && topSaleList.length>0),
                        child: buildProduct(
                            locale, context, topSaleList, locale.topRated, wishModel,(){
                          getWislist();
                        },storeFinderData),
                      ):buildCompleteVerticalSHList(context),
                      (!recentSaleLoading)?Visibility(
                        visible: (recentSaleList!=null && recentSaleList.length>0),
                        child: buildProduct(locale, context, recentSaleList,
                            locale.featuredProducts, wishModel,(){
                              getWislist();
                            },storeFinderData),
                      ):buildCompleteVerticalSHList(context),
                      (!dealProductLoading)?Visibility(
                        visible: (dealProductList!=null && dealProductList.length>0),
                        child: buildDealProduct(locale, context, dealProductList,
                            locale.discountedItems,wishModel,(){
                              getWislist();
                            },storeFinderData),
                      ):buildCompleteVerticalSHList(context),
                      SizedBox(height: 20.0),
                    ],
                  ),
                )
                    :Align(
                  alignment: Alignment.center,
                  child: Text(shownMessage),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Column buildCompleteVerticalList(AppLocalizations locale,
      BuildContext context, List<WhatsNewDataModel> products, String heading, List<WishListDataModel> wishModel,Function callback,StoreFinderData storeFinderData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(16),
          child: Text(heading,
              style: Theme.of(context)
                  .textTheme
                  .subtitle1
                  .copyWith(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        buildList(products,wishModel,(){
          callback();
        },apCurrency,storeFinderData),
      ],
    );
  }

  Column buildDealProduct(AppLocalizations locale, BuildContext context,
      List<DealProductDataModel> products, String heading, List<WishListDataModel> wishModel,Function callback,StoreFinderData storeFinderData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(16),
          child: Text(heading,
              style: Theme.of(context)
                  .textTheme
                  .subtitle1
                  .copyWith(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        buildDealList(products,wishModel,(){
          callback();
        },apCurrency,storeFinderData),
      ],
    );
  }

  Column buildProduct(AppLocalizations locale, BuildContext context,
      List<WhatsNewDataModel> products, String heading, List<WishListDataModel> wishModel,Function callback,StoreFinderData storeFinderData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(16),
          child: Text(heading,
              style: Theme.of(context)
                  .textTheme
                  .subtitle1
                  .copyWith(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        buildProductList(products,wishModel,(){
          callback();
        },apCurrency,storeFinderData),
      ],
    );
  }

  void _getLocation() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(prefs.getInt('last_loc') == 0 || (!prefs.containsKey('lat') && !prefs.containsKey('lng'))){
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        bool isLocationServiceEnableds =
        await Geolocator.isLocationServiceEnabled();
        if (isLocationServiceEnableds) {
          Position position = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.high);
          if(position!=null){
            Timer(Duration(seconds: 5), () async {
              double lat = position.latitude;
              double lng = position.longitude;
              prefs.setString("lat", lat.toStringAsFixed(8));
              prefs.setString("lng", lng.toStringAsFixed(8));
              final coordinates = new Coordinates(lat, lng);
              await Geocoder.local
                  .findAddressesFromCoordinates(coordinates)
                  .then((value) {
                setState(() {
                  currentAddress = value[0].addressLine;
                });
              });
              _goToTheLake(lat, lng);
            });
          }else{
            _getLocation();
          }

        } else {
          await Geolocator.openLocationSettings().then((value) {
            if (value) {
              _getLocation();
            } else {
              Toast.show('Location permission is required!', context,
                  duration: Toast.LENGTH_SHORT);
            }
          }).catchError((e) {
            Toast.show('Location permission is required!', context,
                duration: Toast.LENGTH_SHORT);
          });
        }
      } else if (permission == LocationPermission.denied) {
        LocationPermission permissiond = await Geolocator.requestPermission();
        if (permissiond == LocationPermission.whileInUse ||
            permissiond == LocationPermission.always) {
          _getLocation();
        } else {
          Toast.show('Location permission is required!', context,
              duration: Toast.LENGTH_SHORT);
        }
      } else if (permission == LocationPermission.deniedForever) {
        await Geolocator.openAppSettings().then((value) {
          _getLocation();
        }).catchError((e) {
          Toast.show('Location permission is required!', context,
              duration: Toast.LENGTH_SHORT);
        });
      }
    }else{
      lat = double.parse('${prefs.getString('lat')}');
      lng = double.parse('${prefs.getString('lng')}');
      _goToTheLake(lat, lng);
    }

  }

  showAlertDialog(BuildContext context, AppLocalizations locale, String currentAddress) {
    Widget clear = GestureDetector(
      onTap: () {
        Navigator.of(context, rootNavigator: true).pop('dialog');
        clearAllList();

      },
      child: Material(
        elevation: 2,
        clipBehavior: Clip.hardEdge,
        borderRadius: BorderRadius.all(Radius.circular(20)),
        child: Container(
          padding: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
          decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.all(Radius.circular(20))),
          child: Text(
            locale.saveLoc,
            style: TextStyle(fontSize: 13, color: kWhiteColor),
          ),
        ),
      ),
    );

    Widget no = GestureDetector(
      onTap: () {
        Navigator.of(context, rootNavigator: true).pop('dialog');
      },
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.all(Radius.circular(20)),
        clipBehavior: Clip.hardEdge,
        child: Container(
          padding: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
          decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.all(Radius.circular(20))),
          child: Text(
            locale.notext,
            style: TextStyle(fontSize: 13, color: kWhiteColor),
          ),
        ),
      ),
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context,setState){
          return AlertDialog(
            insetPadding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
            contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            title: Text(locale.locateyourself),
            content: Container(
              height: MediaQuery.of(context).size.height*0.5,
              width: MediaQuery.of(context).size.width,
              child: Stack(
                children: [
                  GoogleMap(
                    mapType: MapType.normal,
                    initialCameraPosition: kGooglePlex,
                    zoomControlsEnabled: false,
                    myLocationButtonEnabled: false,
                    compassEnabled: false,
                    mapToolbarEnabled: false,
                    buildingsEnabled: false,
                    onMapCreated: (GoogleMapController controller) async{
                      _controller.complete(controller);
                    },
                    onCameraIdle: () async{
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      prefs.setString("lat", lat.toStringAsFixed(8));
                      prefs.setString("lng", lng.toStringAsFixed(8));
                      final coordinates = new Coordinates(lat, lng);
                      return await Geocoder.local
                          .findAddressesFromCoordinates(coordinates)
                          .then((value) {
                        setState(() {
                          currentAddress = value[0].addressLine;
                        });
                        //
                        print('${currentAddress}');
                      });
                    },
                    onCameraMove: (post) {
                      lat = post.target.latitude;
                      lng = post.target.longitude;
                    },
                  ),
                  Positioned(
                    top: 20,
                    left: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: (){
                        Navigator.of(context, rootNavigator: true).pop('locpage');
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        margin: EdgeInsets.symmetric(horizontal: 15),
                        padding: EdgeInsets.symmetric(horizontal: 15,vertical: 10),
                        decoration: BoxDecoration(
                            color: kWhiteColor,
                            borderRadius: BorderRadius.all(Radius.circular(5.0))
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.my_location,
                              size: 25,
                            ),
                            SizedBox(width: 10,),
                            Expanded(
                              child: Text('$currentAddress',
                                maxLines: 2,
                                style: TextStyle(
                                    fontSize: 12,
                                    color: kMainTextColor
                                ),),
                            ),
                          ],
                        ),
                      ),
                    ),),
                  Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 36.0),
                        child: Image.asset(
                          'assets/map_pin.png',
                          height: 36,
                        ),
                      ))
                ],
              ),
            ),
            actions: [clear, no],
          );
        });
      },
    ).then((value){
      print('dialog value - ${value}');
      if('$value'=='locpage'){
Navigator.of(context).push(MaterialPageRoute(builder: (context){
  return LocationPage(lat, lng);
})).then((value){
  print(value);
  setState(() {
    lat = double.parse('${value[0]}');
    lng = double.parse('${value[1]}');
  });
  clearAllList();
});
      }
    }).catchError((e){
      print(e);
    });
  }

  void clearAllList() async{
    setState(() {
      bannerList.clear();
      whatsNewList.clear();
      recentSaleList.clear();
      topSaleList.clear();
      dealProductList.clear();
      topCategoryList.clear();
      wishModel.clear();
      bannerLoading = true;
      topCatLoading = true;
      topSellingLoading = true;
      whatsnewLoading = true;
      recentSaleLoading = true;
      dealProductLoading = true;
    });
    getStoreId();

  }

  void getStoreId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      bannerLoading = true;
    });
    var http = Client();
    http.post(getNearestStoreUri, body: {
      'lat': '${lat}',
      'lng': '${lng}',
    }).then((value) {
      print('loc - ${value.body}');
      if (value.statusCode == 200) {
        StoreFinderBean data1 = StoreFinderBean.fromJson(jsonDecode(value.body));
        setState(() {
          shownMessage = '${data1.message}';
        });
        if ('${data1.status}' == '1') {
          setState(() {
            store_id = '${data1.data.store_id}';
            storeName = '${data1.data.store_name}';
            storeFinderData = data1.data;
            if(prefs.containsKey('storelist') && prefs.getString('storelist').length>0){
              var storeListpf = jsonDecode(prefs.getString('storelist')) as List;
              List<StoreFinderData> dataFinderL = [];
              dataFinderL = List.from(storeListpf.map((e) => StoreFinderData.fromJson(e)).toList());
              int idd1 = dataFinderL.indexOf(data1.data);
              if(idd1<0){
                dataFinderL.add(data1.data);
              }
              prefs.setString('storelist', dataFinderL.toString());
            }else{
              List<StoreFinderData> dataFinderLd = [];
              dataFinderLd.add(data1.data);
              prefs.setString('storelist', dataFinderLd.toString());
            }
            prefs.setString('store_id_last', '${storeFinderData.store_id}');
          });
        }else{
          Toast.show(data1.message, context,gravity: Toast.CENTER,duration: Toast.LENGTH_SHORT);
        }
      }
      if(store_id!=null && store_id.toString().length>0){
        hitAsyncList();
      }else{
        bannerLoading = false;
        topCatLoading = false;
        topSellingLoading = false;
        whatsnewLoading = false;
        recentSaleLoading = false;
        dealProductLoading = false;
      }
    }).catchError((e) {
      print(e);
      if(store_id!=null && store_id.toString().length>0){
        hitAsyncList();
      }else{
        bannerLoading = false;
        topCatLoading = false;
        topSellingLoading = false;
        whatsnewLoading = false;
        recentSaleLoading = false;
        dealProductLoading = false;
      }
    });
  }
}

Container buildList(List<WhatsNewDataModel> products, List<WishListDataModel> wishModel, Function callback, String apCurrency,StoreFinderData storeFinderData) {
  return Container(
    height: 240,
    child: ListView.builder(
        physics: BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        itemCount: products.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Container(
              width: MediaQuery.of(context).size.width / 2.5,
              child: buildProductCard(
                  context,
                  products[index],
                  wishModel,(){
                callback();
              },apCurrency,storeFinderData),
            ),
          );
        }),
  );
}

Container buildDealList(List<DealProductDataModel> products, List<WishListDataModel> wishModel, Function callback,String apCurrency,StoreFinderData storeFinderData) {
  return Container(
    height: 240,
    child: ListView.builder(
        physics: BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        itemCount: products.length,
        itemBuilder: (context, index) {
          WhatsNewDataModel whatsNewM = WhatsNewDataModel(productId: products[index].product_id,productName: products[index].product_name,productImage: products[index].product_image,price: products[index].price,mrp: products[index].mrp,unit: products[index].unit,quantity: products[index].quantity,varientId: products[index].varient_id,varientImage: products[index].varient_image,description: products[index].description,tags: [],stock: products[index].stock,storeId: products[index].store_id);
          return Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Container(
              width: MediaQuery.of(context).size.width / 2.5,
              child: buildProductCard(
                  context,
                  whatsNewM,
                  wishModel,(){
                callback();
              },apCurrency,storeFinderData),
            ),
          );
        }),
  );
}

Container buildProductList(List<WhatsNewDataModel> products, List<WishListDataModel> wishModel, Function callback,String apCurrency,StoreFinderData storeFinderData) {
  return Container(
    height: 240,
    child: ListView.builder(
        physics: BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        itemCount: products.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Container(
              width: MediaQuery.of(context).size.width / 2.5,
              child: buildProductCard(
                  context,
                  products[index],wishModel,(){
callback();
              },apCurrency,storeFinderData),
            ),
          );
        }),
  );
}

Widget buildProductCard(BuildContext context,WhatsNewDataModel products,List<WishListDataModel> wishModel,
    Function callback,String apCurrency,StoreFinderData storeFinderData,
    {bool favourites = false}) {
  return GestureDetector(
    onTap: () {
      ProductDataModel modelP = ProductDataModel(pId: products.productId,productImage: products.productImage,productName: products.productName,tags: products.tags,varients: <ProductVarient>[
        ProductVarient(varientId: products.varientId,description: products.description,price: products.price,mrp: products.mrp,varientImage: products.varientImage,unit: products.unit,quantity: products.quantity,stock: products.stock,storeId: products.storeId)
      ]);
      int idd = wishModel.indexOf(WishListDataModel('', '', '${products.varientId}', '', '', '', '', '', '', '', '', '', ''));
      print('${idd}');
      Navigator.pushNamed(context, PageRoutes.product,arguments: {
        'pdetails':modelP,
        'storedetails':storeFinderData,
        'isInWish': (idd>=0),
      }).then((value){
        callback();
      });
      // Navigator.push(
      //     context, MaterialPageRoute(builder: (context) => ProductInfo(image,name,productid,price,varientid,storeid)));
    },
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            Container(
              width: MediaQuery.of(context).size.width / 2.5,
              height: MediaQuery.of(context).size.width / 2.5,
              child: CachedNetworkImage(
                imageUrl: '${products.productImage}',
                placeholder: (context, url) => Align(
                  widthFactor: 50,
                  heightFactor: 50,
                  alignment: Alignment.center,
                  child: Container(
                    padding: const EdgeInsets.all(5.0),
                    width: 50,
                    height: 50,
                    child: CircularProgressIndicator(),
                  ),
                ),
                errorWidget: (context, url, error) => Image.asset('assets/icon.png'),
              ),
            ),
            // Image.network(
            //   image,
            //
            //   fit: BoxFit.fill,
            // ),
            favourites
                ? Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.favorite,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  )
                : SizedBox.shrink(),
          ],
        ),
        Text(products.productName, style: TextStyle(fontWeight: FontWeight.w500)),
        Text('${products.quantity} ${products.unit}',
            style: TextStyle(color: Colors.grey[600], fontSize: 13)),
        SizedBox(height: 4),
        Container(
          width: MediaQuery.of(context).size.width / 2,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text('$apCurrency ${products.price}',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
              Visibility(
                visible: ('${products.price}'=='${products.mrp}')?false:true,
                child: Padding(
                  padding: const EdgeInsets.only(left:8.0),
                  child: Text('$apCurrency ${products.mrp}',
                      style: TextStyle(color: Colors.grey[600],fontWeight: FontWeight.w300, fontSize: 13,decoration: TextDecoration.lineThrough)),
                ),
              ),
              // buildRating(context),
            ],
          ),
        ),
      ],
    ),
  );
}

Container buildRating(BuildContext context) {
  return Container(
    padding: EdgeInsets.only(top: 1.5, bottom: 1.5, left: 4, right: 3),
    //width: 30,
    decoration: BoxDecoration(
      color: Colors.green,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      children: [
        Text(
          "4.2",
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.button.copyWith(fontSize: 10),
        ),
        SizedBox(
          width: 1,
        ),
        Icon(
          Icons.star,
          size: 10,
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
      ],
    ),
  );
}

GestureDetector buildCategoryRow(BuildContext context, TopCategoryDataModel categories, StoreFinderData storeFinderData) {
  return GestureDetector(
    onTap: () {
      Navigator.pushNamed(context, PageRoutes.cat_product, arguments: {
        'title': categories.title,
        'storeid': categories.store_id,
        'cat_id': categories.cat_id,
        'storedetail':storeFinderData,
      });
    },
    behavior: HitTestBehavior.opaque,
    child: Container(
      margin: EdgeInsets.only(left: 16),
      // padding: EdgeInsets.all(10),
      width: 96,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: kWhiteColor,
          // image: DecorationImage(
          //     image: NetworkImage(categories.image), fit: BoxFit.fill)
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(categories.image,fit: BoxFit.cover)
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),// Clip it cleanly.
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 0.5, sigmaY: 0.5),
              child: Container(
                padding: EdgeInsets.only(top: 5,left: 5,right: 5),
                color: Colors.grey.withOpacity(0.3),
                alignment: Alignment.topLeft,
                child: Text(categories.title,style: TextStyle(color: kWhiteColor, fontWeight: FontWeight.w600),),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Column buildCompleteVerticalSHList(BuildContext context) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: EdgeInsets.all(16),
        child: Shimmer(
          duration: Duration(seconds: 3),
          color: Colors.white,
          enabled: true,
          direction: ShimmerDirection.fromLTRB(),
          child: Container(
            height: 15,
            width: 150,
            color: Colors.grey[300],
          ),
        ),
      ),
      buildShList(context),
    ],
  );
}
Container buildShList(context) {
  return Container(
    height: 240,
    child: ListView.builder(
        physics: BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        itemCount: 10,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Container(
              width: MediaQuery.of(context).size.width / 2.5,
              child: buildProductShHCard(context),
            ),
          );
        }),
  );
}
Widget buildProductShHCard(BuildContext context) {
  return Shimmer(
    duration: Duration(seconds: 3),
    color: Colors.white,
    enabled: true,
    direction: ShimmerDirection.fromLTRB(),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            Container(
              alignment: Alignment.center,
              child: SizedBox(
                width: MediaQuery.of(context).size.width / 2.5,
                height: MediaQuery.of(context).size.width / 2.5,
                child: Container(
                  color: Colors.grey[300],
                ),
              ),
            )
          ],
        ),
        SizedBox(height: 4),
        Container(height: 10,color: Colors.grey[300],),
        // Text(type, style: TextStyle(color: Colors.grey[500], fontSize: 10)),
        SizedBox(height: 4),
        Container(
          width: MediaQuery.of(context).size.width / 2,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(height: 10,width: 30,color: Colors.grey[300],),
              Container(height: 10,width: 30,color: Colors.grey[300],),
            ],
          ),
        ),
      ],
    ),
  );
}
