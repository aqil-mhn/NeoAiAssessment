import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:neoai_assessment/configs/app_database.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

Future<List<Map<String, dynamic>>> getRecipes() async {
  List<Map<String, dynamic>> recipes = [];

  for (int i = 0; i < 2; i++) {
    try {
      final response = await http.get(
        Uri.parse("https://www.themealdb.com/api/json/v1/1/random.php")
      );

      switch (response.statusCode) {
        case 200:
          Map<String, dynamic> data = jsonDecode(response.body);

          if (data['meals'] != null && data['meals'].isNotEmpty) {
            recipes.add(data['meals'][0]);

            Map<String, dynamic> meal = data['meals'][0];
            String imagePath = '';
            await downloadAndConvertImage(meal['strMealThumb'], meal['idMeal']).then((value) {
              imagePath = value;
            });

            await insertLDB(meal, imagePath);
          }
        default:
          Map<String, dynamic> data = {};
          recipes.add(data);
      }
    } catch (e) {
      log("Get Recipes >>> ${e.toString()}");
    }
  }

  return recipes;
}

downloadAndConvertImage(String url, String id) async {
  try {
    final response = await http.get(
      Uri.parse(url)
    );

    switch (response.statusCode) {
      case 200:
        Uint8List bytes = response.bodyBytes;
        String base64Image = base64Encode(bytes);

        final Directory directory = await getApplicationDocumentsDirectory();
        final userProfileDirectoryPath = '${directory.path}/recipeImage';

        final filePath = '${userProfileDirectoryPath}/${id}_${DateTime.now().microsecondsSinceEpoch}';
        final Directory userProfileDir = Directory(userProfileDirectoryPath);

        if (!await userProfileDir.exists()) {
          await userProfileDir.create(recursive: true);
        }

        final File userProfile = File(filePath);
        final bytesImage = base64Decode(base64Image);
        await userProfile.writeAsBytes(bytesImage);
        return userProfile.path;
      default:
        Map<String, dynamic> data = {};
        return "";
    }
  } catch (e) {
    log("Download and Convert Error >>> ${e.toString()}");
    return "";
  }
}

Future<void> insertLDB(Map<String, dynamic> meal, String imagePath) async {
  var db = await openDatabase(
    dbPath,
    version: 1
  );

  try {
    List<Map<String, Object?>> query = await db.query(
      'recipes',
      where: "id=?",
      whereArgs: [meal['idMeal']]
    );

    log("imageProfile in INSERTLDB ${imagePath.toString()}");

    if (query.isNotEmpty) {
      int updateLBD = await db.update(
        'recipes',
        conflictAlgorithm: ConflictAlgorithm.replace,
        {
          'datasource': jsonEncode(meal),
          'name': "${meal['strMeal']}",
          'type': "${meal['strCategory']}",
          'imageLink': "${meal['strMealThumb']}",
          // 'datasource': jsonEncode(user),
          'dateInsert': DateTime.now().millisecondsSinceEpoch.toString(),
          'imagePath': imagePath,
          'source': "API"
        },
        where: 'id=?',
        whereArgs: [meal['idMeal']]
      );
    } else {
      int updateLBD = await db.insert(
        'recipes',
        conflictAlgorithm: ConflictAlgorithm.replace,
        {
          'id': meal['idMeal'],
          'datasource': jsonEncode(meal),
          'name': "${meal['strMeal']}",
          'type': "${meal['strCategory']}",
          'imageLink': "${meal['strMealThumb']}",
          // 'datasource': jsonEncode(user),
          'dateInsert': DateTime.now().millisecondsSinceEpoch.toString(),
          'imagePath': imagePath,
          'source': "API"
        },
      );
    }
  } catch (e, stackTrace) {
    log("Insert LDB Error >>> ${e.toString()} | ${stackTrace.toString()}");
  }
}