import 'package:flutter/material.dart';
import 'package:groshop/Pages/Checkout/Address.dart';
import 'package:groshop/Pages/Checkout/ConfirmOrder.dart';
import 'package:groshop/Pages/Checkout/PaymentMode.dart';
import 'package:groshop/Pages/Checkout/my_orders.dart';
import 'package:groshop/Pages/Checkout/orderdetailpage.dart';
import 'package:groshop/Pages/Search/cart.dart';
import 'package:groshop/Routes/routes.dart';
import 'package:groshop/main.dart';

GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class CheckOutRoutes {
  static const String cartPage = 'root/checkout';
  static const String selectAddress = 'selectAddress/';
  static const String paymentMode = 'paymentMode';
  static const String confirmOrder = 'confirmOrder';
  static const String orderdetailspage = 'orderdetailspage';
  static const String myorder = 'myorder';
}

class CheckOutNavigator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        var canPop = navigatorKey.currentState.canPop();
        if (canPop) {
          navigatorKey.currentState.pop();
        }
        return !canPop;
      },
      child: Navigator(
        key: navigatorKey,
        initialRoute: CheckOutRoutes.cartPage,
        onGenerateRoute: (RouteSettings settings) {
          WidgetBuilder builder;
          switch (settings.name) {
            case CheckOutRoutes.cartPage:
              builder =
                  (BuildContext _) => CartPage();
              break;
            case CheckOutRoutes.selectAddress:
              builder = (BuildContext _) => AddressPage();
              break;
            case CheckOutRoutes.orderdetailspage:
              builder = (BuildContext _) => OrderDeatilsPage();
              break;
            case CheckOutRoutes.paymentMode:
              builder = (BuildContext _) => PaymentModePage();
              break;
            case CheckOutRoutes.confirmOrder:
              builder = (BuildContext _) => ConfirmOrderPage();
              break;
            case CheckOutRoutes.myorder:
              builder = (BuildContext _) => MyOrders();
              break;
          }
          return MaterialPageRoute(builder: builder, settings: settings);
        },
        onPopPage: (Route<dynamic> route, dynamic result) {
          return route.didPop(result);
        },
      ),
    );
  }
}
