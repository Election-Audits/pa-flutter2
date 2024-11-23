// Controller for results pages

import 'package:flutter/foundation.dart';
import 'package:flutter_template/core/http/http.dart';
import 'package:flutter_template/generated/i18n.dart';
import 'package:flutter_template/db/entity/result.dart';

import 'package:flutter_template/db/database.dart';
import 'package:flutter_template/db/db-utils.dart';


class ResultController {

  dynamic database = null;
  dynamic resultDao;


  // Get results (pending or completed) from database
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

}

