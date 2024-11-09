// View my sub agents, as well as a button to launch form for adding new one

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_template/core/http/http.dart';
import 'package:flutter_template/core/utils/toast.dart';
import 'package:flutter_template/core/widget/loading_dialog.dart';
import 'package:flutter_template/generated/i18n.dart';
import 'package:flutter_template/page/index.dart';
import 'package:flutter_template/utils/provider.dart';
// import 'package:flutter/foundation.dart';
import 'package:flutter_template/page/details-form.dart';
import 'package:flutter_template/page/subagent/agent-form.dart';
import 'package:flutter_template/utils/sputils.dart';



class AgentPage extends ConsumerStatefulWidget {
  final bool isLoginCodeScreen; // same design used for viewing subagents and getting their login codes

  AgentPage({Key? key, this.isLoginCodeScreen = false}) : super(key: key);

  @override
  _AgentPageState createState() => _AgentPageState(isLoginCodeScreen);
}


class _AgentPageState extends ConsumerState<AgentPage> {
  FocusNode blankNode = FocusNode();
  final bool isLoginCodeScreen;
  // TextEditingController _otpController = TextEditingController();

  _AgentPageState(this.isLoginCodeScreen) : super();

  List<Widget> agentWidgets = [];
  int numAgentsAdded = 0;


  @override
  void initState() {
    super.initState();
    // get the subAgents
    getSubAgentsQuery();
  }

  //@override void didChangeDependencies ()

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //leading: _leading(context),
        title: Text(I18n.of(context)!.subAgents),
        //actions: <Widget>[],
      ),
      body: SizedBox.expand( // make child column take up the whole width
        child: Column(
            // mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // show 'add agent' button
              isLoginCodeScreen ? SizedBox.shrink()
              : ElevatedButton(
                  style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).primaryColor,
                      padding: EdgeInsets.all(15.0)),
                  child: Text(I18n.of(context)!.addSubAgents,
                      style: TextStyle(color: Colors.white)),
                  onPressed: () { // navigate to screen for adding subagents
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) {
                        return AgentFormPage(numAgentsAdded: numAgentsAdded,);
                      }
                    ));
                  },
                ),
              isLoginCodeScreen ? SizedBox.shrink() 
              : Text(I18n.of(context)!.numberAgentsAdded(numAgentsAdded.toString())),
              Divider(),
              ListView.builder(
                shrinkWrap: true,
                itemCount: agentWidgets.length,
                itemBuilder: (BuildContext context, int index) {
                  // return Container(
                  //   //width: 400, // added
                  //   height: 50,
                  //   color: Colors.amber[100+200*index],
                  //   child: Center(child: Text('Entry $index')),
                  // );
                  return agentWidgets[index];
                }
              )
            ],
          )
        
        )
        
    );
  }


  /// get subAgents on init
  Future getSubAgentsQuery() async {
    debugPrint('getSubAgentsQuery..');

    // show loading dialog/spinner
    // showDialog(
    //   context: context,
    //   barrierDismissible: false,
    //   builder: (BuildContext context) {
    //     return LoadingDialog(
    //       showContent: false,
    //       backgroundColor: Colors.black38,
    //       loadingView: SpinKitCircle(color: Colors.white),
    //     );
    //   }
    // );

    try {
      var response = await XHttp.get('/subagents');

      ///Navigator.of(context).pop(); // pop loading dialog/spinner
      int status = response.statusCode;

      if (status == 200) {
        // update agentWidgets
        var subAgents = response.data;
        debugPrint('sub agents: $subAgents');

        List<Widget> tmpWidgets = [];
        //tmpWidgets.addAll(
        subAgents.forEach((agent){
          debugPrint('agent: $agent');
          var name = '';
          if (agent.containsKey('otherNames')) name += agent['otherNames'];
          if (agent.containsKey('surname')) name += ' ${agent['surname']}';
          // check if user completed signup
          bool emailConfirmed = agent.containsKey('emailConfirmed') && agent.emailConfirmed;
          bool phoneConfirmed = agent.containsKey('phoneConfirmed') && agent.phoneConfirmed;
          bool hasSignedUp = emailConfirmed || phoneConfirmed;

          tmpWidgets.add(
            Column(children: [ // return
              name.isNotEmpty ? Text(name) : SizedBox.shrink(),
              agent.containsKey('email') ? Text(agent['email']) : SizedBox.shrink(),
              agent.containsKey('phone') ? Text(agent['phone']) : SizedBox.shrink(),
              hasSignedUp ? Text(I18n.of(context)!.signedUp, style: TextStyle(color: Colors.green),) 
              : Text(I18n.of(context)!.notSignedUp, style: TextStyle(color: Colors.red)),
              Divider()
              ],
            )
          );
        });
        //);

        setState(() {
          numAgentsAdded = subAgents.length;
          agentWidgets = tmpWidgets;
        });

      } else if (status == 400) {
        debugPrint('GET /subagents error: ${response?.data?.errMsg}');
        ToastUtils.error(response.data?.errMsg);
      } else {
        debugPrint('GET /subagents error 500');
        ToastUtils.error(I18n.of(context)!.somethingWentWrong);
      }

    } catch (exc) {
      debugPrint("caught exc on getSubAgentsQuery: $exc");
      ToastUtils.error(I18n.of(context)!.somethingWentWrong);
    }


    return 5;
  }

}
