import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:groshop/Locale/locales.dart';
import 'package:groshop/Pages/Search/search_result.dart' as search;
import 'package:groshop/Routes/routes.dart';
import 'package:groshop/Theme/colors.dart';
import 'package:groshop/baseurl/baseurlg.dart';
import 'package:groshop/beanmodel/category/topcategory.dart';
import 'package:groshop/beanmodel/productbean/productwithvarient.dart';
import 'package:groshop/beanmodel/productbean/recentsale.dart';
import 'package:groshop/beanmodel/storefinder/storefinderbean.dart';
import 'package:groshop/beanmodel/whatsnew/whatsnew.dart';
import 'package:groshop/beanmodel/wishlist/wishdata.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchHistory extends StatefulWidget {
  @override
  _SearchHistoryState createState() => _SearchHistoryState();
}

class _SearchHistoryState extends State<SearchHistory> {
  final List<String> _searchList = [];
  List<WhatsNewDataModel> recentSaleList = [];
  List<TopCategoryDataModel> topCategoryList = [];
  List<WishListDataModel> wishModel = [];
  StoreFinderData storeDetails;
  bool enterFirst = false;
  dynamic apCurrency;

  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getSharedValue();
  }

  void getSharedValue() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      apCurrency = pref.getString('app_currency');
    });
  }

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);

    Map<String, dynamic> receivedData = ModalRoute
        .of(context)
        .settings
        .arguments;
    setState(() {
      if (!enterFirst) {
        enterFirst = true;
        topCategoryList = receivedData['category'];
        recentSaleList = receivedData['recentsale'];
        storeDetails = receivedData['storedetails'];
        wishModel = receivedData['wishlist'];
      }
    });
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: TextField(
          controller: searchController,
          onSubmitted: (s) {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => search.SearchResult(wishModel,storeDetails,apCurrency,s)));
            setState(() {
              _searchList.add(s);
            });
          },
          style: Theme
              .of(context)
              .textTheme
              .headline6
              .copyWith(color: Colors.black, fontSize: 18),
          decoration: InputDecoration(
              hintText: '${locale.searchOnGroShop} $appname',
              hintStyle: Theme
                  .of(context)
                  .textTheme
                  .subtitle2,
              suffixIcon: IconButton(
                icon: Icon(
                  Icons.search,
                  color: Colors.grey[400],
                ),
                onPressed: () =>
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => search.SearchResult(wishModel,storeDetails,apCurrency,searchController.text))),
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
      body: ListView(
        physics: BouncingScrollPhysics(),
        children: [
          _searchList.isNotEmpty
              ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 16),
                child: Text(
                  locale.recentlySearched,
                  style: Theme
                      .of(context)
                      .textTheme
                      .headline6
                      .copyWith(color: Colors.black),
                  textAlign: TextAlign.left,
                ),
              ),
              Container(
                height: 144.0,
                child: ListView.builder(
                  itemCount: _searchList.length,
                  itemBuilder: (context, index) {
                    return Row(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: 6.0,
                            horizontal: 16.0,
                          ),
                          child: Icon(Icons.youtube_searched_for,
                              color: Theme
                                  .of(context)
                                  .backgroundColor),
                        ),
                        Text(
                          _searchList[index],
                          style: Theme
                              .of(context)
                              .textTheme
                              .subtitle1
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          )
              : SizedBox.shrink(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12),
            child: Text(
              locale.chooseCategory,
              style: Theme
                  .of(context)
                  .textTheme
                  .headline6
                  .copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                  fontSize: 22),
            ),
          ),
          SizedBox(height: 12),
          Container(
            height: 96,
            child: ListView.builder(
                physics: BouncingScrollPhysics(),
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemCount: topCategoryList.length,
                itemBuilder: (context, index) {
                  return buildCategoryRow(
                      context, topCategoryList[index], storeDetails);
                }),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Text(locale.featuredProducts,
                style: Theme
                    .of(context)
                    .textTheme
                    .subtitle1
                    .copyWith(fontSize: 18)),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: buildGridViewP(recentSaleList, apCurrency, wishModel, storeDetails),
          ),
        ],
      ),
    );
  }
}

GestureDetector buildCategoryRow(BuildContext context,
    TopCategoryDataModel categories, StoreFinderData storeFinderData) {
  return GestureDetector(
    onTap: () {
      Navigator.pushNamed(context, PageRoutes.cat_product, arguments: {
        'title': categories.title,
        'storeid': categories.store_id,
        'cat_id': categories.cat_id,
        'storedetail': storeFinderData,
      });
    },
    behavior: HitTestBehavior.opaque,
    child: Container(
      margin: EdgeInsets.only(left: 16),
      padding: EdgeInsets.all(10),
      width: 96,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: kWhiteColor,
          image: DecorationImage(
              image: NetworkImage(categories.image), fit: BoxFit.fill)),
      child: Text(
        categories.title,
        style: TextStyle(color: kMainTextColor, fontWeight: FontWeight.w600),
      ),
    ),
  );
}
GridView buildGridViewP(List<WhatsNewDataModel> products, apCurrency,
    List<WishListDataModel> wishModel, StoreFinderData storeFinderData,
    {bool favourites = false}) {
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
            context, products[index], apCurrency, wishModel, storeFinderData);
      });
}

Widget buildProductCard(
    BuildContext context,
    WhatsNewDataModel products,
    dynamic apCurrency,
    List<WishListDataModel> wishModel,
    StoreFinderData storeFinderData,
    ) {
  return GestureDetector(
    onTap: () {
      ProductDataModel modelP = ProductDataModel(
          pId: products.productId,
          productImage: products.productImage,
          productName: products.productName,
          tags: products.tags,
          varients: <ProductVarient>[
            ProductVarient(
                varientId: products.varientId,
                description: products.description,
                price: products.price,
                mrp: products.mrp,
                varientImage: products.varientImage,
                unit: products.unit,
                quantity: products.quantity,
                stock: products.stock,
                storeId: products.storeId)
          ]);
      int idd = wishModel.indexOf(WishListDataModel('', '',
          '${products.varientId}', '', '', '', '', '', '', '', '', '', ''));
      Navigator.pushNamed(context, PageRoutes.product, arguments: {
        'pdetails': modelP,
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
            errorWidget: (context, url, error) =>
                Image.asset('assets/icon.png'),
          ),
        ),
        Text(products.productName,
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
