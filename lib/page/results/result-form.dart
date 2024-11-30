// Form for entering results of every contestant in a given election

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_template/core/http/http.dart';
import 'package:flutter_template/core/utils/toast.dart';
import 'package:flutter_template/core/widget/loading_dialog.dart';
import 'package:flutter_template/generated/i18n.dart';
import 'package:flutter_template/page/menu/login.dart';

import 'package:flutter_template/page/results/pictures.dart';
import 'package:flutter_template/utils/sputils.dart';
import 'package:flutter_template/utils/ea-utils.dart';


class ResultFormPage extends ConsumerStatefulWidget {

  @override
  _ResultFormPageState createState() => _ResultFormPageState();
}


class _ResultFormPageState extends ConsumerState<ResultFormPage> {
  FocusNode blankNode = FocusNode();
  TextEditingController _numRegisteredController = TextEditingController();
  TextEditingController _numVotedController = TextEditingController();
  TextEditingController _numRejectedController = TextEditingController();

  List<TextEditingController> _contestantControllers = [];

  Future<String>? queryDone;
  List<Widget> contestantFields = [];
  List<Candidate> _candidates = [];

  @override
  void initState() {
    super.initState();
    queryDone = getCandidatesWrapper();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(), // title: Text(I18n.of(context)!.register)
      body: GestureDetector(
        onTap: () {
          // 点击空白页面关闭键盘
          closeKeyboard(context);
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
          child: Column(children: [
            // summary form
            Form(//key: _formKey,
              autovalidateMode: AutovalidateMode.disabled,
              child: Column(children: <Widget>[
                // Text(
                //   I18n.of(context)!.summary_num_registered,
                //   textAlign: TextAlign.center,
                // ),
                TextFormField(
                  autofocus: false,
                  controller: _numRegisteredController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: I18n.of(context)!.summary_num_registered,
                    hintText: '0',
                    hintStyle: TextStyle(fontSize: 12),
                    //icon: Icon(Icons.email)
                  ),
                ),
                TextFormField(
                  autofocus: false,
                  controller: _numVotedController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: I18n.of(context)!.summary_num_voted,
                    hintText: '0',
                    //hintStyle: TextStyle(fontSize: 12),
                  ),
                ),
                TextFormField(
                  autofocus: false,
                  controller: _numRejectedController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: I18n.of(context)!.summary_num_rejected,
                    hintText: '0',
                    //hintStyle: TextStyle(fontSize: 12),
                  ),
                )
              ])
            ),

            // Future Builder for votes by each candidate
            FutureBuilder(
              future: queryDone, 
              builder: (context, snapshot) {
                // If your data is not loading show loader
                if (!snapshot.hasData) {
                  return LoadingDialog(
                    showContent: false,
                    backgroundColor: Colors.black38,
                    loadingView: SpinKitCircle(color: Colors.white),
                  );
                } else if (snapshot.hasError) {
                  debugPrint('Futurebuilder error getting candidates');
                  return Text(I18n.of(context)!.somethingWentWrong);
                }

                // return loaded data
                return //Expanded(
                  //child: 
                  ListView.builder(
                    scrollDirection: Axis.vertical,
                    //itemExtent: 100,
                    shrinkWrap: true,
                    itemCount: contestantFields.length,
                    itemBuilder: (BuildContext context, int index) {
                      return contestantFields[index];
                    }
                  );
                //);
              }
            )

          ])
        ),
      ),
    );
  }

  void closeKeyboard(BuildContext context) {
    FocusScope.of(context).requestFocus(blankNode);
  }


  /// get candidates of a given election from the server
  Future<List<Candidate>> getCandidates() async {
    debugPrint('getCandidates running...');
    var spf = await SPUtils.init(); // get access to shared prefs
    var electionId = await spf!.getString('electionId');
    var response = await XHttp.get('/candidates', {"electionId": electionId});
    int status = response.statusCode; debugPrint('status; $status');

    List<Candidate> candidates = [];

    switch (status) {
      case 200 :
        var candidatesRet = response.data;
        debugPrint('candidatesRet: $candidatesRet');
        //candidates = [];
        for (var cand in candidatesRet) {
          var tmpCand = Candidate(cand['_id'], cand['partyId'], cand['partyInitials'], cand['partyName'], cand['surname'],
            cand['otherNames'] );
          candidates.add(tmpCand);
        }
        break;

      case 400 :
        debugPrint('GET /candidates error: ${response?.data?.errMsg}');
        ToastUtils.error(response.data?.errMsg);
        break;

      case 401 :
        debugPrint('401 on get /candidates');
        //ToastUtils.waring("not logged in");
        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
          builder: (context) {
            return LoginPage();
          }),
          (_)=> false
        );
        break;

      default :
        debugPrint('/account/deactivate error 500 or other');
        ToastUtils.error(I18n.of(context)!.somethingWentWrong);
    }

    return candidates;
  }

  // return a string to be used by the future builder
  Future<String> getCandidatesWrapper() async {
    _candidates = await getCandidates();

    // build widgets
    for (var candidate in _candidates) {
      // Add controller for the text
      _contestantControllers.add(TextEditingController());
      //
      var nameWithParty = '${candidate.partyInitials}:  ${candidate.otherNames} ${candidate.surname}';
      var candidateName = '${candidate.otherNames} ${candidate.surname}';
      var labelText = candidate.partyInitials.isEmpty ? candidateName : nameWithParty;
      contestantFields.add(
        TextFormField(
          autofocus: false,
          controller: _contestantControllers.last,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: labelText,
            hintText: '0',
            //hintStyle: TextStyle(fontSize: 12),
          ),
        )
      );
    }

    debugPrint('getCandidatesWrapper done');
    return "done";
  }


}
