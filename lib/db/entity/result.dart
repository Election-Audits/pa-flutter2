// Results entity
import 'package:floor/floor.dart';

// election Results
@entity
class Result {
  @PrimaryKey(autoGenerate: true)
  final int id;

  final String stationId;
  final String stationName;
  final String electionId;
  final String electionType; // presidential, parliamentary
  final int unixTime; // also used to name the folder containing the pictures
  String status; // pending or completed
  String? serverResultId; // resultId from server database
  String? summary; // stringified JSON of summary {totalNumVotes, numRegisteredVoters, numRejectedVotes}
  String? partyResults; // stringified JSON of {[partyId]: <numVotes>,...}
  String? candidateResults; // stringified JSON of {[candidateId]: <numVotes>,...}
  String? unknownResults; // stringified JSON of {[name]: <numVotes>...} for when party/independent candidate not known

  Result(this.id, this.stationId, this.stationName, this.electionId, this.electionType, this.unixTime, this.status); // this.id, 

  // TODO: indexes: status, unixTime?

  @override
  String toString() {
    return 'Result {id: $id, electoralAreaId: $stationId, status: $status, electionType ... }';
  }
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
