import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_template/core/utils/click.dart';
import 'package:flutter_template/core/utils/privacy.dart';
import 'package:flutter_template/core/utils/toast.dart';
//import 'package:flutter_template/core/utils/xupdate.dart';
import 'package:flutter_template/generated/i18n.dart';
import 'package:flutter_template/page/home/tab_home.dart';
import 'package:flutter_template/utils/provider.dart';

import 'menu/menu_drawer.dart';

class MainHomePage extends ConsumerStatefulWidget {
  MainHomePage({Key? key}) : super(key: key);
  
  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _MainHomePageState();
  }
}

class _MainHomePageState extends ConsumerState<MainHomePage> {
  
  List<BottomNavigationBarItem> getTabs(BuildContext context) => [
        BottomNavigationBarItem(
            label: I18n.of(context)!.home, icon: Icon(Icons.home)),
        BottomNavigationBarItem(
            label: I18n.of(context)!.category, icon: Icon(Icons.list)),
        BottomNavigationBarItem(
            label: I18n.of(context)!.activity, icon: Icon(Icons.local_activity)),
        BottomNavigationBarItem(
            label: I18n.of(context)!.message, icon: Icon(Icons.notifications)),
        BottomNavigationBarItem(
            label: I18n.of(context)!.profile, icon: Icon(Icons.person)),
      ];

  List<Widget> getTabWidget(BuildContext context) => [
        TabHomePage(),
        Center(child: Text(I18n.of(context)!.category)),
        Center(child: Text(I18n.of(context)!.activity)),
        Center(child: Text(I18n.of(context)!.message)),
        Center(child: Text(I18n.of(context)!.profile)),
      ];

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    //XUpdate.initAndCheck();
  }

  @override
  void dispose() {
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final status = ref.watch(appStatusProvider);
    var tabs = getTabs(context);
    return WillPopScope(
          child: Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
              title: Text(tabs[status].label!),
              actions: <Widget>[
                IconButton(
                    icon: Icon(Icons.security),
                    onPressed: () {
                      PrivacyUtils.showPrivacyDialog(context,
                          onAgressCallback: () {
                        Navigator.of(context).pop();
                        ToastUtils.success(I18n.of(context)!.agreePrivacy);
                      });
                    }),
              ],
            ),
            drawer: MenuDrawer(),
            body: IndexedStack(
              index: status,
              children: getTabWidget(context),
            ),
          ),
          //监听导航栏返回,类似onKeyEvent
          onWillPop: () =>
              ClickUtils.exitBy2Click(status: _scaffoldKey.currentState));
  }
}
