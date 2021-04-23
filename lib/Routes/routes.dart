import 'package:flutter/material.dart';
import 'package:groshop/Auth/checkout_navigator.dart';
import 'package:groshop/Components/cardstripe.dart';
import 'package:groshop/Pages/Checkout/Address.dart';
import 'package:groshop/Pages/Checkout/ConfirmOrder.dart';
import 'package:groshop/Pages/Checkout/PaymentMode.dart';
import 'package:groshop/Pages/Checkout/my_orders.dart';
import 'package:groshop/Pages/Checkout/orderdetailpage.dart';
import 'package:groshop/Pages/DrawerPages/invoicepage.dart';
import 'package:groshop/Pages/Other/add_address.dart';
import 'package:groshop/Pages/Other/category_products.dart';
import 'package:groshop/Pages/Other/edit_address.dart';
import 'package:groshop/Pages/Other/home_page.dart';
import 'package:groshop/Pages/Other/product_info.dart';
import 'package:groshop/Pages/Other/productbytags.dart';
import 'package:groshop/Pages/Other/reviews.dart';
import 'package:groshop/Pages/Search/cart.dart';
import 'package:groshop/Pages/Search/search_history.dart';
import 'package:groshop/Pages/Search/searchean.dart';
import 'package:groshop/Pages/categorypage/cat_sub_product.dart';
import 'package:groshop/Pages/categorypage/categorypage.dart';

class PageRoutes {
  static const String sidebar = '/side_bar';
  static const String homePage = '/home_page';
  static const String all_category = '/all_category';
  static const String cat_product = '/cat_product';
  static const String product = '/product';
  // static const String cart = '/cart';
  static const String search = '/search';
  static const String searchhistory = '/searchhistory';
  static const String cat_sub_p = '/catsubp';
  static const String tagproduct = '/tagproduct';
  static const String reviewsall = '/reviewsall';
//  static const String confirmOrder = 'confirm_order';
  static const String cartPage = 'checkout';
  static const String selectAddress = 'selectAddress';
  static const String editAddress = 'editAddress';
  static const String paymentMode = 'paymentMode';
  static const String confirmOrder = 'confirmOrder';
  static const String orderdetailspage = 'orderdetailspage';
  static const String myorder = 'myorder';
  static const String addaddressp = 'addaddressp';
  static const String stripecard = 'stripecard';
  static const String invoice = 'invoice';

  Map<String, WidgetBuilder> routes() {
    return {
      homePage: (context) => HomePage(),
      all_category: (context) => AllCategory(),
      cat_product: (context) => CategoryProduct(),
      product: (context) => ProductInfo(),
      // cart: (context) => CheckOutNavigator(),
      search: (context) => SearchEan(),
      searchhistory: (context) => SearchHistory(),
      cat_sub_p: (context) => CategorySubProduct(),
      tagproduct: (context) => TagsProduct(),
      reviewsall: (context) => Reviews(),
      cartPage: (context) => CartPage(),
      selectAddress: (context) => AddressPage(),
      editAddress: (context) => EditAddressPage(),
      orderdetailspage: (context) => OrderDeatilsPage(),
      paymentMode: (context) => PaymentModePage(),
      confirmOrder: (context) => ConfirmOrderPage(),
      myorder: (context) => MyOrders(),
      addaddressp: (context) => AddAddressPage(),
      stripecard: (context) => MyStripeCard(),
      invoice: (context) => MyInvoicePdf(),
//      confirmOrder: (context) => ConfirmOrderPage(),
    };
  }
}
