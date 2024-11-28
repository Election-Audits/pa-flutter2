// database.dart
// 'dart run build_runner build'. Used to be flutter packages pub...

// required package imports
import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import 'dao/result.dart';
import 'entity/result.dart';


part 'database.g.dart'; // the generated code will be there


@Database(version: 1, entities: [Result])
abstract class AppDatabase extends FloorDatabase {
  ResultDao get resultDao;
}

