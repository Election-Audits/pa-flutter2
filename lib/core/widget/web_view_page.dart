import 'dart:core';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:share/share.dart';

class WebViewPage extends StatefulWidget {
  WebViewPage();
  _WebViewPageState createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final Object? data = ModalRoute.of(context)?.settings.arguments;
    String url = (data is Map) ? data['url'] : "";
    String title = (data is Map) ? data['title'] : "";

    if (url.length == 0) {
      return Scaffold(
        appBar: AppBar(title: Text("Url is Empty"),),
      );
    }

    return WebviewScaffold(
      url: Uri.decodeComponent(url),
      debuggingEnabled: kReleaseMode ? false : true,
      withLocalStorage: true,
      withJavascript: true,
      hidden: false,
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(title, style: TextStyle(fontSize: 15)),
        titleSpacing: 0,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.share),
              onPressed: () {
                Share.share(url);
              }),
        ],
      ),
    );
  }
}
