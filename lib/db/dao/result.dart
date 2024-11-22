// Data Access Object for Result

import 'package:floor/floor.dart';

// NB: adding import to ensure Result defined. Not in docs
import 'package:flutter_template/db/entity/result.dart';


@dao
abstract class ResultDao {
  @insert
  Future<void> insertResult(Result result);

  // select results by status
  @Query('Select * FROM Result WHERE status = :status')
  Future<List<Result>> findResultsByStatus(String status);

  // TODO: update a result

}
