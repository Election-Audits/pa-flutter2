// View (attempted) result submissions. Button at top to create new result submission

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_template/core/http/http.dart';
import 'package:flutter_template/core/utils/toast.dart';
import 'package:flutter_template/core/widget/loading_dialog.dart';
import 'package:flutter_template/generated/i18n.dart';
// import 'package:flutter_template/page/index.dart';
// import 'package:flutter_template/utils/provider.dart';
// import 'package:flutter/foundation.dart';
import 'package:flutter_template/page/subagent/agent-form.dart';
import 'package:flutter_template/page/results/pictures.dart';
import 'package:flutter_template/controller/result.dart';



class ResultPage extends ConsumerStatefulWidget {

  @override
  _ResultPageState createState() => _ResultPageState();
}


class _ResultPageState extends ConsumerState<ResultPage> {
  FocusNode blankNode = FocusNode();

  List<Widget> pendingWidgets = [];
  List<Widget> completedWidgets = [];
  int numResultsSubmitted = 0;

  Future<String>? pendingQueryDone;
  Future<String>? completedQueryDone;

  var resultController = ResultController(); // query functions


  @override
  void initState() {
    super.initState();
    // get the subAgents
    pendingQueryDone = getResultsQuery('pending');
    completedQueryDone = getResultsQuery('completed');
  }

  //@override void didChangeDependencies ()

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //leading: _leading(context),
        title: Text(I18n.of(context)!.uploadResults),
        //actions: <Widget>[],
      ),
      body: SizedBox.expand( // make child column take up the whole width
        child: Flex(
          //Column(
            direction: Axis.vertical,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // show 'add agent' button
              ElevatedButton(
                style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).primaryColor,
                    padding: EdgeInsets.all(15.0)),
                child: Text(I18n.of(context)!.uploadResults,
                    style: TextStyle(color: Colors.white)),
                onPressed: () async { // navigate to screen for adding subagents
                  await Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) {
                      return PicturesPage();
                    }
                  ));
                  // call function to query num agents
                  //getSubAgentsQuery(); //await
                },
              ),
              // Pending Results to resubmit
              Text(I18n.of(context)!.pending),
              Divider(),
              FutureBuilder(
                future: pendingQueryDone, 
                builder: (context,snapshot) {
                  // If your data is not loading show loader
                  if (!snapshot.hasData) {
                    return LoadingDialog(
                      showContent: false,
                      backgroundColor: Colors.black38,
                      loadingView: SpinKitCircle(color: Colors.white),
                    );
                  // If your data is not loading show loader
                  } else if (snapshot.hasError) {
                    debugPrint('Futurebuilder error getting pending submissions'); // TODO: Toast
                    return Text(I18n.of(context)!.somethingWentWrong);
                  }
                  // return loaded data
                  return Expanded(
                    child: ListView.builder(
                      scrollDirection: Axis.vertical,
                      //itemExtent: 100,
                      shrinkWrap: true,
                      itemCount: pendingWidgets.length,
                      itemBuilder: (BuildContext context, int index) {
                        return pendingWidgets[index];
                      }
                    )
                  );
                }
              ),
              SizedBox(height: 20,),
              // Completed Results to submit
              Text(I18n.of(context)!.completed),
              Divider(),
              FutureBuilder(
                future: completedQueryDone, 
                builder: (context,snapshot) {
                  // If your data is not loading show loader
                  if (!snapshot.hasData) {
                    return LoadingDialog(
                      showContent: false,
                      backgroundColor: Colors.black38,
                      loadingView: SpinKitCircle(color: Colors.white),
                    );
                  // If your data is not loading show loader
                  } else if (snapshot.hasError) {
                    debugPrint('Futurebuilder error getting completed submissions'); // TODO: Toast
                    return Text(I18n.of(context)!.somethingWentWrong);
                  }
                  // return loaded data
                  return Expanded(
                    child: ListView.builder(
                      scrollDirection: Axis.vertical,
                      //itemExtent: 100,
                      shrinkWrap: true,
                      itemCount: completedWidgets.length,
                      itemBuilder: (BuildContext context, int index) {
                        return completedWidgets[index];
                      }
                    )
                  );
                }
              ),
            ]
          ),
        )
        
    );
  }


  //
  Future<String> getResultsQuery(String status) async {
    var results = await resultController.getResults(status);
    // build widgets
    List<Widget> widgets = [];
    results.forEach((result) {
      DateTime createTime = DateTime.fromMillisecondsSinceEpoch(result.unixTime);

      widgets.add(
        Column(children: [
          Text(result.electionType),
          Text(result.stationName),
          Text(I18n.of(context)!.createdTime(createTime.toString())),
          // TODO: add view button to launch if pending/complete
          Divider()
        ],)
      );
    });

    // assign right widgets
    //setState(() { // when returning after an upload, will call function
      if (status == 'pending') pendingWidgets = widgets;
      else completedWidgets = widgets;
    //});

    return 'done'; // signal FutureBuilder to update widgets
  }


}
