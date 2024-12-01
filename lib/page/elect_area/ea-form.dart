// Choose and add an electoral area

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_template/core/http/http.dart';
import 'package:flutter_template/core/utils/toast.dart';
import 'package:flutter_template/core/widget/loading_dialog.dart';
import 'package:flutter_template/generated/i18n.dart';
import 'package:flutter_template/page/menu/login.dart';
import 'package:flutter_template/utils/ea-utils.dart';



class ElectAreaFormPage extends ConsumerStatefulWidget {
  int numElectAreasAdded;

  ElectAreaFormPage({Key? key, required this.numElectAreasAdded}) : super(key: key);

  @override
  _ElectAreaFormPageState createState ()=> _ElectAreaFormPageState(numElectAreasAdded);
}


class _ElectAreaFormPageState extends ConsumerState<ElectAreaFormPage> {

  int numElectAreasAdded;

  _ElectAreaFormPageState(this.numElectAreasAdded) : super();

  String lastElectAreaAdded = "";

  Future<String>? optionsQueryDone;

  //String? _selectedElectAreaName;
  ElectoralArea? _selectedElectArea;
  List<DropdownMenuItem<ElectoralArea>> _electAreaChoices = [];

  @override
  void initState() {
    super.initState();
    optionsQueryDone = queryElectAreaOptions();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //leading: _leading(context),
        title: Text(I18n.of(context)!.addChangeElectArea),
        //actions: <Widget>[],
      ),
      body: SizedBox.expand(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Text( I18n.of(context)!.numberElectAreasAdded(numElectAreasAdded.toString()) ),
            SizedBox(height: 10,),
            // Text(I18n.of(context)!.previouslyAdded),
            // Text(lastElectAreaAdded),
            //
            Padding(
              // key: _formKey, //设置globalKey，用于后面获取FormState
              // autovalidateMode: AutovalidateMode.disabled,
              padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 24.0),
              child: FutureBuilder(
                future: optionsQueryDone, 
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return LoadingDialog(
                      showContent: false,
                      backgroundColor: Colors.black38,
                      loadingView: SpinKitCircle(color: Colors.white),
                    );
                  } else if (snapshot.hasError) {
                    debugPrint('Futurebuilder error getting electoral area options');
                    return Text(I18n.of(context)!.somethingWentWrong);
                  }
                  
                  // return loaded data
                  return Column(
                    children: [
                      _dropDown( underline: Container() ),
                      // Submit
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 24.0),
                        child: ElevatedButton(
                          style: TextButton.styleFrom(
                            foregroundColor: Theme.of(context).primaryColor,
                            padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 48.0)
                          ),
                          child: Text(I18n.of(context)!.submit,
                            style: TextStyle(color: Colors.white)),
                          onPressed: () {
                            setElectoralAreaQuery(context);
                          },
                        )
                      )
                    ],
                  );
                  
                }
              )
            )
            

          ]
        )
      )
      
    );
  }


  // dropdown with list of electoral areas. Populated after query
  Widget _dropDown({
    Widget? underline,
    Widget? icon,
    TextStyle? style,
    TextStyle? hintStyle,
    Color? dropdownColor,
    Color? iconEnabledColor,
  }) => DropdownButton<ElectoralArea>(
    value: _selectedElectArea,
    underline: underline,
    icon: icon,
    dropdownColor: dropdownColor,
    style: style,
    iconEnabledColor: iconEnabledColor, 
    onChanged: (ElectoralArea? newValue) {
      setState(() {
        _selectedElectArea = newValue;
      });
    },
    hint: Text( I18n.of(context)!.selectElectoralArea('electoral area') ),
    items: _electAreaChoices
  );


  /// query electoral area options available
  Future<String> queryElectAreaOptions() async {
    debugPrint('query electoral area options...');

    try {
      var response = await XHttp.get('/electoral-area/options');
      int status = response.statusCode;

      if (status == 200) {
        // update select options
        var electAreas = response.data;
        debugPrint('elect areas: $electAreas');
        List<DropdownMenuItem<ElectoralArea>> tmpElectAreas = [];

        for (var electArea in electAreas) {
          var electAreaInst = new ElectoralArea(electArea['name'], electArea['_id']);
          tmpElectAreas.add( new DropdownMenuItem(
            value: electAreaInst,
            child: Text(electAreaInst.name)) 
          );
        }

        setState(() {
          _electAreaChoices = tmpElectAreas; // cause update
        });

      } else if (status == 400) {
        debugPrint('GET "electoral area options" error: ${response?.data['errMsg']}');
        ToastUtils.error(response.data['errMsg']);
      } else if (status == 401) {
        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
          builder: (context) {
            return LoginPage();
          }),
          (_)=> false
        );

      } else {
        debugPrint('GET /subagents error 500');
        ToastUtils.error(I18n.of(context)!.somethingWentWrong);
      }


    } catch (exc) {
      debugPrint("caught exc on getSubAgentsQuery: $exc");
      ToastUtils.error(I18n.of(context)!.somethingWentWrong);
    }


    return "done"; // ensure FutureBuilder has return data
  }


  ///
  Future setElectoralAreaQuery(BuildContext context) async {
    debugPrint('set electoral area query...');

    // show loading dialog/spinner
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return LoadingDialog(
          showContent: false,
          backgroundColor: Colors.black38,
          loadingView: SpinKitCircle(color: Colors.white),
        );
      }
    );

    if (_selectedElectArea == null) {
      debugPrint('need to select an electoral area before submitting');
      return;
    }

    // get data to be sent
    var dataSend = {
      "electoralAreaId": _selectedElectArea!.id
    };

    try {
      var response = await XHttp.putJson('/agent/electoral-area', dataSend);
      Navigator.of(context).pop(); // pop loading dialog/spinner
      int status = response.statusCode;
      debugPrint('POST electoral area response: $status');

      if (status == 200) {
        ToastUtils.success(I18n.of(context)!.requestSuccess);
      } else if (status==400) {
        debugPrint('POST electoral area error: ${response?.data['errMsg']}');
        ToastUtils.error(response.data['errMsg']);

      } else if (status == 401) {
        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
          builder: (context) {
            return LoginPage();
          }),
          (_)=> false
        );

      } else {
        debugPrint('POST electoral area error 500');
        ToastUtils.error(I18n.of(context)!.somethingWentWrong);
      }

    } catch (exc) {
      debugPrint('setElectoralAreaQuery function caught exc: $exc');
      ToastUtils.error(I18n.of(context)!.somethingWentWrong);
    }
  }

}



