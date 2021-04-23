import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:groshop/Auth/checkout_navigator.dart';
import 'package:groshop/Components/constantfile.dart';
import 'package:groshop/Components/custom_button.dart';
import 'package:groshop/Locale/locales.dart';
import 'package:groshop/Pages/Other/reviews.dart';
import 'package:groshop/Pages/Other/seller_info.dart';
import 'package:groshop/Routes/routes.dart';
import 'package:groshop/Theme/colors.dart';
import 'package:groshop/baseurl/baseurlg.dart';
import 'package:groshop/beanmodel/cart/addtocartbean.dart';
import 'package:groshop/beanmodel/cart/cartitembean.dart';
import 'package:groshop/beanmodel/productbean/productwithvarient.dart';
import 'package:groshop/beanmodel/ratting/rattingbean.dart';
import 'package:groshop/beanmodel/storefinder/storefinderbean.dart';
import 'package:groshop/beanmodel/whatsnew/whatsnew.dart';
import 'package:groshop/beanmodel/wishlist/addorremovewish.dart';
import 'package:groshop/beanmodel/wishlist/wishdata.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

class ProductInfo extends StatefulWidget {
  // ProductInfo(this.image, this.name, this.productid, this.price, this.varientid, this.storeid);

  @override
  _ProductInfoState createState() => _ProductInfoState();
}

class _ProductInfoState extends State<ProductInfo> {
  ProductDataModel productDetails;
  var http = Client();
  List<ProductVarient> varaintList = [];
  List<Tags> tagsList = [];
  List<WhatsNewDataModel> sellerProducts = [];
  List<WishListDataModel> wishModel = [];
  List<CartItemData> cartItemd = [];
  StoreFinderData storedetails;
  bool progressadd = false;
  bool isWishList = false;
  String image;
  String name;
  String productid;
  String price;
  String varientid;
  String storeid;
  String desp;
  bool enterFirst = false;
  bool inCart = false;
  dynamic apCurrency;

