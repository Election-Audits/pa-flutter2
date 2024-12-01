import 'package:flutter/material.dart';
// import 'package:flutter_easyrefresh/easy_refresh.dart';
// import 'package:flutter_template/core/utils/toast.dart';
// import 'package:flutter_template/core/widget/grid/grid_item.dart';
// import 'package:flutter_template/core/widget/list/article_item.dart';
import 'package:flutter_template/generated/i18n.dart';

class TabHomePage extends StatefulWidget {
  @override
  _TabHomePageState createState() => _TabHomePageState();
}

class _TabHomePageState extends State<TabHomePage> {
  final String bullet = "\u2022 ";
  TextStyle textStyle = TextStyle(fontSize: 16);

  @override
  Widget build(BuildContext context) {
    return Column(
        children: [
          const Image(image: AssetImage('assets/images/logo-named.png')),
          Padding(padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(I18n.of(context)!.click_hamburger_icon, style: TextStyle(fontSize: 18))
          ),
          //
          Padding(padding: const EdgeInsets.only(bottom: 8),
            child: Text(I18n.of(context)!.checklist, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          Expanded(child:
            Padding(padding: EdgeInsets.symmetric(horizontal: 10),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$bullet ${I18n.of(context)!.checkitem_elect_area}', style: textStyle),
                  Text('$bullet ${I18n.of(context)!.checkitem_add_subagents}', style: textStyle),
                  Text('$bullet ${I18n.of(context)!.checkitem_assist_subagents}', style: textStyle),
                  Text('$bullet ${I18n.of(context)!.checkitem_upload_results}', style: textStyle)
                ]
              )
            )
          )
        ],
    );
  }



  

  
}
