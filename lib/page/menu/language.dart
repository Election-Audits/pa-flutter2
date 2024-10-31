import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_template/generated/i18n.dart';
import 'package:flutter_template/init/default_app.dart';
import 'package:flutter_template/utils/provider.dart';
// import 'package:provider/provider.dart';

class LanguagePage extends ConsumerStatefulWidget {
  @override
  _LanguagePageState createState() => _LanguagePageState();
}

class _LanguagePageState extends ConsumerState<LanguagePage> {
  @override
  Widget build(BuildContext context) {
    Color color = Theme.of(context).primaryColor;
    final locale = ref.watch(localProvider);
    I18n S = I18n.of(context)!;

    Widget _buildLanguageItem(String lan, value) {
      return ListTile(
        title: Text(
          lan,
          // 对APP当前语言进行高亮显示
          style: TextStyle(color: locale == value ? color : null),
        ),
        trailing: locale == value ? Icon(Icons.done, color: color) : null,
        onTap: () {
          // 此行代码会通知MaterialApp重新build
          ref.read(localProvider.notifier).locale = value;
        },
      );
    }

    return Scaffold(
        appBar: AppBar(title: Text(S.language)),
        body: ListView(
          children: <Widget>[
            _buildLanguageItem(S.english, "en_US"),
            _buildLanguageItem(S.chinese, "zh_CN"),
            _buildLanguageItem(S.auto, LOCALE_FOLLOW_SYSTEM),
          ],
        ));
  }
}
