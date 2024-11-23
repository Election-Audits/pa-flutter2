
import 'package:flutter_template/db/database.dart';


// Database Singleton
class MyDatabase {
  static final MyDatabase _databaseInst = MyDatabase._internal();

  factory MyDatabase() {
    return _databaseInst;
  }

  MyDatabase._internal();

  dynamic db;

  Future initDb() async {
    db = await $FloorAppDatabase.databaseBuilder('app_db.db').build();
  }

}


/*
class MyDatabase {
  static final MyDatabase _database = MyDatabase._internal();

  factory MyDatabase() {
    return _database;
  }

  MyDatabase._internal();
}
*/
