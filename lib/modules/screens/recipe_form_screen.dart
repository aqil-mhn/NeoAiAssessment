import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:neoai_assessment/configs/app_database.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sqflite/sqflite.dart';

class RecipeFormScreen extends StatefulWidget {
  RecipeFormScreen({super.key, required this.data, required this.isUpdate});

  bool isUpdate = false;
  Map<String, dynamic> data = {};

  @override
  State<RecipeFormScreen> createState() => _RecipeFormScreenState();
}

class _RecipeFormScreenState extends State<RecipeFormScreen> {
  final ImagePicker _picker = ImagePicker();
  final ValueNotifier<bool> _isUpdate = ValueNotifier<bool>(false);
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController nameController = TextEditingController();
  TextEditingController typeController = TextEditingController();
  TextEditingController areaController = TextEditingController();
  TextEditingController ingredientController = TextEditingController();
  TextEditingController measurementController = TextEditingController();
  TextEditingController instructionController = TextEditingController();
  List<TextEditingController> newIngredientController = <TextEditingController>[];
  List<TextEditingController> newMeasurementController = <TextEditingController>[];

  String imageData = '';
  bool _imageError = false;
  Map<String, dynamic> recipeData = {};
  List<String> newIngredientsField = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _isUpdate.value = widget.isUpdate;

