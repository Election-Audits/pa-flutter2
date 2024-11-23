// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

abstract class $AppDatabaseBuilderContract {
  /// Adds migrations to the builder.
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations);

  /// Adds a database [Callback] to the builder.
  $AppDatabaseBuilderContract addCallback(Callback callback);

  /// Creates the database and initializes it.
  Future<AppDatabase> build();
}

// ignore: avoid_classes_with_only_static_members
class $FloorAppDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract databaseBuilder(String name) =>
      _$AppDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract inMemoryDatabaseBuilder() =>
      _$AppDatabaseBuilder(null);
}

class _$AppDatabaseBuilder implements $AppDatabaseBuilderContract {
  _$AppDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  @override
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  @override
  $AppDatabaseBuilderContract addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  @override
  Future<AppDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$AppDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$AppDatabase extends AppDatabase {
  _$AppDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  ResultDao? _resultDaoInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Result` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `stationId` TEXT NOT NULL, `stationName` TEXT NOT NULL, `electionId` TEXT NOT NULL, `electionType` TEXT NOT NULL, `unixTime` INTEGER NOT NULL, `status` TEXT NOT NULL, `serverResultId` TEXT, `summaryId` TEXT, `resultItemId` TEXT)');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  ResultDao get resultDao {
    return _resultDaoInstance ??= _$ResultDao(database, changeListener);
  }
}

class _$ResultDao extends ResultDao {
  _$ResultDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _resultInsertionAdapter = InsertionAdapter(
            database,
            'Result',
            (Result item) => <String, Object?>{
                  'id': item.id,
                  'stationId': item.stationId,
                  'stationName': item.stationName,
                  'electionId': item.electionId,
                  'electionType': item.electionType,
                  'unixTime': item.unixTime,
                  'status': item.status,
                  'serverResultId': item.serverResultId,
                  'summaryId': item.summaryId,
                  'resultItemId': item.resultItemId
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Result> _resultInsertionAdapter;

  @override
  Future<List<Result>> findResultsByStatus(String status) async {
    return _queryAdapter.queryList('Select * FROM Result WHERE status = ?1',
        mapper: (Map<String, Object?> row) => Result(
            row['id'] as int?,
            row['stationId'] as String,
            row['stationName'] as String,
            row['electionId'] as String,
            row['electionType'] as String,
            row['unixTime'] as int,
            row['status'] as String),
        arguments: [status]);
  }

  @override
  Future<List<Result>> findResults() async {
    return _queryAdapter.queryList('Select * FROM Result',
        mapper: (Map<String, Object?> row) => Result(
            row['id'] as int?,
            row['stationId'] as String,
            row['stationName'] as String,
            row['electionId'] as String,
            row['electionType'] as String,
            row['unixTime'] as int,
            row['status'] as String));
  }

  @override
  Future<void> insertResult(Result result) async {
    await _resultInsertionAdapter.insert(result, OnConflictStrategy.abort);
  }
}
