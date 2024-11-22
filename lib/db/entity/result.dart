// Results entity
import 'package:floor/floor.dart';


@entity
class Result {
  @primaryKey
  final int id;

  final String electoralAreaId;
  final String electionId;
  final String picsFolder; // folder containing pictures
  String status; // pending or completed
  String? serverResultId; // resultId from server database
  // Summary? summary; TODO: create tables for Summary and ResultItem and use foreign key
  // List<ResultItem>? results;


  Result(this.id, this.electoralAreaId, this.electionId, this.picsFolder, this.status);
}


// a single result item for a given candidate
class ResultItem {
  final String partyId;
  final String candidateId; // if result of independent candidate
  final int numVotes;
  final String name; // optional if party/candidate not known


  ResultItem(this.partyId, this.candidateId, this.numVotes, this.name);
}


// result summary. total number of votes, number of registered voters etc
class Summary {
  int? totalNumVotes;
  int? numRegisteredVoters;
  int? numRejectedVotes;

  //Summary(this.totalNumVotes, this.numRegisteredVoters, this.numRejectedVotes);
}
