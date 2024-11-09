// Add a new sub agent

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_template/core/http/http.dart';
import 'package:flutter_template/core/utils/toast.dart';
import 'package:flutter_template/core/widget/loading_dialog.dart';
import 'package:flutter_template/generated/i18n.dart';
import 'package:flutter_template/page/index.dart';
import 'package:flutter_template/utils/provider.dart';
// import 'package:flutter/foundation.dart';
import 'package:flutter_template/page/details-form.dart';
import 'package:flutter_template/utils/sputils.dart';


/*
/// get the current count of subagents
@riverpod
String countAgent(Ref ref) { // , BuildContext context, int count
  return "";
  //return I18n.of(context)!.numberAgentsAdded(count.toString());
}

/// get the previously set subAgent
@riverpod
String lastAgent(BuildContext context, Map<String, String> agent) {
  var info = agent['email'] ?? agent['phone'];
  var name = '';
  if (agent['otherNames'] != null) name += '${agent['otherNames']} ';
  if (agent['surname'] != null) name += '${agent['surname']}';
  return "$name ($info)";
}
*/



class AgentFormPage extends ConsumerStatefulWidget {
  int numAgentsAdded;

  AgentFormPage({Key? key, required this.numAgentsAdded}) : super(key: key);

  @override
  _AgentFormPageState createState() => _AgentFormPageState(numAgentsAdded);
}


class _AgentFormPageState extends ConsumerState<AgentFormPage> {
//class AgentFormPage extends ConsumerWidget {
  FocusNode blankNode = FocusNode();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _surnameController = TextEditingController();
  TextEditingController _otherNamesController = TextEditingController();
  //String? agentJustAdded;
  int numAgentsAdded;
  String lastAgentAddedStr = "";
  //GlobalKey _formKey = GlobalKey<FormState>();

  _AgentFormPageState(this.numAgentsAdded) : super();

  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) { // , WidgetRef ref
    //final numAgentsStr = ref.watch(countAgentProvider);

    return Scaffold(
      appBar: AppBar(
        //leading: _leading(context),
        title: Text(I18n.of(context)!.addSubAgents),
        //actions: <Widget>[],
      ),
      body: Column( //SizedBox.expand(
        children: [
          ///Text(I18n.of(context)!.numberAgentsAdded( numAgentsAdded.toString() )),
          //(agentJustAdded != null) ?Text(I18n.of(context)!.previouslyAdded) : SizedBox.shrink(),
          // (agentJustAdded != null) ? Text(agentJustAdded!) : SizedBox.shrink(),

          Text( I18n.of(context)!.numberAgentsAdded(numAgentsAdded.toString()) ),
          SizedBox(height: 10,),
          Text(I18n.of(context)!.previouslyAdded),
          Text(lastAgentAddedStr),

          //
          Padding(
            // key: _formKey, //设置globalKey，用于后面获取FormState
            // autovalidateMode: AutovalidateMode.disabled,
            padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 24.0),
            child: Column(
              children: [
                Divider(),
                // Form
                Text(
                  I18n.of(context)!.enterEmailPhone,
                  textAlign: TextAlign.center,
                ),
                TextFormField(
                  autofocus: false,
                  controller: _emailController,
                  decoration: InputDecoration(
                      labelText: I18n.of(context)!.email,
                      hintText: I18n.of(context)!.emailHint,
                      hintStyle: TextStyle(fontSize: 12),
                      icon: Icon(Icons.email))
                ),
                // phone
                TextFormField(
                  autofocus: false,
                  controller: _phoneController,
                  decoration: InputDecoration(
                      labelText: I18n.of(context)!.phone,
                      hintText: I18n.of(context)!.phoneHint,
                      hintStyle: TextStyle(fontSize: 12),
                      icon: Icon(Icons.phone))
                ),
                TextFormField(
                  autofocus: false,
                  controller: _surnameController,
                  decoration: InputDecoration(
                    labelText: I18n.of(context)!.surnameOptional,
                    icon: Icon(Icons.text_fields)
                  )
                ),
                // phone
                TextFormField(
                  autofocus: false,
                  controller: _otherNamesController,
                  decoration: InputDecoration(
                      labelText: I18n.of(context)!.otherNamesOptional,
                      icon: Icon(Icons.text_fields)
                  ),
                ),
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
                      onSubmitAgent(context);
                    },
                  )
                )
                
            ],),
          )
        ]
        
      )
    );
  }


  void closeKeyboard(BuildContext context) {
    FocusScope.of(context).requestFocus(blankNode);
  }


  ///
  Future onSubmitAgent(BuildContext context) async {
    debugPrint('onSubmitAgent clicked...');
    closeKeyboard(context);

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

    // get data to be sent
    Map<String,dynamic> subAgent = {};
    String email = _emailController.text.trim();
    String phone = _phoneController.text.trim();
    String surname = _surnameController.text.trim();
    String otherNames = _otherNamesController.text.trim();
    if (email.isNotEmpty) subAgent['email'] = email;
    if (phone.isNotEmpty) subAgent['phone'] = phone;
    if (surname.isNotEmpty) subAgent['surname'] = surname;
    if (otherNames.isNotEmpty) subAgent['otherNames'] = otherNames;
    
    var dataSend = {
      "people": [ subAgent ]
    };

    try {
      var response = await XHttp.postJson('/subagents', dataSend);
      Navigator.of(context).pop(); // pop loading dialog/spinner
      var status = response.statusCode;

      if (status == 200) {
        // update the count of number of agents added, and the previously added agent
        setState(() {
          numAgentsAdded++;
          lastAgentAddedStr = getLastAgentStr(subAgent);
        });
        // reset the form for entering next data
        _emailController.text = "";
        _phoneController.text = "";
        _surnameController.text = "";
        _otherNamesController.text = "";



      } else if (status == 400) {
        debugPrint('POST /subagents error: ${response?.data?.errMsg}');
        ToastUtils.error(response.data?.errMsg);
      } else {
        debugPrint('POST /subagents error 500');
        ToastUtils.error(I18n.of(context)!.somethingWentWrong);
      }

    } catch (exc) {
      debugPrint('POST /subagents caught exc: $exc');
      ToastUtils.error(I18n.of(context)!.somethingWentWrong);
    }
  }

  /// get string of last agent added to display
  String getLastAgentStr(Map<String, dynamic> agent) {
    var info = agent['email'] ?? agent['phone'];
    var name = '';
    if (agent['otherNames'] != null) name += '${agent['otherNames']} ';
    if (agent['surname'] != null) name += '${agent['surname']}';
    return "$name ($info)";
  }



}