  int ratingvalue = 0;
  double avrageRating = 0.0;
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    getCartList();
  }

  void getRatingValue(dynamic store_id, dynamic varient_id) async {
    http.post(getProductRatingUri,body: {
      'store_id':'$store_id',
      'varient_id':'$varient_id'
    }).then((value) {
      if (value.statusCode == 200) {
        ProductRating data1 = ProductRating.fromJson(jsonDecode(value.body));
        if (data1.status == "1" || data1.status == 1) {
          setState(() {
            List<ProductRatingData> dataL = List.from(data1.data);
            ratingvalue = dataL.length;
            if(ratingvalue>0){
              double rateV = 0.0;
              for(int i=0;i<dataL.length;i++){
                rateV = rateV+double.parse('${dataL[i].rating}');
                if(dataL.length == i+1){
                  avrageRating = rateV/dataL.length;
                }
              }
            }else{
              avrageRating = 5.0;
            }
          });
        }
      }
    }).catchError((e) {
      print(e);
    });
  }

  void getWislist(dynamic storeid) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    dynamic userId = prefs.getInt('user_id');
    var url = showWishlistUri;
    var http = Client();
    http.post(url,
        body: {'user_id': '${userId}', 'store_id': '${storeid}'}).then((value) {
      print('resp - ${value.body}');
      if (value.statusCode == 200) {
        WishListModel data1 = WishListModel.fromJson(jsonDecode(value.body));
        if (data1.status == "1" || data1.status == 1) {
          setState(() {
            wishModel.clear();
            wishModel = List.from(data1.data);
          });
        }
      }
    }).catchError((e) {});
  }

  void getCartList() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      progressadd = true;
      apCurrency = preferences.getString('app_currency');
    });
    var http = Client();
    http.post(showCartUri,
        body: {'user_id': '${preferences.getInt('user_id')}'}).then((value) {
      print('cart - ${value.body}');
      if (value.statusCode == 200) {
        CartItemMainBean data1 =
            CartItemMainBean.fromJson(jsonDecode(value.body));
        if (data1.status == "1" || data1.status == 1) {
          setState(() {
            cartItemd.clear();
            cartItemd = List.from(data1.data);
            if (varientid != null) {
              int ind1 = cartItemd.indexOf(CartItemData('', '', '', '', '',
                  '$varientid', '', '', '', '', '', '', '', ''));
              if (ind1 >= 0) {
                inCart = true;
              } else {
                inCart = false;
              }
            }
          });
        } else {
          setState(() {
            cartItemd.clear();
            if (data1.data.length > 0) {
              cartItemd = List.from(data1.data);
              if (varientid != null) {
                int ind1 = cartItemd.indexOf(CartItemData('', '', '', '', '',
                    '$varientid', '', '', '', '', '', '', '', ''));
                if (ind1 >= 0) {
                  inCart = true;
                } else {
                  inCart = false;
                }
              }
            } else {
              inCart = false;
            }
          });
        }
      }
      setState(() {
        progressadd = false;
      });
    }).catchError((e) {
      setState(() {
        progressadd = false;
      });
      print(e);
    });
  }

  void getTopSellingList(dynamic storeid) async {
    // SharedPreferences preferences = await SharedPreferences.getInstance();
    var http = Client();
    http.post(topSellingUri, body: {'store_id': '${storeid}'}).then((value) {
      if (value.statusCode == 200) {
        WhatsNewModel data1 = WhatsNewModel.fromJson(jsonDecode(value.body));
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

  void addOrRemove(
      dynamic storeid, dynamic varientId, BuildContext context) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    dynamic userid = preferences.getInt('user_id');
    print('${storeid} ${userid} ${varientId}');
    var http = Client();
    http.post(addRemWishlistUri, body: {
      'store_id': '${storeid}',
      'user_id': '${userid}',
      'varient_id': '${varientId}',
    }).then((value) {
      print('resd ${value.body}');
      if (value.statusCode == 200) {
        AddRemoveWishList data1 =
            AddRemoveWishList.fromJson(jsonDecode(value.body));
        if (data1.status == "1" || data1.status == 1) {
          setState(() {
            isWishList = true;
          });
        } else if (data1.status == "2" || data1.status == 2) {
          setState(() {
            isWishList = false;
          });
        }
        Toast.show(data1.message, context,
            duration: Toast.LENGTH_SHORT, gravity: Toast.CENTER);
      }
    }).catchError((e) {
      print(e);
    });
  }

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);
    Map<String, dynamic> receivedData =
        ModalRoute.of(context).settings.arguments;
    setState(() {
      if (!enterFirst) {
        enterFirst = true;
        productDetails = receivedData['pdetails'];
        storedetails = receivedData['storedetails'];
        image = productDetails.productImage;
        name = productDetails.productName;
        productid = '${productDetails.productId}';
        price = '${productDetails.varients[0].price}';
        varientid = '${productDetails.varients[0].varientId}';
        desp = productDetails.varients[0].description;
        storeid = '${storedetails.store_id}';
        if(cartItemd!=null && cartItemd.length>0){
          int ind1 = cartItemd.indexOf(CartItemData(
              '', '', '', '', '', '$varientid', '', '', '', '', '', '', '', ''));
          if (ind1 >= 0) {
            setState(() {
              inCart = true;
            });
          }
        }
        isWishList = receivedData['isInWish'];
        varaintList.clear();
        varaintList = List.from(productDetails.varients);
        tagsList.clear();
        tagsList = List.from(productDetails.tags);
        selectedIndex = 0;
        print('${receivedData['isInWish']}');
        print('${isWishList}');
        getRatingValue(storeid, varientid);
        getTopSellingList(storeid);
        getWislist(storeid);
      }
    });

    return Scaffold(
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: 250,
              child: Stack(
                children: [
                  //Container(),
                  Positioned.fill(
                      child: Image.network(image, fit: BoxFit.fill)),
                  Positioned.directional(
                      textDirection: Directionality.of(context),
                      top: 40,
                      start: 5,
                      child: IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Icon(Icons.arrow_back_ios))),
                  Positioned.directional(
                      textDirection: Directionality.of(context),
                      top: 40,
                      end: 5,
                      child: IconButton(
                          onPressed: () async {
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            if (prefs.containsKey('islogin') &&
                                prefs.getBool('islogin')) {

                              Navigator.pushNamed(context, PageRoutes.cartPage).then((value) {
                                print('value d');
                                getCartList();
                              }).catchError((e) {
                                print('dd');
                                getCartList();
                              });
                              // Navigator.pushNamed(context, PageRoutes.cart)

                            } else {
                              Toast.show(locale.loginfirst, context,
                                  gravity: Toast.CENTER,
                                  duration: Toast.LENGTH_SHORT);
                            }
                          },
                          icon: ImageIcon(AssetImage('assets/ic_cart.png')))),
                  Positioned.directional(
                      textDirection: Directionality.of(context),
                      bottom: 10,
                      end: 5,
                      child: IconButton(
                        onPressed: () async {
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          if (prefs.containsKey('islogin') &&
                              prefs.getBool('islogin')) {
                            addOrRemove(storeid, varientid, context);
                          } else {
                            Toast.show(locale.loginfirst, context,
                                gravity: Toast.CENTER,
                                duration: Toast.LENGTH_SHORT);
                          }
                        },
                        icon: Icon(isWishList
                            ? Icons.favorite
                            : Icons.favorite_border),
                        color: kMainColor,
                      )),
                ],
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: Theme.of(context).textTheme.headline3.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 20),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${storedetails.store_name}',
                        style: Theme.of(context).textTheme.headline6.copyWith(
                            color: Colors.grey[600],
                            fontSize: 14,
                            fontWeight: FontWeight.w400),
                      ),
                      Spacer(),
                      //SizedBox(width: 180,),
                      buildRating(context,avrageRating: avrageRating),
                    ],
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Row(
                    children: [
                      Text("$apCurrency ${price}",
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 20)),
                      Spacer(),
                      FlatButton(
                          onPressed: () {
                            Navigator.pushNamed(
                                context, PageRoutes.reviewsall,arguments: {
                                  'store_id':'$storeid',
                                  'v_id':'$varientid',
                                  'title':'$name'
                            }).then((value){
                              getRatingValue(storeid, varientid);
                            });
                            // name,varientid
                          },
                          child: Text(
                            '${locale.readAllReviews1} $ratingvalue ${locale.readAllReviews2}',
                            style: TextStyle(
                                color: Color(
                                  0xffa9a9a9,
                                ),
                                fontSize: 13),
                          )),
                      Icon(Icons.arrow_forward_ios,
                          size: 10, color: Color(0xffa9a9a9)),
                    ],
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  Visibility(
                    visible: (desp != null && '$desp'.toUpperCase() != 'NULL'),
                    child: Text(
                      '${desp}',
                      softWrap: true,
                      style: TextStyle(
                        color: Color(0xff585858),
                        fontSize: 15,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  Visibility(
                    visible: (varaintList != null && varaintList.length > 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(locale.varient,style: TextStyle(
                            color: Theme.of(context).backgroundColor,
                            fontSize: 18),),
                        SizedBox(height: 10,),
                        Container(
                          height:50,
                          child: ListView.builder(
                              itemCount: varaintList.length,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () {
                                    setState(() {
                                      selectedIndex = index;
                                      price = '${varaintList[selectedIndex].price}';
                                      // mrp = '${varaintList[selectedIndex].mrp}';
                                      desp =
                                      '${varaintList[selectedIndex].description}';
                                      varientid = productDetails
                                          .varients[selectedIndex].varientId;
                                    });
                                  },
                                  child: Container(
                                    margin: EdgeInsets.symmetric(horizontal: 10),
                                    padding: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      border: Border.all(
                                          color: (selectedIndex == index)
                                              ? kMainColor
                                              : kWhiteColor,
                                          width: (selectedIndex == index) ? 2 : 1),
                                      color: (selectedIndex == index)
                                          ? Colors.grey[300]
                                          : kWhiteColor,
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                            '${varaintList[index].quantity}\t${varaintList[index].unit}')
                                      ],
                                    ),
                                  ),
                                );
                              }),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            (!progressadd)
                ? CustomButton(
                    onTap: () async {
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      if (!inCart) {
                        setState(() {
                          progressadd = true;
                        });
                        if (prefs.containsKey('islogin') &&
                            prefs.getBool('islogin')) {
                          addtocart(storeid, varientid, 1, '0');
                        } else {
                          setState(() {
                            progressadd = false;
                          });
                          Toast.show(locale.loginfirst, context,
                              gravity: Toast.CENTER,
                              duration: Toast.LENGTH_SHORT);
                        }
                      } else {
                        if (prefs.containsKey('islogin') &&
                            prefs.getBool('islogin')) {
                          Navigator.pushNamed(context,PageRoutes.cartPage).then((value) {
                            print('value d');
                            getCartList();
                          }).catchError((e) {
                            print('dd');
                            getCartList();
                          });
                        } else {
                          Toast.show(locale.loginfirst, context,
                              gravity: Toast.CENTER,
                              duration: Toast.LENGTH_SHORT);
                        }
                      }
                    },
                    height: 60,
                    iconGap: 12,
                    prefixIcon: ImageIcon(
                      AssetImage('assets/ic_cart.png'),
                      color: Colors.white,
                      size: 16,
                    ),
                    label: (inCart) ? locale.goToCart : locale.addToCart,
                    // label: locale.goToCart,
                  )
                : Container(
                    height: 52,
                    alignment: Alignment.center,
                    child: SizedBox(
                        width: 30,
                        height: 30,
                        child: CircularProgressIndicator()),
                  ),
            SizedBox(
              height: 10,
            ),
            Visibility(
              visible: (tagsList != null && tagsList.length > 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 5),
                    child: Text(locale.tags,style: TextStyle(
                    color: Theme.of(context).backgroundColor,
                fontSize: 18),),
                  ),
                  SizedBox(height: 10,),
                  Container(
                    height: 40,
                    child: ListView.builder(
                        itemCount: tagsList.length,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              Navigator.pushNamed(context, PageRoutes.tagproduct,
                                  arguments: {
                                    'storedetail': storedetails,
                                    'tagname': tagsList[index].tag
                                  }).then((value) {
                                print('value d');
                                getCartList();
                              }).catchError((e) {
                                print('dd');
                                getCartList();
                              });
                            },
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: 10),
                              padding: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(color: kMainColor, width: 1),
                                color: kWhiteColor,
                              ),
                              child: Row(
                                children: [
                                  Text('${productDetails.tags[index].tag}')
                                ],
                              ),
                            ),
                          );
                        }),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            ListTile(
              title: GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              SellerInfo(storedetails, wishModel)));
                },
                child: RichText(
                  text: TextSpan(
                      text: locale.moreBy + ' ',
                      style: TextStyle(
                          color: Theme.of(context).backgroundColor,
                          fontSize: 18),
                      children: <TextSpan>[
                        TextSpan(
                            text: locale.seller,
                            style: TextStyle(fontWeight: FontWeight.w500)),
                      ]),
                ),
              ),
              trailing: FlatButton(
                  onPressed: () {
                    // Navigator.push(
                    //     context,
                    //     MaterialPageRoute(
                    //         builder: (context) =>
                    //             CategoryProduct(locale.viewAll)));
                  },
                  child: Text(
                    locale.viewAll,
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  )),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: buildGridViewP(
                  sellerProducts, apCurrency, wishModel, storedetails),
            ),
          ],
        ),
      ),
    );
  }

  void addtocart(
      String storeid, String varientid, dynamic qnty, String special) async {
    print('$storeid $varientid $qnty $special');
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var http = Client();
    http.post(addToCartUri, body: {
      'user_id': '${preferences.getInt('user_id')}',
      'qty': '${qnty}',
      'store_id': '${storedetails.store_id}',
      'varient_id': '${varientid}',
      'special': '${special}',
    }).then((value) {
      print('${value.body}');
      if (value.statusCode == 200) {
        AddToCartMainModel data1 =
            AddToCartMainModel.fromJson(jsonDecode(value.body));
        if (data1.status == "1" || data1.status == 1) {
          setState(() {
            inCart = true;
          });
        }
      }
      setState(() {
        progressadd = false;
      });
    }).catchError((e) {
      setState(() {
        progressadd = false;
      });
      print(e);
    });
  }
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
        Text(products.productName,maxLines: 1,
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
