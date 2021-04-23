import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:groshop/Auth/checkout_navigator.dart';
import 'package:groshop/Locale/locales.dart';
import 'package:groshop/Routes/routes.dart';
import 'package:groshop/Theme/colors.dart';
import 'package:groshop/baseurl/baseurlg.dart';
import 'package:groshop/beanmodel/productbean/productwithvarient.dart';
import 'package:groshop/beanmodel/storefinder/storefinderbean.dart';
import 'package:groshop/beanmodel/wishlist/wishdata.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:toast/toast.dart';

class SearchEan extends StatefulWidget {
  SearchEan();

  @override
  _SearchEanState createState() => _SearchEanState();
}

class _SearchEanState extends State<SearchEan> {
  List<ProductDataModel> products = [];
  dynamic title;
  bool enterFirst = false;
  bool isLoading = false;
  List<WishListDataModel> wishModel = [];
  StoreFinderData storedetails;
  dynamic apCurency;

  @override
  void initState() {
    super.initState();
    getWislist();
  }

  void getWislist() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      apCurency = prefs.getString('app_currency');
    });
    dynamic userId = prefs.getInt('user_id');
    dynamic storeId = prefs.getInt('store_id');
    var url = showWishlistUri;
    var http = Client();
    http.post(url, body: {
      'user_id': '${userId}',
      'store_id':'37'
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

  void getCategory(dynamic ean_code, dynamic storeid, BuildContext context) async{
    var http = Client();
    http.post(searchUri,body: {
      'ean_code':'${ean_code}',
      // 'ean_code':'HXBCX',
      'store_id':'${storeid}'
    }).then((value){
      print('${value.body}');
      if(value.statusCode == 200){
        ProductModel data1 = ProductModel.fromJson(jsonDecode(value.body));
        if(data1.status=="1" || data1.status==1){
          setState(() {
            products.clear();
            products = List.from(data1.data);
          });
        }
        Toast.show(data1.message, context,gravity: Toast.CENTER,duration: Toast.LENGTH_SHORT);
      }
      setState(() {
        isLoading = false;
      });
    }).catchError((e){
      Toast.show('Something went wrong\nPlease check your internet connection.', context,gravity: Toast.CENTER,duration: Toast.LENGTH_SHORT);
      print(e);
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);
    Map<String,dynamic> receivedData = ModalRoute.of(context).settings.arguments;
    setState(() {
      // title = receivedData['title'];
      if(!enterFirst){
        enterFirst = true;
        isLoading = true;
        storedetails = receivedData['storedetails'];
        getCategory(receivedData['ean_code'], storedetails.store_id, context);
      }
    });
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Scan Product',
          style: TextStyle(color: kMainTextColor),
        ),
        centerTitle: true,
        actions: [
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
        ],
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.all(5.0),
        child: SingleChildScrollView(
          primary: true,
          child: (isLoading)?buildGridShView():buildGridView(products,wishModel,storedetails,apCurency),
        ),
      ),
    );
  }
}

GridView buildGridView(List<ProductDataModel> listName, List<WishListDataModel> wishModel,StoreFinderData storedetails,dynamic apCurency,{bool favourites = false}) {
  return GridView.builder(
      padding: EdgeInsets.symmetric(vertical: 10),
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      primary: false,
      itemCount: listName.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.80,
        crossAxisSpacing: 16,
      ),
      itemBuilder: (context, index) {
        return buildProductCard(
            context,listName[index],
            wishModel,
            storedetails,
            apCurency,
            favourites: favourites);
      });
}

Widget buildProductCard(
    BuildContext context,ProductDataModel products,List<WishListDataModel> wishModel,StoreFinderData finderDetails,dynamic apCurency,
    {bool favourites = false}) {
  return GestureDetector(
    onTap: () {
      int idd = wishModel.indexOf(WishListDataModel('', '', '${products.varients[0].varientId}', '', '', '', '', '', '', '', '', '', ''));
      Navigator.pushNamed(context, PageRoutes.product,arguments: {
        'pdetails':products,
        'storedetails':finderDetails,
        'isInWish': (idd>=0),
      });
    },
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            Container(
              alignment: Alignment.center,
              child: Image.network(
                '${products.productImage}',
                width: MediaQuery.of(context).size.width / 2.5,
                height: MediaQuery.of(context).size.width / 2.5,
                fit: BoxFit.fill,
              ),
            ),
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
        Text('${products.productName}', style: TextStyle(fontWeight: FontWeight.w500)),
        Text('${products.varients[0].quantity} ${products.varients[0].unit}', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
        SizedBox(height: 4),
        Container(
          width: MediaQuery.of(context).size.width / 2,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text('$apCurency ${products.varients[0].price}',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
              Visibility(
                visible: ('${products.varients[0].price}'=='${products.varients[0].mrp}')?false:true,
                child: Padding(
                  padding: const EdgeInsets.only(left:8.0),
                  child: Text('$apCurency ${products.varients[0].mrp}',
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

GridView buildGridShView() {
  return GridView.builder(
      padding: EdgeInsets.symmetric(vertical: 10),
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      primary: false,
      itemCount: 10,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.80,
        crossAxisSpacing: 16,
      ),
      itemBuilder: (context, index) {
        return buildProductShCard(
            context);
      });
}

Widget buildProductShCard(BuildContext context) {
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
