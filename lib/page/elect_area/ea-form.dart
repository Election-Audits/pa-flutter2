// Choose and add an electoral area

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_template/core/http/http.dart';
import 'package:flutter_template/core/utils/toast.dart';
import 'package:flutter_template/core/widget/loading_dialog.dart';
import 'package:flutter_template/generated/i18n.dart';



class ElectAreaFormPage extends ConsumerStatefulWidget {

  @override
  _ElectAreaFormPageState createState ()=> _ElectAreaFormPageState();
}


class _ElectAreaFormPageState extends ConsumerState<ElectAreaFormPage> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //leading: _leading(context),
        title: Text(I18n.of(context)!.addSubAgents),
        //actions: <Widget>[],
      ),
      body: Column(
        
      )
    );
  }
}



