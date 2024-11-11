// view my electoral areas, as well as a button to add new ones

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_template/core/http/http.dart';
import 'package:flutter_template/core/utils/toast.dart';
import 'package:flutter_template/core/widget/loading_dialog.dart';
import 'package:flutter_template/generated/i18n.dart';
import 'package:flutter_template/page/elect_area/ea-form.dart';



class ElectAreaPage extends ConsumerStatefulWidget {

  @override
  _ElectAreaPageState createState() => _ElectAreaPageState();
}


class _ElectAreaPageState extends ConsumerState<ElectAreaPage> {

  List<Widget> electAreaWidgets = []; //myElectAreas;
  int numElectAreas = 0;
  Future<String>? queryDone; // used in FutureBuilder

  @override
  void initState() {
    super.initState();
    queryDone = getElectAreasQuery();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //leading: _leading(context),
        title: Text(I18n.of(context)!.myElectAreas),
        //actions: <Widget>[],
      ),
      body: Column(
        children: [
          ElevatedButton(
            style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).primaryColor,
                padding: EdgeInsets.all(15.0)),
            child: Text(I18n.of(context)!.addChangeElectArea,
                style: TextStyle(color: Colors.white)),
            onPressed: () async { // navigate to screen for adding subagents
              await Navigator.of(context).push(MaterialPageRoute(
                builder: (context) {
                  return ElectAreaFormPage(numElectAreasAdded: numElectAreas);
                }
              ));
              // call function to query num agents
              getElectAreasQuery(); //await
            },
          ),
          Divider(),
          FutureBuilder(
            future: queryDone, 
            builder: (context,snapshot) {
              if (!snapshot.hasData) {
                return LoadingDialog(
                  showContent: false,
                  backgroundColor: Colors.black38,
                  loadingView: SpinKitCircle(color: Colors.white),
                );
              } else if (snapshot.hasError) {
                debugPrint('Futurebuilder error getting sub agents');
                return Text(I18n.of(context)!.somethingWentWrong);
              }

              // return loaded data
              return ListView.builder(
                scrollDirection: Axis.vertical,
                //itemExtent: 100,
                shrinkWrap: true,
                itemCount: electAreaWidgets.length,
                itemBuilder: (BuildContext context, int index) {
                  return electAreaWidgets[index];
                }
              );
            }
          )
        ],
      )

    );
  }


  Future<String> getElectAreasQuery() async {
    debugPrint('getElectAreas query...');
    try {
      var response = await XHttp.get('/agent/electoral-areas');
      int status = response.statusCode;

      if (status == 200) {
        // create widgets
        var electAreas = response.data;
        debugPrint('electoral areas: $electAreas');

        List<Widget> tmpWidgets = [];
        electAreas.forEach((electArea) {
          tmpWidgets.add(
            Column(children: [
              Text(electArea['name']), // electArea.name
              Divider()
            ],)
          );
        });

        // update widgets on screen
        setState(() {
          numElectAreas = electAreas.length;
          electAreaWidgets = tmpWidgets;
        });

      } else if (status == 400) {
        debugPrint('GET /agent/electoral-areas error: ${response?.data?.errMsg}');
        ToastUtils.error(response.data?.errMsg);
      } else {
        debugPrint('GET /agent/electoral-areas error 500');
        ToastUtils.error(I18n.of(context)!.somethingWentWrong);
      }

    } catch (exc) {
      debugPrint("caught exc on getElectAreasQuery: $exc");
      ToastUtils.error(I18n.of(context)!.somethingWentWrong);
    }

    return "done"; // ensure FutureBuilder has return data
  }




}
