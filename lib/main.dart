import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:groshop/Pages/Other/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Auth/login_navigator.dart';
import 'Locale/locales.dart';
import 'Routes/routes.dart';
import 'Theme/style.dart';
import 'language_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: Colors.transparent));
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool result = prefs.getBool('islogin');
  bool skip = prefs.getBool('skip');
  Firebase.initializeApp().then((value) {
    setFirebase();
  });
  runApp(Phoenix(
      child: ((skip != null && skip) || (result != null && result))
          ? GroceryHome()
          : GroceryLogin()));
}

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

void setFirebase() async {
  FirebaseMessaging messaging = FirebaseMessaging();
  iosPermission(messaging);
  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  var initializationSettingsAndroid = AndroidInitializationSettings('icon');
  var initializationSettingsIOS = IOSInitializationSettings(
      onDidReceiveLocalNotification: onDidReceiveLocalNotification);
  var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: selectNotification);
  messaging.getToken().then((value) {
    debugPrint('token: $value');
  });
  messaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        _showNotification(
            flutterLocalNotificationsPlugin,
            '${message['notification']['title']}',
            '${message['notification']['body']}');
      },
      onBackgroundMessage: myBackgroundMessageHandler,
      onLaunch: (Map<String, dynamic> message) async {},
      onResume: (Map<String, dynamic> message) async {});
}

Future onDidReceiveLocalNotification(
    int id, String title, String body, String payload) async {
  _showNotification(flutterLocalNotificationsPlugin, '${title}', '${body}');
}

Future<void> _showNotification(
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
    dynamic title,
    dynamic body) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails('7458', 'Notify', 'Notify On Shopping',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'ticker');
  const IOSNotificationDetails iOSPlatformChannelSpecifics =
      IOSNotificationDetails(presentSound: false);
  const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics);
  await flutterLocalNotificationsPlugin.show(
      0, '${title}', '${body}', platformChannelSpecifics,
      payload: 'item x');
}

Future selectNotification(String payload) async {}

Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) async {
  _showNotification(
      flutterLocalNotificationsPlugin,
      '${message['notification']['title']}',
      '${message['notification']['body']}');
}

void iosPermission(firebaseMessaging) {
  firebaseMessaging.requestNotificationPermissions(
      IosNotificationSettings(sound: true, badge: true, alert: true));
  firebaseMessaging.onIosSettingsRegistered.listen((event) {
    print('${event.provisional}');
  });
}

class GroceryLogin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<LanguageCubit>(
      create: (context) => LanguageCubit(),
      child: BlocBuilder<LanguageCubit, Locale>(
        builder: (_, locale) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            localizationsDelegates: [
              const AppLocalizationsDelegate(),
              GlobalMaterialLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            supportedLocales: [
              const Locale('en'),
              const Locale('ar'),
              const Locale('pt'),
              const Locale('fr'),
              const Locale('id'),
              const Locale('es'),
            ],
            locale: locale,
            theme: appTheme,
            home: SignInNavigator(),
            routes: PageRoutes().routes(),
          );
        },
      ),
    );
  }
}

class GroceryHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<LanguageCubit>(
      create: (context) => LanguageCubit(),
      child: BlocBuilder<LanguageCubit, Locale>(
        builder: (_, locale) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            localizationsDelegates: [
              const AppLocalizationsDelegate(),
              GlobalMaterialLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            supportedLocales: [
              const Locale('en'),
              const Locale('ar'),
              const Locale('pt'),
              const Locale('fr'),
              const Locale('id'),
              const Locale('es'),
            ],
            locale: locale,
            theme: appTheme,
            home: HomePage(),
            routes: PageRoutes().routes(),
          );
        },
      ),
    );
  }
}
