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

  /// Select all (for testing)
  @Query('Select * FROM Result')
  Future<List<Result>> findResults();

  /// update a result's status and serverResultId ()
  @Query('''UPDATE Result SET status = :status, serverResultId = :serverResultId 
  WHERE stationId = :stationId AND electionId = :electionId AND status = 'pending' ''')
  Future<void> updateStatusResultId(String status, String serverResultId, String stationId, String electionId);

  /// update a result's summary, partyResults, candidateResults, unknownResults
  @Query('''UPDATE Result SET summary = :summary, partyResults = :partyResults, candidateResults = :candidateResults
  unknownResults = :unknownResults WHERE stationId = :stationId AND electionId = :electionId AND status = 'pending'
  ''')
  Future<void> updateSummaryResults(String summary, String partyResults, String candidateResults, String unknownResults,
  String stationId, String electionId);

  /// Delete all (TODO: only for testing)
  // @delete
  // Future<void> deleteResults(Result result);
  @Query('Delete FROM Result')
  Future<void> deleteResults();
}
