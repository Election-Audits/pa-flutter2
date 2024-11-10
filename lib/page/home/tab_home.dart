import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_template/core/utils/toast.dart';
import 'package:flutter_template/core/widget/grid/grid_item.dart';
import 'package:flutter_template/core/widget/list/article_item.dart';

class TabHomePage extends StatefulWidget {
  @override
  _TabHomePageState createState() => _TabHomePageState();
}

class _TabHomePageState extends State<TabHomePage> {

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text(
        "Election Audits",
        style: TextStyle(fontSize: 17),
        textAlign: TextAlign.center,
      ),
    );
  }



  

  
}
