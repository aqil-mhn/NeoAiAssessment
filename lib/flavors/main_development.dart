import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:neoai_assessment/configs/app_config.dart';
import 'package:neoai_assessment/configs/app_database.dart';
import 'package:neoai_assessment/firebase_options.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
  );
  if (kIsWeb) {
    // Use web implementation on the web.
    databaseFactory = databaseFactoryFfiWeb;
  } else {
    // Use ffi on Linux and Windows.
    if (Platform.isLinux || Platform.isWindows) {
      databaseFactory = databaseFactoryFfi;
      sqfliteFfiInit();
    }
  }
  var db = await openDatabase(inMemoryDatabasePath);
  print((await db.rawQuery('SELECT sqlite_version()')).first.values.first);
  await db.close();
  await initiateDatabase();

  await AppConfig(
    appName: "Neo Ai Assessment",
    environment: AppEnvironment.developemnt
  ).run();
}