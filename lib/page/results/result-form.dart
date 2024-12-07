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
//import 'package:flutter_template/db/database.dart';
import 'package:flutter_template/db/db-utils.dart';


class ResultFormPage extends ConsumerStatefulWidget {
  final String serverResultId; // resultId of picture upload

  ResultFormPage({Key? key, required this.serverResultId}) : super(key: key);

  @override
  _ResultFormPageState createState() => _ResultFormPageState(serverResultId);
}


class _ResultFormPageState extends ConsumerState<ResultFormPage> {
  final String serverResultId;

  _ResultFormPageState(this.serverResultId) : super();

  FocusNode blankNode = FocusNode();
  TextEditingController _numRegisteredController = TextEditingController();
  TextEditingController _numVotedController = TextEditingController();
  TextEditingController _numRejectedController = TextEditingController();

  List<TextEditingController> _contestantControllers = [];

  Future<String>? queryDone;
  List<Widget> contestantFields = [];
  List<Candidate> _candidates = [];

  final mydb = MyDatabase();

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
                return Column(
                  children: [
                    ListView.builder(
                      scrollDirection: Axis.vertical,
                      //itemExtent: 100,
                      shrinkWrap: true,
                      itemCount: contestantFields.length,
                      itemBuilder: (BuildContext context, int index) {
                        return contestantFields[index];
                      }
                    ),

                    // submit button
                    SizedBox(height: 20),
                    ElevatedButton(
                      style: TextButton.styleFrom(
                        foregroundColor: Theme.of(context).primaryColor,
                        padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 48.0)
                      ),
                      child: Text(I18n.of(context)!.submit,
                        style: TextStyle(color: Colors.white)),
                      onPressed: () {
                        submitResults();
                      },
                    )
                  ]
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
        debugPrint('GET /candidates error: ${response?.data['errMsg']}');
        ToastUtils.error(response.data['errMsg']);
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


  // submit results
  Future<void> submitResults() async {
    closeKeyboard(context);

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

    // build map of results to transmit
    var dataSend = {
      "resultId": serverResultId,
      "summary": {
        "numRegisteredVoters": _numRegisteredController.text.trim(),
        "totalNumVotes": _numVotedController.text.trim(),
        "numRejectedVotes": _numRejectedController.text.trim()
      },
      "results": []
    };

    // iterate through _candidates and _contestantControllers to get values
    var candResults = [];
    for (var ind=0; ind< _candidates.length; ind++) {
      var numVotes = _contestantControllers[ind].text.trim();
      var candidate = _candidates[ind];
      var candData = {
        "candidateId": candidate.id,
        "numVotes": numVotes
      };

      candResults.add(candData);
    }

    dataSend["results"] = candResults;

    // Send the data
    var response = await XHttp.putJson('/results/summary', dataSend);
    int status = response.statusCode;
    var resBody = response.data;

    switch(status) {
      case 200 :
        // mark completed in database. Go to results screen
        final resultDao = mydb.db.resultDao;
        var spf = await SPUtils.init(); // get access to shared prefs
        var stationId = await spf!.getString('stationId');
        var electionId = await spf.getString('electionId');
        await resultDao.updateStatusResultId('completed', serverResultId, stationId, electionId);
        // go to results page
        Navigator.of(context)..pop()..pop();
        break;

      case 400 :
        debugPrint('submit results error: ${resBody['errMsg']}');
        ToastUtils.error(resBody['errMsg']);
        break;

      case 401 :
        debugPrint('401 on put /results/summary');
        // Don't redirect to login, could be non-polling station agent making call
        ToastUtils.error(I18n.of(context)!.unauthorized);
        break;

      default :
        debugPrint('PUT /results/summary error 500 or other');
        ToastUtils.error(I18n.of(context)!.somethingWentWrong);
    }

  }

}
