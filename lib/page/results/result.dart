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



class ResultPage extends ConsumerStatefulWidget {

  @override
  _ResultPageState createState() => _ResultPageState();
}


class _ResultPageState extends ConsumerState<ResultPage> {
  FocusNode blankNode = FocusNode();

  List<Widget> pendingWidgets = [];
  int numResultsSubmitted = 0;

  Future<String>? pendingQueryDone;
  Future<String>? completedQueryDone;


  @override
  void initState() {
    super.initState();
    // get the subAgents
    //pendingQueryDone = getSubAgentsQuery(); TODO

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
                      return AgentFormPage(numAgentsAdded: numResultsSubmitted,); //TODO
                    }
                  ));
                  // call function to query num agents
                  //getSubAgentsQuery(); //await
                },
              ),
              // Text(I18n.of(context)!.numberAgentsAdded(numResultsSubmitted.toString())),
              // Divider(),
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
                ]
              ),
        )
        
    );
  }


}
