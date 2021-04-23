import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:groshop/Auth/login_navigator.dart';
import 'package:groshop/Locale/locales.dart';
import 'package:groshop/Pages/About/about_us.dart';
import 'package:groshop/Pages/About/contact_us.dart';
import 'package:groshop/Pages/DrawerPages/my_orders_drawer.dart';
import 'package:groshop/Pages/Other/home_page.dart';
import 'package:groshop/Pages/Other/language_choose.dart';
import 'package:groshop/Pages/User/my_account.dart';
import 'package:groshop/Pages/User/wishlist.dart';
import 'package:groshop/Pages/reffernearn.dart';
import 'package:groshop/Pages/tncpage/tnc_page.dart';
import 'package:groshop/Pages/wallet/walletui.dart';
import 'package:groshop/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

Drawer buildDrawer(BuildContext context, userName, bool islogin,{VoidCallback onHit}) {
  var locale = AppLocalizations.of(context);
  return Drawer(
    child: Container(
      height: MediaQuery.of(context).size.height,
      padding: EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/menubg.png'), fit: BoxFit.cover)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 44.0),
            child: Text(
              (userName!=null)?locale.hey + ' $userName':locale.hey + ' User',
              style: Theme.of(context)
                  .textTheme
                  .bodyText1
                  .copyWith(fontSize: 22, letterSpacing: 0.5),
            ),
          ),
          Expanded(
              child: SingleChildScrollView(
            child: Column(
              children: [
                buildListTile(context, Icons.home, locale.home, HomePage()),
                Visibility(
                  visible: islogin,
                  child: buildListTile(
                      context, Icons.account_box, locale.myProfile, MyAccount()),
                ),
                buildListTile(context, Icons.shopping_cart, locale.myOrders,
                    MyOrdersDrawer()),
                // buildListTile(
                //     context, Icons.local_offer, locale.offers, OffersPage()),
                Visibility(
                  visible: islogin,
                  child: buildListTile(
                      context, Icons.favorite, locale.myWishList, MyWishList()),
                ),
                Visibility(
                  visible: islogin,
                  child: buildListTile(
                      context, Icons.account_balance_wallet_sharp, locale.mywallet, Wallet()),
                ),
                buildListTile(
                    context, Icons.view_list, locale.aboutUs, AboutUsPage()),
                buildListTile(context, Icons.admin_panel_settings_rounded,
                    locale.tnc, TNCPage()),
                buildListTile(
                    context, Icons.chat, locale.helpCentre, ContactUsPage()),
                buildListTile(
                    context, Icons.money, locale.inviteNEarn.toUpperCase(), RefferScreen()),
                buildListTile(
                    context, Icons.language, locale.language, ChooseLanguage()),
                ListTile(
                  onTap: () {
                    onHit();
                  },
                  leading: Icon(
                    Icons.subdirectory_arrow_right,
                    color: Theme.of(context).primaryColor,
                  ),
                  title: Text(
                    islogin?locale.logout:locale.login,
                    style: TextStyle(letterSpacing: 2),
                  ),
                ),
              ],
            ),
          ))
        ],
      ),
    ),
  );
}


ListTile buildListTile(
    BuildContext context, IconData icon, String title, Widget onPress) {
  return ListTile(
    onTap: () {
      Navigator.pop(context);
//      Navigator.pop(context);
      Navigator.push(context, MaterialPageRoute(builder: (context) => onPress));
      // BlocProvider.of<NavigationBloc>(context).add(NavigationEvents.HomePageClickedEvent);
    },
    leading: Icon(
      icon,
      color: Theme.of(context).primaryColor,
    ),
    title: Text(
      title,
      style: TextStyle(letterSpacing: 2),
    ),
  );
}
