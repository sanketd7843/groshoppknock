import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:groshop/Locale/locales.dart';
import 'package:groshop/Routes/routes.dart';
import 'package:groshop/baseurl/baseurlg.dart';
import 'package:groshop/beanmodel/productbean/productwithvarient.dart';
import 'package:groshop/beanmodel/productbean/recentsale.dart';
import 'package:groshop/beanmodel/searchmodel/searchkeyword.dart';
import 'package:groshop/beanmodel/storefinder/storefinderbean.dart';
import 'package:groshop/beanmodel/wishlist/wishdata.dart';
import 'package:http/http.dart';


class SearchResult extends StatefulWidget {

  final List<WishListDataModel> wishModel;
  final StoreFinderData storeDetails;
  final dynamic apCurrency;
  final String searchString;

  const SearchResult(this.wishModel, this.storeDetails, this.apCurrency, this.searchString);



  @override
  _SearchResultState createState() => _SearchResultState();
}

class _SearchResultState extends State<SearchResult> {
TextEditingController searchController = TextEditingController();
  List<ProductDataModel> products = [];
  List<WishListDataModel> wishModel = [];
  StoreFinderData storeDetails;

  @override
  void initState() {
    wishModel.clear();
    wishModel = List.from(widget.wishModel);
    storeDetails = widget.storeDetails;
    searchController.text = widget.searchString;
    super.initState();
    getSearchList(searchController.text);
  }

  void getSearchList(dynamic searchword) async{
    var http = Client();
    http.post(searchByStoreUri,body: {
      'keyword':'$searchword',
      'store_id':'${storeDetails.store_id}'
    }).then((value){
      if(value.statusCode == 200){
        ProductModel pData = ProductModel.fromJson(jsonDecode(value.body));
        if('${pData.status}'=='1'){
          setState(() {
            products.clear();
            products = List.from(pData.data);
          });
        }
      }
    }).catchError((e){

    });
  }

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: TextFormField(
          controller: searchController,
          style: Theme.of(context)
              .textTheme
              .headline6
              .copyWith(color: Colors.black, fontSize: 18),
          onFieldSubmitted: (value){
getSearchList(value);
          },
          decoration: InputDecoration(
              suffixIcon: Icon(
                Icons.search,
                color: Colors.grey[400],
              ),
              prefixIcon: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: Colors.grey[400],
                ),
              ),
              contentPadding: EdgeInsets.symmetric(vertical: 10),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(width: 1))),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12),
        child: ListView(
          physics: BouncingScrollPhysics(),
          children: [
            Text(
              (products!=null && products.length>0)?'${products.length} ' + locale.resultsFound:'',
              style: Theme.of(context)
                  .textTheme
                  .headline6
                  .copyWith(color: Colors.grey[400], fontSize: 16),
            ),
            SizedBox(
              height: 16,
            ),
            buildGridViewP(context,products,widget.apCurrency,wishModel,storeDetails),
          ],
        ),
      ),
    );
  }
}

GridView buildGridViewP(BuildContext context,List<ProductDataModel> products, apCurrency,
    List<WishListDataModel> wishModel, StoreFinderData storeDetails,
    {bool favourites = false}) {
  return GridView.builder(
      padding: EdgeInsets.symmetric(vertical: 20),
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: products.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.72,
        crossAxisSpacing: 16,
      ),
      itemBuilder: (context, index) {
        return buildProductCard(
            context, products[index], wishModel, apCurrency,storeDetails);
      });
}

Widget buildProductCard(
    BuildContext context,
    ProductDataModel products,
    dynamic apCurrency,
    List<WishListDataModel> wishModel,
    StoreFinderData storeFinderData,
    ) {
  return GestureDetector(
    onTap: () {
      int idd = wishModel.indexOf(WishListDataModel('', '',
          '${products.varientId}', '', '', '', '', '', '', '', '', '', ''));
      Navigator.pushNamed(context, PageRoutes.product, arguments: {
        'pdetails': products,
        'storedetails': storeFinderData,
        'isInWish': (idd >= 0),
      });
    },
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: MediaQuery.of(context).size.width / 2.5,
          height: MediaQuery.of(context).size.width / 2.5,
          child: CachedNetworkImage(
            imageUrl: '${products.varients[0].varientImage}',
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
        Text(products.productName,
            style: TextStyle(fontWeight: FontWeight.w500)),
        Text('${products.varients[0].quantity} ${products.varients[0].unit}',
            style: TextStyle(color: Colors.grey[600], fontSize: 13)),
        SizedBox(height: 4),
        Container(
          width: MediaQuery.of(context).size.width / 2,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text('$apCurrency ${products.varients[0].price}',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
              Visibility(
                visible:
                ('${products.varients[0].price}' == '${products.varients[0].mrp}') ? false : true,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text('$apCurrency ${products.varients[0].mrp}',
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
