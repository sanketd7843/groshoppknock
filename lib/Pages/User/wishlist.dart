import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:groshop/Auth/checkout_navigator.dart';
import 'package:groshop/Components/custom_button.dart';
import 'package:groshop/Components/drawer.dart';
import 'package:groshop/Locale/locales.dart';
import 'package:groshop/Routes/routes.dart';
import 'package:groshop/Theme/colors.dart';
import 'package:groshop/baseurl/baseurlg.dart';
import 'package:groshop/beanmodel/cart/addtocartbean.dart';
import 'package:groshop/beanmodel/productbean/productwithvarient.dart';
import 'package:groshop/beanmodel/storefinder/storefinderbean.dart';
import 'package:groshop/beanmodel/wishlist/wishdata.dart';
import 'package:groshop/main.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:toast/toast.dart';

class MyWishList extends StatefulWidget {
  @override
  _MyWishListState createState() => _MyWishListState();
}

class _MyWishListState extends State<MyWishList> {
  var userName;
  bool islogin = false;
  List<WishListDataModel> wishModel = [];
  StoreFinderData _storeFinderData;
  bool isLoading = false;
  dynamic apCurrency;
  var http = Client();

  @override
  void initState() {
    super.initState();
    getSharedValue();
  }
  getSharedValue() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isLoading = true;
      islogin = prefs.getBool('islogin');
      userName = prefs.getString('user_name');
      apCurrency = prefs.getString('app_currency');
    });
    int st = -1;
    if(prefs.containsKey('store_id_last')){
      st = int.parse('${prefs.getString('store_id_last')}');
      if(prefs.containsKey('storelist')){
        var storeListpf = jsonDecode(prefs.getString('storelist')) as List;
        List<StoreFinderData> dataFinderL = [];
        dataFinderL = List.from(storeListpf.map((e) => StoreFinderData.fromJson(e)).toList());
        int idd1 = dataFinderL.indexOf(StoreFinderData('', st, '', '', '', ''));
        if(idd1>=0){
          _storeFinderData = dataFinderL[idd1];
        }
      }
      getWislist(st);
    }else{
      getWislist('');
    }
  }

  void getWislist(dynamic storeId) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    dynamic userId = prefs.getInt('user_id');
    var url = showWishlistUri;
    await http.post(url, body: {
      'user_id': '${userId}',
      'store_id':'$storeId'
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
      setState(() {
        isLoading = false;
      });
    }).catchError((e){
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  void dispose() {
    http.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          locale.myWishList.toUpperCase(),
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
      drawer: buildDrawer(context, '$userName',islogin,onHit: () {
        SharedPreferences.getInstance().then((pref){
          pref.clear().then((value) {
            Navigator.pushAndRemoveUntil(context,
                MaterialPageRoute(builder: (context) {
                  return GroceryLogin();
                }), (Route<dynamic> route) => false);
          });
        });
      }),
      body: Column(
        children: [
          Expanded(child: Padding(
            padding: const EdgeInsets.all(20),
            child: (isLoading)?buildGridShView():(wishModel!=null && wishModel.length>0)?buildGridView(wishModel,apCurrency,_storeFinderData):Container(
              alignment: Alignment.center,
              child: Text(locale.noprodwishlist),
            ),
          ),),
          Visibility(
            visible: ((_storeFinderData!=null && _storeFinderData.store_id!=null) && (wishModel!=null && wishModel.length>0)),
            child: CustomButton(onTap: () {
              if (!isLoading) {
                setState(() {
                  isLoading = true;
                });
               hitWishToCart();

              }
            },
              label: locale.continueText,
            ),
          )
        ],
      ),
    );
  }

  void hitWishToCart() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    http.post(wishlistToCartUri,body: {
      'user_id':'${prefs.getInt('user_id')}',
      'store_id':'${_storeFinderData.store_id}',
    }).then((value){
print('waddct -  ${value.body}');
if (value.statusCode == 200) {
  AddToCartMainModel data1 =
  AddToCartMainModel.fromJson(jsonDecode(value.body));
  Toast.show(data1.message, context,gravity: Toast.CENTER,duration: Toast.LENGTH_SHORT);
}
getWislist(_storeFinderData.store_id);
// setState(() {
//   isLoading = false;
// });
    }).catchError((e){
      setState(() {
        isLoading = false;
      });
    });
  }
}

GridView buildGridView(List<WishListDataModel> wishModel, String apCurrency, StoreFinderData finderData) {
  return GridView.builder(
      padding: EdgeInsets.symmetric(vertical: 20),
      // physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: wishModel.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
      ),
      itemBuilder: (context, index) {
        return buildProductCard(
            context,
            wishModel[index],
            '$apCurrency',finderData);
      });
}

Widget buildProductCard(
    BuildContext context,WishListDataModel products,String apCurrency,StoreFinderData finderData) {
  return GestureDetector(
    onTap: () {
      if(finderData!=null){
        ProductDataModel modelP = ProductDataModel(
            pId: products.varient_id,
            productImage: products.varient_image,
            productName: products.product_name,
            tags: [],
            varients: <ProductVarient>[
              ProductVarient(
                  varientId: products.varient_id,
                  description: products.description,
                  price: products.price,
                  mrp: products.mrp,
                  varientImage: products.varient_image,
                  unit: products.unit,
                  quantity: products.quantity,
                  stock: 1,
                  storeId: products.store_id)
            ]);
        Navigator.pushNamed(context, PageRoutes.product, arguments: {
          'pdetails': modelP,
          'storedetails': finderData,
          'isInWish': true,
        });
      }else{

      }
    },
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: MediaQuery.of(context).size.width / 2.5,
          height: MediaQuery.of(context).size.width / 2.5,
          child: CachedNetworkImage(
            imageUrl: '${products.varient_image}',
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
            errorWidget: (context, url, error) =>
                Image.asset('assets/icon.png'),
          ),
        ),
        Text(products.product_name,maxLines: 1,
            style: TextStyle(fontWeight: FontWeight.w500)),
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
                visible:
                ('${products.price}' == '${products.mrp}') ? false : true,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text('$apCurrency ${products.mrp}',
                      style: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w300,
                          fontSize: 13,
                          decoration: TextDecoration.lineThrough)),
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
      // physics: NeverScrollableScrollPhysics(),
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
