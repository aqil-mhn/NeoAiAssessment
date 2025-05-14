import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

String dbName = "db.local";
var path = '/my/db/path';
String dbPath = "";
int version = 1;

Future<void> initiateDatabase() async {
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
    path = 'my_web_web.db';
  }
  dbPath = join(await getDatabasesPath(), dbName);
  var database = await openDatabase(
    dbPath,
    version: version
  );

  String recipe = "CREATE TABLE IF NOT EXISTS recipes (id TEXT PRIMARY KEY, datasource TEXT, name TEXT, type TEXT, source TEXT, imageLink TEXT, imagePath TEXT, dateInsert TEXT)";
  await database.execute(recipe);
}

Future<void> dropDatabase() async {
  dbPath = join(await getDatabasesPath(), dbName);

  var database = await openDatabase(
    dbPath,
    version: version
  );

  database.execute("DROP TABLE IF EXISTS recipes");

  initiateDatabase();
}