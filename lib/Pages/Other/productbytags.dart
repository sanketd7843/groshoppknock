import 'dart:convert';

import 'package:flutter/cupertino.dart';
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

class TagsProduct extends StatefulWidget {

  @override
  _TagsProductState createState() => _TagsProductState();
}

class _TagsProductState extends State<TagsProduct> {
  List<ProductDataModel> products = [];
  dynamic title;
  dynamic store_id;
  bool enterFirst = false;
  bool isLoading = false;
  StoreFinderData storedetail;
  List<WishListDataModel> wishModel = [];
  dynamic apCurrency;
  @override
  void initState() {
    super.initState();
    getSharedValue();
  }

  void getSharedValue() async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      apCurrency = pref.getString('app_currency');
    });
  }

  void getWislist(dynamic storeid) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    dynamic userId = prefs.getInt('user_id');
    var url = showWishlistUri;
    var http = Client();
    http.post(url, body: {
      'user_id': '${userId}',
      'store_id':'${storeid}'
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

  void getCategory(dynamic title, dynamic storeid) async{
    var http = Client();
    http.post(tagProductUri,body: {
      'tag_name':'${title}',
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
      }
      setState(() {
        isLoading = false;
      });
    }).catchError((e){
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
      if(!enterFirst){
        enterFirst = true;
        isLoading = true;
        storedetail = receivedData['storedetail'];
        store_id = storedetail.store_id;
        title = receivedData['tagname'];
        getWislist(store_id);
        getCategory(title, store_id);
      }
    });
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
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
          child: (isLoading)?buildGridShView():buildGridView(products,wishModel,'$apCurrency',storedetail),
        ),
      ),
    );
  }
}

GridView buildGridView(List<ProductDataModel> listName, List<WishListDataModel> wishModel,String apCurrency,StoreFinderData storedetail,{bool favourites = false}) {
  return GridView.builder(
      padding: EdgeInsets.symmetric(vertical: 10),
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      primary: false,
      itemCount: listName.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.72,
          crossAxisSpacing: 16,
          mainAxisSpacing: 5
      ),
      itemBuilder: (context, index) {
        return buildProductCard(
            context,
            listName[index],
            wishModel,
            '$apCurrency',
            storedetail,
            favourites: favourites);
      });
}

Widget buildProductCard(
    BuildContext context,ProductDataModel product,
    List<WishListDataModel> wishModel,String apCurrency,StoreFinderData storedetail,
    {bool favourites = false}) {
  return GestureDetector(
    onTap: () {
      int idd = wishModel.indexOf(WishListDataModel('', '', '${product.varientId}', '', '', '', '', '', '', '', '', '', ''));
      Navigator.pushNamed(context, PageRoutes.product,arguments: {
        'pdetails':product,
        'storedetails':storedetail,
        'isInWish': (idd>=0),
      });
    },
    child: Container(
      padding: EdgeInsets.all(5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                alignment: Alignment.center,
                width: MediaQuery.of(context).size.width / 2.5,
                height: MediaQuery.of(context).size.width / 2.5,
                child: Image.network(
                  '${product.productImage}',
                  width: MediaQuery.of(context).size.width / 2.5-20,
                  height: 90,
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
          Text('${product.productName}', maxLines: 2,style: TextStyle(fontWeight: FontWeight.w500)),
          Text('${product.varients[0].quantity} ${product.varients[0].unit}', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          SizedBox(height: 4),
          Container(
            width: MediaQuery.of(context).size.width / 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text('$apCurrency ${product.varients[0].price}',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                Visibility(
                  visible: ('${product.varients[0].price}'=='${product.varients[0].mrp}')?false:true,
                  child: Padding(
                    padding: const EdgeInsets.only(left:8.0),
                    child: Text('$apCurrency ${product.varients[0].mrp}',
                        style: TextStyle(color: Colors.grey[600],fontWeight: FontWeight.w300, fontSize: 13,decoration: TextDecoration.lineThrough)),
                  ),
                ),
                // buildRating(context),
              ],
            ),
          ),
        ],
      ),
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
