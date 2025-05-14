import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:neoai_assessment/configs/app_database.dart';
import 'package:neoai_assessment/modules/screens/recipe_form_screen.dart';
import 'package:sqflite/sqflite.dart';

class RecipeDetailScreen extends StatefulWidget {
  RecipeDetailScreen({super.key, required this.recipe});

  Map<String, dynamic> recipe = {};

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  Map<String, dynamic> datasource = {};
  Map<String, dynamic> recipe= {};
  final List<String> _tabs = [
    'Ingredients',
    'Instructions'
  ];

  @override
  void initState() {
    super.initState();
    
    init();
  }
  init() async {
    recipe = widget.recipe;
    datasource = jsonDecode(recipe['datasource']);
  }

  refreshData() async {
    final db = await openDatabase(dbPath, version: 1);

    final result = await db.query(
      'recipes',
      where: "id = ?",
      whereArgs: [widget.recipe['id']]
    );
    if (result.isNotEmpty) {
      setState(() {
        recipe = result.first;
        datasource = jsonDecode(recipe['datasource']);
      });
    }
  }

  Future<void> _deleteRecipe() async {
    try {
      final db = await openDatabase(dbPath, version: 1);
      await db.delete(
        'recipes',
        where: 'id = ?',
        whereArgs: [recipe['id']],
      );
      
      // Delete the image file
      final imageFile = File(recipe['imagePath']);
      if (await imageFile.exists()) {
        await imageFile.delete();
      }
      
    } catch (e) {
      print('Error deleting recipe: $e');
    }
  }

  Future<void> _showDeleteConfirmation() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Recipe'),
          content: Text('Are you sure you want to delete this recipe?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _deleteRecipe();
                Navigator.of(context).pop(true); // Close dialog
                Navigator.of(context).pop(true); // Return to previous screen
              },
              child: Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 98, 124, 119),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () => Navigator.of(context).pop(true),
        ),
        title: Text(
          "Recipe Detail",
          style: TextStyle(
            color: Colors.white
          ),
        ),
      ),
      body: SingleChildScrollView(
        // padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
        child: Column(
          children: [
            Column(
              children: [
                // Image Section
                Container(
                  height: 300,
                  width: double.infinity,
                  child: ClipRRect(
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(10),
                      // top: Radius.circular(10)
                    ),
                    child: Builder(
                      builder: (context) {
                        try {
                          if (kIsWeb) {
                            return Image.network(
                              recipe['imageLink'] ?? '',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(Icons.food_bank);
                              },
                            );
                          } else {
                            return Image.file(
                              File('${recipe['imagePath']}'),
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
                    )
                  ),
                ),
                Transform.translate(
                  offset: Offset(0, -50),
                  child: Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                        bottom: Radius.circular(20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: Offset(0, -5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          recipe['name'] ?? '-',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            _buildContainerTag(datasource['strCategory']),
                            SizedBox(
                              width: 10,
                            ),
                            _buildContainerTag(datasource['strArea']),
                          ],
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        DefaultTabController(
                          length: 2,
                          child: Column(
                            children: [
                              TabBar(
                                labelColor: const Color.fromARGB(255, 98, 124, 119),
                                unselectedLabelColor: Colors.grey,
                                indicatorColor: const Color.fromARGB(255, 98, 124, 119),
                                tabs: _tabs.map((String tab) => Tab(text: tab)).toList(),
                              ),
                              ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxHeight: MediaQuery.of(context).size.height * 0.4
                                ),
                                child: TabBarView(
                                  children: [
                                    // Ingredients Tab
                                    SingleChildScrollView(
                                      child: Column(
                                        children: List.generate(20, (index) {
                                          final ingredient = datasource['strIngredient${index + 1}'];
                                          final measure = datasource['strMeasure${index + 1}'];
                                          
                                          if (ingredient != null && ingredient.isNotEmpty) {
                                            return Padding(
                                              padding: EdgeInsets.symmetric(vertical: 4),
                                              child: Row(
                                                children: [
                                                  Text(
                                                    '•',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                  SizedBox(width: 8),
                                                  Expanded(  // Add this to handle long text
                                                    child: Text(
                                                      measure != null && measure.isNotEmpty 
                                                        ? '$measure $ingredient'
                                                        : ingredient,
                                                      style: TextStyle(fontSize: 14),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }
                                          return SizedBox.shrink();
                                        }),
                                      ),
                                    ),
                                    SingleChildScrollView(
                                      child: Padding(
                                        padding: EdgeInsets.only(top: 8),
                                        child: Text(
                                          datasource['strInstructions'] ?? '-',
                                          style: TextStyle(fontSize: 14),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: OutlinedButton(
                                style: ButtonStyle(
                                  side: WidgetStateProperty.all(BorderSide(
                                    color: const Color.fromARGB(255, 98, 124, 119)
                                  ))
                                ),
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => RecipeFormScreen(
                                        isUpdate: true,
                                        data: recipe,
                                      ),
                                    ),
                                  ).then((value) {
                                    if (value == true) {
                                      refreshData();
                                    }
                                  });
                                },
                                child: Text(
                                  'Update',
                                  style: TextStyle(
                                    color: const Color.fromARGB(255, 98, 124, 119)
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Expanded(
                              flex: 1,
                              child: OutlinedButton(
                                style: ButtonStyle(
                                  side: WidgetStateProperty.all(BorderSide(
                                    color: Colors.red
                                  )),
                                  backgroundColor: WidgetStateProperty.all(const Color.fromARGB(255, 245, 205, 205))
                                ),
                                onPressed: () {
                                  _showDeleteConfirmation();
                                },
                                child: Text(
                                  'Delete',
                                  style: TextStyle(
                                    color: Colors.red
                                  ),
                                ),
                              ),
                            )
                          ],
                        )
                        // Add more recipe details here
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  _buildContainerTag(String title) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color.fromARGB(255, 98, 124, 119)
      ),
      child: Text(
        title.toString().toUpperCase(),
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white
        ),
      ),
    );
  }
}