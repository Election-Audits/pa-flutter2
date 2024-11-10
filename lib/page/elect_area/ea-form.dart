// Choose and add an electoral area

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_template/core/http/http.dart';
import 'package:flutter_template/core/utils/toast.dart';
import 'package:flutter_template/core/widget/loading_dialog.dart';
import 'package:flutter_template/generated/i18n.dart';



class ElectAreaFormPage extends ConsumerStatefulWidget {
  int numElectAreasAdded;

  ElectAreaFormPage({Key? key, required this.numElectAreasAdded}) : super(key: key);

  @override
  _ElectAreaFormPageState createState ()=> _ElectAreaFormPageState(numElectAreasAdded);
}


class _ElectAreaFormPageState extends ConsumerState<ElectAreaFormPage> {

  int numElectAreasAdded;

  _ElectAreaFormPageState(this.numElectAreasAdded) : super();

  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //leading: _leading(context),
        title: Text(I18n.of(context)!.addChangeElectArea),
        //actions: <Widget>[],
      ),
      body: Column(
        children: [
          Text( I18n.of(context)!.numberElectAreasAdded(numElectAreasAdded.toString()) ),
          SizedBox(height: 10,),
          
        ]
      )
    );
  }
}



