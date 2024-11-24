// Controller for results pages

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_template/core/http/http.dart';
import 'package:flutter_template/generated/i18n.dart';
import 'package:flutter_template/db/entity/result.dart';

import 'package:flutter_template/db/database.dart';
import 'package:flutter_template/db/db-utils.dart';
import 'package:flutter_template/utils/ea-utils.dart';
import 'package:flutter_template/core/utils/toast.dart';


class ResultController {

  dynamic database = null;
  dynamic resultDao;


  /// Get results (pending or completed) from database
  Future<List<Result>> getResults(String status) async {
    debugPrint('getResults($status) called...');
    try {
      var mydb = MyDatabase();
      var resultDao = mydb.db.resultDao;
      List<Result> results = await resultDao.findResultsByStatus(status);
      return results;
    } catch (exc) {
      debugPrint('exception getting results from db: $exc');
      return [];
    }
  }


  /// Query electoral areas/stations of agent
  Future<List<ElectoralArea>> getMyStations(BuildContext context) async {
    debugPrint("getMyStations query...");
    List<ElectoralArea> stationsRet = [];

    try {
      var response = await XHttp.get('/agent/electoral-areas');
      int status = response.statusCode;
      debugPrint('status: $status');

      if (status == 200) { // TODO: status 401
        var stations = response.data;
        debugPrint('stations (controller): $stations');
        //stationsRet = stations.forEach((station){
        for (var station in stations) {
          var tmpStation = new ElectoralArea(station['name'], station['_id']);
          stationsRet.add(tmpStation);
          //return tmpStation;
        }
        //});

      } else if (status == 400) {
        debugPrint('GET /agent/electoral-areas error: ${response?.data?.errMsg}');
        ToastUtils.error(response.data?.errMsg);
      } else {
        debugPrint('GET /agent/electoral-areas error 500');
        ToastUtils.error(I18n.of(context)!.somethingWentWrong);
      }
    } catch (exc) {
      debugPrint("caught exc on getSubAgentsQuery: $exc");
      ToastUtils.error(I18n.of(context)!.somethingWentWrong);
    }

    return stationsRet;
  }


  /// Query available elections of a given polling station/ electoral area
  Future<List<Election>> getStationElections(BuildContext context, String stationId) async {
    debugPrint('getStationElections query...');
    List<Election> electionsRet = [];

    try {
      var response = await XHttp.get('/electoral-area/$stationId/parents/elections');
      int status = response.statusCode; debugPrint('status: $status');

      if (status == 200) {
        var elections = response.data;
        debugPrint('elections (controller): $elections');

        for (var election in elections) {
          var tmpElection = new Election(election['_id'], election['type']);
          electionsRet.add(tmpElection);
          //return tmpElection;
        }
        //});

      } else if (status == 400) {
        debugPrint('GET /electoral-area/$stationId/parents/elections error: ${response?.data?.errMsg}');
        ToastUtils.error(response.data?.errMsg);
      } else {
        debugPrint('GET /electoral-area/$stationId/parents/elections error 500');
        ToastUtils.error(I18n.of(context)!.somethingWentWrong);
      }
    } catch (exc) {
      debugPrint("caught exc on getStationElections: $exc");
      ToastUtils.error(I18n.of(context)!.somethingWentWrong);
    }

    return electionsRet;
  }

}

