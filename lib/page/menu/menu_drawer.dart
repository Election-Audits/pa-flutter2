import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_template/core/utils/toast.dart';
import 'package:flutter_template/core/utils/xuifont.dart';
import 'package:flutter_template/generated/i18n.dart';
import 'package:flutter_template/utils/provider.dart';

import 'package:flutter_template/page/menu/about.dart';
import 'package:flutter_template/page/menu/login.dart';
import 'package:flutter_template/page/menu/settings.dart';
import 'package:flutter_template/page/menu/sponsor.dart';
import 'package:flutter_template/page/subagent/agent.dart';


class MenuDrawer extends ConsumerWidget {
  const MenuDrawer({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(appStatusProvider);
    final value = ref.watch(userProfileProvider);
    return Drawer(
        child: SingleChildScrollView(
      child: Column(
        children: <Widget>[
          GestureDetector(
            child: Container(
              color: Theme.of(context).primaryColor,
              padding: EdgeInsets.only(top: 40, bottom: 20),
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ClipOval(
                      // 如果已登录，则显示用户头像；若未登录，则显示默认头像
                      child: FlutterLogo(
                        size: 80,
                      ),
                    ),
                  ),
                  Expanded(
                      child: Text(
                    value == null ? I18n.of(context)!.title : value,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ))
                ],
              ),
            ),
            onTap: () {
              ToastUtils.toast("点击头像");
            },
          ),
          MediaQuery.removePadding(
            context: context,
            // DrawerHeader consumes top MediaQuery padding.
            removeTop: true,
            child: ListView(
              shrinkWrap: true, //为true可以解决子控件必须设置高度的问题
              physics: NeverScrollableScrollPhysics(), //禁用滑动事件
              scrollDirection: Axis.vertical, // 水平listView
              children: <Widget>[
                //首页
                ListTile(
                  leading: Icon(Icons.home),
                  title: Text(I18n.of(context)!.home),
                  onTap: () {
                    ref.read(appStatusProvider.notifier).change(TAB_HOME_INDEX);
                    Navigator.pop(context);
                  },
                  selected: status == TAB_HOME_INDEX,
                ),
                ListTile(
                  leading: Icon(Icons.list),
                  title: Text(I18n.of(context)!.subAgents),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => AgentPage(),
                    ));
                  },
                  selected: status == TAB_AGENTS_INDEX,
                ),
                ListTile(
                  leading: Icon(Icons.local_activity),
                  title: Text(I18n.of(context)!.loginCodes),
                  onTap: () {
                    ref.read(appStatusProvider.notifier).change(TAB_LOGIN_CODES_INDEX);
                    Navigator.pop(context);
                  },
                  selected: status == TAB_LOGIN_CODES_INDEX,
                ),
                Divider(height: 1.0, color: Colors.grey),
                ListTile(
                  leading: Icon(Icons.notifications),
                  title: Text(I18n.of(context)!.myElectAreas),
                  onTap: () {
                    ref.read(appStatusProvider.notifier).change(TAB_ELECT_AREAS_INDEX);
                    Navigator.pop(context);
                  },
                  selected: status == TAB_ELECT_AREAS_INDEX,
                ),
                ListTile(
                  leading: Icon(Icons.notifications),
                  title: Text(I18n.of(context)!.uploadResults),
                  onTap: () {
                    ref.read(appStatusProvider.notifier).change(TAB_UPLOAD_RESULTS_INDEX);
                    Navigator.pop(context);
                  },
                  selected: status == TAB_UPLOAD_RESULTS_INDEX,
                ),
                Divider(height: 1.0, color: Colors.grey),
                ListTile(
                  leading: Icon(Icons.person),
                  title: Text(I18n.of(context)!.profile),
                  onTap: () {
                    ref.read(appStatusProvider.notifier).change(TAB_PROFILE_INDEX);
                    Navigator.pop(context);
                  },
                  selected: status == TAB_PROFILE_INDEX,
                ),
                //设置、关于、赞助
                Divider(height: 1.0, color: Colors.grey),
                ListTile(
                  leading: Icon(Icons.attach_money),
                  title: Text(I18n.of(context)!.sponsor),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => SponsorPage(),
                    ));
                  },
                ),
                ListTile(
                  leading: Icon(Icons.settings),
                  title: Text(I18n.of(context)!.settings),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => SettingsPage(),
                    ));
                  },
                ),
                ListTile(
                  leading: Icon(Icons.error_outline),
                  title: Text(I18n.of(context)!.about),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => AboutPage(),
                    ));
                  },
                ),
                //退出
                Divider(height: 1.0, color: Colors.grey),
                ListTile(
                  leading: Icon(XUIIcons.logout),
                  title: Text(I18n.of(context)!.logout),
                  onTap: () {
                    ref.read(userProfileProvider.notifier).changeNickName("");
                    Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => LoginPage(),
                        ),
                        (Route<dynamic> route) => false);
                  },
                )
              ],
            ),
          ),
        ],
      ),
    ));
  }
}
