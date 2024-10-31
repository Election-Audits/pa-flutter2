import 'package:flutter/material.dart';
import 'package:flutter_template/core/widget/web_view_page.dart';
import 'package:flutter_template/init/splash.dart';
import 'package:flutter_template/page/index.dart';
import 'package:flutter_template/page/menu/about.dart';
import 'package:flutter_template/page/menu/login.dart';
import 'package:flutter_template/page/menu/settings.dart';
import 'package:flutter_template/page/menu/sponsor.dart';

class RouteMap {

  static Map<String, Widget Function(BuildContext)> routers = {
    '/': (context) => SplashPage(),
    '/login': (context) => LoginPage(),
    '/home': (context) => MainHomePage(),
    '/web': (context) => WebViewPage(),
    '/menu/sponsor-page': (context) => SponsorPage(),
    '/menu/settings-page': (context) => SettingsPage(),
    '/menu/about-page': (context) => AboutPage(),
  };

  /// 页面切换动画
  static Widget getTransitions(
      BuildContext context, Animation<double> animation1, Animation<double> animation2, Widget child) {
    return SlideTransition(
      position: Tween<Offset>(
              //1.0为右进右出，-1.0为左进左出
              begin: Offset(1.0, 0.0),
              end: Offset(0.0, 0.0))
          .animate(CurvedAnimation(parent: animation1, curve: Curves.fastOutSlowIn)),
      child: child,
    );
  }
}
