import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:groshop/Auth/checkout_navigator.dart';
import 'package:groshop/Locale/locales.dart';
import 'package:groshop/Routes/routes.dart';
import 'package:groshop/baseurl/baseurlg.dart';
import 'package:groshop/beanmodel/productbean/productwithvarient.dart';
import 'package:groshop/beanmodel/productbean/recentsale.dart';
import 'package:groshop/beanmodel/storefinder/storefinderbean.dart';
import 'package:groshop/beanmodel/whatsnew/whatsnew.dart';
import 'package:groshop/beanmodel/wishlist/wishdata.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';


class SellerInfo extends StatefulWidget {
  final StoreFinderData storedetails;
  final List<WishListDataModel> wishModel;
  SellerInfo(this.storedetails,this.wishModel);

  @override
  _SellerInfoState createState() => _SellerInfoState();
}

class _SellerInfoState extends State<SellerInfo> {
  List<WhatsNewDataModel> sellerProducts = [];
  List<WishListDataModel> wishModel = [];
  StoreFinderData storedetails;
  dynamic apCurrency;

  @override
  void initState() {
    super.initState();
    wishModel = widget.wishModel;
    storedetails = widget.storedetails;
    getTopSellingList(widget.storedetails.store_id);
  }

  void getTopSellingList(dynamic storeid) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      apCurrency = prefs.getString('app_currency');
    });
    var http = Client();
    http.post(topSellingUri, body: {'store_id': '${storeid}'}).then((value) {
      if (value.statusCode == 200) {
        WhatsNewModel data1 =
            WhatsNewModel.fromJson(jsonDecode(value.body));
        if (data1.status == "1" || data1.status == 1) {
          setState(() {
            sellerProducts.clear();
            sellerProducts = List.from(data1.data);
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
    return Scaffold(
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  height: 300,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    image: new DecorationImage(
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                          Colors.black.withOpacity(0.75), BlendMode.dstATop),
                      image: AssetImage('assets/seller1.png'),
                    ),
                  ),
                ),
                Positioned.directional(
                  textDirection: Directionality.of(context),
                  top: 50,
                  start: 10,
                  child: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(
                      Icons.arrow_back_ios,
                      size: 24,
                      color: Theme.of(context).scaffoldBackgroundColor,
                    ),
                  ),
                ),
                Positioned.directional(
                  textDirection: Directionality.of(context),
                  top: 40,
                  end: 10,
                  child: IconButton(
                      onPressed: () async{
                        SharedPreferences prefs = await SharedPreferences.getInstance();
                        if(prefs.containsKey('islogin') && prefs.getBool('islogin')){
                          Navigator.pushNamed(context,PageRoutes.cartPage);
                        }else{
                          Toast.show(locale.loginfirst, context,gravity: Toast.CENTER,duration: Toast.LENGTH_SHORT);
                        }
                      },
                      icon: ImageIcon(AssetImage('assets/ic_cart.png'),
                          color: Colors.white)),
                ),
                Positioned.directional(
                  bottom: 20,
                  start: 20,
                  textDirection: TextDirection.ltr,
                  child: Text('${widget.storedetails.store_name}',
                      style: Theme.of(context).textTheme.bodyText1.copyWith(
                          fontSize: 24,
                          letterSpacing: 0.5,
                          fontWeight: FontWeight.w500)),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: buildGridViewP(sellerProducts,apCurrency,wishModel,storedetails),
            ),
          ],
        ),
      ),
    );
  }
}

GridView buildGridViewP(List<WhatsNewDataModel> products, apCurrency, List<WishListDataModel> wishModel,StoreFinderData storeFinderData,{bool favourites = false}) {
  return GridView.builder(
      padding: EdgeInsets.symmetric(vertical: 20),
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: products.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
      ),
      itemBuilder: (context, index) {
        return buildProductCard(
            context,products[index],apCurrency,wishModel,storeFinderData);
      });
}

Widget buildProductCard(BuildContext context,WhatsNewDataModel products, dynamic apCurrency,List<WishListDataModel> wishModel,StoreFinderData storeFinderData,) {
  return GestureDetector(
    onTap: () {
      ProductDataModel modelP = ProductDataModel(pId: products.productId,productImage: products.productImage,productName: products.productName,tags: products.tags,varients: <ProductVarient>[
        ProductVarient(varientId: products.varientId,description: products.description,price: products.price,mrp: products.mrp,varientImage: products.varientImage,unit: products.unit,quantity: products.quantity,stock: products.stock,storeId: products.storeId)
      ]);
      int idd = wishModel.indexOf(WishListDataModel('', '', '${products.varientId}', '', '', '', '', '', '', '', '', '', ''));
      Navigator.pushNamed(context, PageRoutes.product,arguments: {
        'pdetails':modelP,
        'storedetails':storeFinderData,
        'isInWish': (idd>=0),
      });
    },
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
