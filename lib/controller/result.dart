// Controller for results pages

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_template/core/http/http.dart';
import 'package:flutter_template/generated/i18n.dart';
import 'package:flutter_template/db/entity/result.dart';

import 'package:flutter_template/db/database.dart';
import 'package:flutter_template/db/db-utils.dart';
import 'package:flutter_template/page/menu/login.dart';
import 'package:flutter_template/utils/ea-utils.dart';
import 'package:flutter_template/core/utils/toast.dart';
import 'package:flutter_template/utils/sputils.dart';
// import 'package:flutter_template/db/dao/result.dart';
import 'package:flutter_template/page/results/result-form.dart';


class ResultController {
  final mydb = MyDatabase();

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


  /// upload pictures to server
  /// create db record, upload pictures, update db record
  Future<void> onUploadPicturesPress(BuildContext context) async {
    debugPrint('on upload pictures press...');
    final resultDao = mydb.db.resultDao;
    var spf = await SPUtils.init(); // get access to shared prefs
    var stationId = await spf!.getString('stationId');
    var stationName = await spf.getString('stationName');
    var electionId = await spf.getString('electionId');
    var electionType = await spf.getString('electionType');

    var unixTime = DateTime.now().millisecondsSinceEpoch;
    final result = Result(unixTime, stationId!, stationName!, electionId!, electionType!, unixTime, 'pending');

    await resultDao.insertResult(result);
    // TODO: maybe delete previous pending results of this election type for this station

    // var results = await resultDao.findResults();
    // debugPrint('results: $results');

    // upload pictures
    // prepare form data
    var filePaths = await getPictureFiles();
    //FormData formD = FormData();
    Map<String,dynamic> map = {
      "electionId": electionId, "electoralAreaId": stationId,
      "files": []
    };
    for (var filePath in filePaths) {
      var fileName = filePath.split('/').last;
      var file = await MultipartFile.fromFile(filePath, filename: fileName);
      //formD.files.add(file);
      map['files']!.add(file);
    }
    //
    FormData formD = FormData.fromMap(map);
    var response = await XHttp.postFormData('/results/pictures', formD);
    debugPrint('Xhttp response: $response');
    int status = response.statusCode;
    var resBody = response.data; // {resultId}

    switch(status) {
      case 200 :
        // update db, then transition to screen for entering results
        await resultDao.updateStatusResultId('completed', resBody.resultId, stationId, electionId);
        // go to screen for entering results
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) {
            return ResultFormPage();
          }
        ));
        break;

      case 400 :
        debugPrint('picture upload error: ${resBody?.errMsg}');
        ToastUtils.error(resBody?.errMsg);
        break;

      case 401 :
        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
          builder: (context) {
            return LoginPage();
          }),
          (_)=> false
        );
        break;
        
      default  :
        debugPrint('upload picture error 500 or other');
        ToastUtils.error(I18n.of(context)!.somethingWentWrong);
    }

  }


    // read directory containing pictures
  Future<List<String>> getPictureFiles() async {
    var spf = await SPUtils.init();
    var pictureDir = await spf?.getString('pictureDir');
    debugPrint('pictureDir: $pictureDir');

    // read directory
    final dir = Directory(pictureDir!);
    final List<FileSystemEntity> entities = await dir.list().toList();
    debugPrint('entities: $entities');
    List<String> files = [];
    for (var entity in entities) {
      files.add(entity.path);
    }
    debugPrint('pictures: $files');
    debugPrint('number of pictures: ${files.length}');

    //
    return files;
  }

}

