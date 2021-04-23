import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:groshop/Locale/locales.dart';
import 'package:groshop/Routes/routes.dart';
import 'package:groshop/Theme/colors.dart';
import 'package:groshop/baseurl/baseurlg.dart';
import 'package:groshop/beanmodel/category/categorymodel.dart';
import 'package:groshop/beanmodel/storefinder/storefinderbean.dart';
import 'package:http/http.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class AllCategory extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return AllCategoryState();
  }

}

class AllCategoryState extends State<AllCategory>{
  bool enterFirst = false;
  bool isLoading = false;
dynamic storeid;
StoreFinderData storedetail;
  List<CategoryDataModel> categories = [];

  @override
  void initState() {
    super.initState();
    // getCategory();
  }

  void getCategory(dynamic store_id) async{
    // SharedPreferences preferences = await SharedPreferences.getInstance();
    var http = Client();
    http.post(categoryUri,body: {
      'store_id':'${store_id}'
    }).then((value){
      if(value.statusCode == 200){
        CategoryModel data1 = CategoryModel.fromJson(jsonDecode(value.body));
        if(data1.status=="1" || data1.status==1){
          setState(() {
            categories.clear();
            categories = List.from(data1.data);
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
      print(e);
    });
  }

  @override
  Widget build(BuildContext context) {
var locale = AppLocalizations.of(context);
    Map<String,dynamic> receivedData = ModalRoute.of(context).settings.arguments;
    setState(() {
      if(!enterFirst){
        // title = receivedData['title'];
        enterFirst = true;
        isLoading = true;
        storeid = receivedData['store_id'];
        storedetail = receivedData['storedetail'];
        getCategory(receivedData['store_id']);
      }
    });

    return Scaffold(
      backgroundColor: kCardBackgroundColor,
appBar: AppBar(
  backgroundColor: kWhiteColor,
  title: Text(locale.shopbycategory),
),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: (!isLoading && (categories!=null && categories.length>0))?
        GridView.builder(
            padding: EdgeInsets.symmetric(vertical: 20,horizontal: 10),
            physics: ScrollPhysics(),
            shrinkWrap: true,
            primary: true,
            itemCount: categories.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemBuilder: (context, index) {
              return buildCategoryRow(
                  context,
                  categories[index],storeid,storedetail);
            }):(isLoading)?GridView.builder(
            padding: EdgeInsets.symmetric(vertical: 20,horizontal: 10),
            physics: ScrollPhysics(),
            shrinkWrap: true,
            primary: true,
            itemCount: 10,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemBuilder: (context, index) {
              return buildCategorySHRow(
                  context);
            }):Align(
          alignment: Alignment.center,
          child: Text(locale.nomorcategory),
        ),
      ),
    );
  }

}

GestureDetector buildCategoryRow(BuildContext context, CategoryDataModel categories, dynamic storeid, StoreFinderData storedetail) {
  bool hasSubCategory = false;

  if(categories.subcategory.length>0){
    hasSubCategory = true;
  }

  return GestureDetector(
    onTap: () {
      print(hasSubCategory);
      if(hasSubCategory){
        Navigator.pushNamed(context, PageRoutes.cat_sub_p,arguments: {
          'title': categories.title,
          'categories': categories,
          'storedetail': storedetail,
        });
      }else{
        Navigator.pushNamed(context, PageRoutes.cat_product,arguments: {
          'title': categories.title,
          'storeid': storedetail.store_id,
          'cat_id': categories.cat_id,
          'storedetail': storedetail,
        });
      }

    },
    child: Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: kWhiteColor,
          image: DecorationImage(
              image: NetworkImage(categories.image), fit: BoxFit.fill)),
      child: Text(categories.title,style: TextStyle(
          color: kMainTextColor,
          fontWeight: FontWeight.w600
      ),),
    ),
  );
}
GestureDetector buildCategorySHRow(BuildContext context) {
  return GestureDetector(
    onTap: () {

    },
    child: Shimmer(
      duration: Duration(seconds: 3),
      color: Colors.white,
      enabled: true,
      direction: ShimmerDirection.fromLTRB(),
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: kWhiteColor,),
        child: Container(
          height: 10,
          width: 100,
          color: Colors.grey[300],
        ),),
    ),
  );
}