    if (widget.data.isNotEmpty) {
      recipeData = Map<String, dynamic>.from(widget.data);
      if (kIsWeb) {
        imageData = recipeData['imageLink'];
      } else {
        imageData = recipeData['imagePath'];
      }

      final Map<String, dynamic> datasource = jsonDecode(recipeData['datasource']);

      nameController.text = recipeData['name'] ?? '';
      typeController.text = recipeData['type'] ?? '';
      areaController.text = datasource['strArea'] ?? '';
      instructionController.text = datasource['strInstructions'] ?? '';

      ingredientController.text = datasource['strIngredient1'] ?? '';
      measurementController.text = datasource['strMeasure1'] ?? '';

      for (int i = 2; i <= 20; i++) {
        final ingredient = datasource['strIngredient$i'];
        final measurement = datasource['strMeasure$i'];

        log("measurement ${measurement.toString()}");
        
        if (ingredient != null && ingredient.isNotEmpty) {
          newIngredientController.add(TextEditingController(text: ingredient));
          newMeasurementController.add(TextEditingController(text: measurement ?? ''));
        }
      }
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final File fileImage = File(image.path);
      final bytes = await fileImage.readAsBytes();
      final String base64Image = base64Encode(bytes);

      // isImageEdit = true;

      setState(() {
        imageData = base64Image;
        recipeData['imagePath'] = image.path;
      });
    } else {
      // isImageEdit = false;
    }
  }

  String generateId() {
    final random = math.Random();
    final numbers = List.generate(5, (_) => random.nextInt(10)).join();
    return numbers;
  }

  saveRecipe(Map<String, dynamic> data) async {
    List<String> allIngredients = [ingredientController.text];
    List<String> allMeasurements = [measurementController.text];

    String newID = generateId();
    
    for (var i = 0; i < newIngredientController.length; i++) {
      allIngredients.add(newIngredientController[i].text);
      allMeasurements.add(newMeasurementController[i].text);
    }

    Map<String, dynamic> recipeData = {
      "id": widget.isUpdate ? data['id'] : newID,
      "name": nameController.text,
      "type": typeController.text,
      // "area": areaController.text,
      "imagePath": data['imagePath'] ?? '',
      "source": "Local",
      "datasource": jsonEncode({
        "idMeal": newID,
        "strMeal": nameController.text,
        "strCategory": typeController.text,
        "strArea": areaController.text,
        "strInstructions": instructionController.text,
        ...Map.fromIterables(
          List.generate(20, (i) => "strIngredient${i + 1}"),
          List.generate(20, (i) => i < allIngredients.length ? allIngredients[i] : "")
        ),
        ...Map.fromIterables(
          List.generate(20, (i) => "strMeasure${i + 1}"),
          List.generate(20, (i) => i < allMeasurements.length ? allMeasurements[i] : "")
        ),
      }),
      "dateInsert": DateTime.now().millisecondsSinceEpoch.toString(),
    };

    try {
      final db = await openDatabase(dbPath, version: 1);
      
      if (widget.isUpdate) {
        await db.update(
          conflictAlgorithm: ConflictAlgorithm.replace,
          'recipes',
          recipeData,
          where: 'id = ?',
          whereArgs: [recipeData['id']],
        );
      } else {
        await db.insert(
          conflictAlgorithm: ConflictAlgorithm.replace,
          'recipes',
          recipeData
        );
      }

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(seconds: 1),
          content: Text("${widget.isUpdate ? 'Updated' : 'Saved'} successfully"),
          padding: EdgeInsets.fromLTRB(20, 10, 10, 10),
          margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50)
          ),
        ),
      );

      Navigator.of(context).pop(true);
    } catch (e) {
      log("Save Recipe Error >>> ${e.toString()}");
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(seconds: 1),
          content: Text("${widget.isUpdate ? "Edit" : "Save"} failed"),
          padding: EdgeInsets.fromLTRB(20, 10, 10, 10),
          margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50)),
        ),
      );
    }

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: Duration(seconds: 1),
        content: Text("${widget.isUpdate ? "Edit" : "Save"} successfully"),
        padding: EdgeInsets.fromLTRB(20, 10, 10, 10),
        margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50)),
      ),
    );
  }
  @override
  void dispose() {
    nameController.dispose();
    typeController.dispose();
    areaController.dispose();
    ingredientController.dispose();
    measurementController.dispose();
    instructionController.dispose();
    
    // Dispose additional controllers
    for (var controller in newIngredientController) {
      controller.dispose();
    }
    for (var controller in newMeasurementController) {
      controller.dispose();
    }
    
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 245, 243, 241),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 98, 124, 119),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "Recipe Form",
          style: TextStyle(
            color: Colors.white
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(10, 10, 10, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ValueListenableBuilder(
              valueListenable: _isUpdate,
              builder: (context, isUpdate, child) {
                return Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: _imageError ? Border.all(color: Colors.red) : null
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: isUpdate ? null : null,
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 231, 231, 231),
                                borderRadius: BorderRadius.circular(10)
                              ),
                              child: isUpdate ? ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  child: Builder(
                                    builder: (context) {
                                      try {
                                        if (kIsWeb) {
                                          return Image.network(
                                            recipeData['imageLink'] ?? '',
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) {
                                              return Icon(Icons.food_bank);
                                            },
                                          );
                                        } else {
                                          return Image.file(
                                            File('${recipeData['imagePath']}'),
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) {
                                              return Icon(Icons.food_bank);
                                            },
                                          );
                                        }
                                      } catch (e) {
                                        return Icon(Icons.food_bank);
                                      }
                                    },
                                  ),
                                ),
                              ) : imageData.isEmpty ? Center(
                                child: Column(
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        _pickImage();
                                        setState(() {
                                          _imageError = false;
                                        });
                                      },
                                      iconSize: 45,
                                      icon: Icon(
                                        Icons.add_a_photo_outlined,
                                      ),
                                    ),
                                  ],
                                ),
                              ) : ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  child: Image.memory(base64Decode(imageData)),
                                ),
                              )
                            ),
                            if (_imageError)
                            Align(
                              alignment: Alignment.center,
                              child: Text(
                                'Please select an image',
                                style: TextStyle(
                                  color: const Color.fromARGB(255, 158, 44, 36),
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            if (recipeData['imagePath'] != null)
                            Align(
                              alignment: Alignment.bottomRight,
                              child: OutlinedButton(
                                style: ButtonStyle(
                                  side: WidgetStateProperty.all(BorderSide(
                                    color: const Color.fromARGB(255, 98, 124, 119)
                                  ))
                                ),
                                onPressed: () {
                                  _pickImage();
                                },
                                child: Text(
                                  "Edit Image",
                                  style: TextStyle(
                                    color: const Color.fromARGB(255, 98, 124, 119)
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10)
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Recipe Name',
                              style: TextStyle(
                                fontSize: 15
                              ),
                            ),
                            TextFormField(
                              controller: nameController,
                              style: TextStyle(fontSize: 14),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Please enter recipe name";
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                isDense: true,
                                contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: const Color.fromARGB(255, 98, 124, 119)
                                  )
                                ),
                                labelStyle: TextStyle(fontSize: 12),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(width: 0.5)
                                ),
                                floatingLabelStyle: TextStyle(fontSize: 12),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              'Recipe Type',
                              style: TextStyle(
                                fontSize: 15
                              ),
                            ),
                            TextFormField(
                              controller: typeController,
                              style: TextStyle(fontSize: 14),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Please enter recipe type";
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                isDense: true,
                                contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: const Color.fromARGB(255, 98, 124, 119)
                                  )
                                ),
                                labelStyle: TextStyle(fontSize: 12),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(width: 0.5)
                                ),
                                floatingLabelStyle: TextStyle(fontSize: 12),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              'Origin of Recipe',
                              style: TextStyle(
                                fontSize: 15
                              ),
                            ),
                            TextFormField(
                              controller: areaController,
                              style: TextStyle(fontSize: 14),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Please enter recipe origin";
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                isDense: true,
                                contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: const Color.fromARGB(255, 98, 124, 119)
                                  )
                                ),
                                labelStyle: TextStyle(fontSize: 12),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(width: 0.5)
                                ),
                                floatingLabelStyle: TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10)
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Ingredient and Measurement 1',
                              style: TextStyle(
                                fontSize: 15
                              ),
                            ),
                            Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: TextFormField(
                                    controller: ingredientController,
                                    style: TextStyle(fontSize: 14),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return "Please add an ingredient";
                                      }
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                      isDense: true,
                                      contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: const Color.fromARGB(255, 98, 124, 119)
                                        )
                                      ),
                                      labelStyle: TextStyle(fontSize: 12),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(width: 0.5)
                                      ),
                                      floatingLabelStyle: TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Expanded(
                                  flex: 1,
                                  child: TextFormField(
                                    controller: measurementController,
                                    style: TextStyle(fontSize: 14),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return "Measurement required";
                                      }
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                      isDense: true,
                                      contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: const Color.fromARGB(255, 98, 124, 119)
                                        )
                                      ),
                                      labelStyle: TextStyle(fontSize: 12),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(width: 0.5)
                                      ),
                                      floatingLabelStyle: TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    if (newIngredientController.length < 19) {
                                      setState(() {
                                        newIngredientController.add(TextEditingController());
                                        newMeasurementController.add(TextEditingController());
                                      });
                                    } else {
                                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          duration: Duration(milliseconds: 600),
                                          content: Text(
                                            "Maximum 20 ingredients allowed"
                                          ),
                                          padding: EdgeInsets.fromLTRB(20, 10, 10, 10),
                                          margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(50)
                                                ),
                                        ),
                                      );
                                    }
                                  },
                                  icon: Icon(
                                    Icons.add_circle,
                                    color: const Color.fromARGB(255, 98, 124, 119),
                                    size: 30,
                                  ),
                                )
                              ],
                            ),
                            ...addNewTextField()
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10)
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Instruction',
                              style: TextStyle(
                                fontSize: 15
                              ),
                            ),
                            TextFormField(
                              controller: instructionController,
                              maxLines: null,
                              style: TextStyle(fontSize: 14),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Please enter any instruction for the recipe";
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                isDense: true,
                                contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: const Color.fromARGB(255, 98, 124, 119)
                                  )
                                ),
                                labelStyle: TextStyle(fontSize: 12),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(width: 0.5)
                                ),
                                floatingLabelStyle: TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      OutlinedButton(
                        style: ButtonStyle(
                          foregroundColor: WidgetStateProperty.all(Colors.white),
                          backgroundColor: WidgetStateProperty.all(const Color.fromARGB(255, 98, 124, 119),)
                        ),
                        onPressed: () {
                          setState(() {
                            _imageError = imageData.isEmpty;
                          });
                          if (_formKey.currentState!.validate() && !_imageError) {
                            // log("instructionController ${instructionController.text}");
                            saveRecipe({
                              'id': widget.data['id'],
                              'imagePath': recipeData['imagePath'] ?? imageData,
                            });
                          } else {
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                duration: Duration(milliseconds: 600),
                                content: Text(
                                  "Please fill in all field including the image"
                                ),
                                padding: EdgeInsets.fromLTRB(20, 10, 10, 10),
                                margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(50)
                                      ),
                              ),
                            );
                          }
                        },
                        child: Text(
                          'Submit',
                          style: TextStyle(
                            fontSize: 15
                          ),
                        ),
                      )
                    ],
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }

  List<Widget> addNewTextField() {
    var textField = <Widget>[];
    for (int i = 0; i < newIngredientController.length; i++) {
      textField.add(
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Ingredient and Measurement ${i + 2}',
              style: TextStyle(
                fontSize: 15
              ),
            ),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: newIngredientController[i],
                    style: TextStyle(fontSize: 14),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please add an ingredient";
                      }
                      return null;
                    }, 
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: const Color.fromARGB(255, 98, 124, 119)
                        )
                      ),
                      labelStyle: TextStyle(fontSize: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(width: 0.5)
                      ),
                      floatingLabelStyle: TextStyle(fontSize: 12),
                    ),
                  ),
                ),
                SizedBox(
                  width: 5,
                ),
                Expanded(
                  flex: 1,
                  child: TextFormField(
                    controller: newMeasurementController[i],
                    style: TextStyle(fontSize: 14),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Measurement required";
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: const Color.fromARGB(255, 98, 124, 119)
                        )
                      ),
                      labelStyle: TextStyle(fontSize: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(width: 0.5)
                      ),
                      floatingLabelStyle: TextStyle(fontSize: 12),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      newIngredientController.removeAt(i);
                      newMeasurementController.removeAt(i);
                    });
                  },
                  icon: Icon(
                    Icons.remove_circle,
                    color: Colors.red,
                    size: 30,
                  ),
                )
              ],
            ),
          ],
        )
      );
    }
    return textField;
  }
}