
/// An electoral area received from the server
class ElectoralArea {

  const ElectoralArea(this.name, this._id);
  final String name;
  final String _id;
  // final String level;
  // final String parentLevelName;

  String get id => this._id;
}


/// An election received from the server
class Election {

  const Election(this.id, this.type);
  final String id;
  //final String name;
  final String type;
}
