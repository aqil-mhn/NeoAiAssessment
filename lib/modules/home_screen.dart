import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:neoai_assessment/commons/string_casing.dart';
import 'package:neoai_assessment/configs/app_database.dart';
import 'package:neoai_assessment/configs/context_extensions.dart';
import 'package:neoai_assessment/modules/logins/login_screen.dart';
import 'package:neoai_assessment/modules/screens/profile_screen.dart';
import 'package:neoai_assessment/modules/screens/recipe_detail_screen.dart';
import 'package:neoai_assessment/modules/screens/recipe_form_screen.dart';
import 'package:neoai_assessment/modules/services/firebase_auth_services.dart';
import 'package:neoai_assessment/modules/services/recipes_services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ValueNotifier<bool> _isLoading = ValueNotifier<bool>(true);
  final ValueNotifier<bool> _isFilter = ValueNotifier<bool>(false);
  final ValueNotifier<String> _typeSelected = ValueNotifier<String>('');
  final ValueNotifier<List<Map<String, dynamic>>> _filteredRecipes = ValueNotifier<List<Map<String, dynamic>>>([]);
  final ValueNotifier<Map<String, dynamic>> _featuredRecipe = ValueNotifier<Map<String, dynamic>>({});
  FirebaseAuthServices auth = FirebaseAuthServices();
  TextEditingController searchController = TextEditingController();

  final User? currentUser = FirebaseAuth.instance.currentUser;
  
  List<Map<String, dynamic>> recipes = [];
  List<DropdownMenuItem> categories = [];

  @override
  void initState() {
    super.initState();
    
    init();
  }

  void init() async {
    _isLoading.value = true;
    try {
      await getRecipes();
      await initLDB();
    } catch (e) {
      log("Get Recipes Error >>> ${e.toString()}");
    } finally {
      _isLoading.value = false;
    }
  }

  initLDB() async {
    recipes = [];
    var db = await openDatabase(
      dbPath,
      version: 1
    );

    recipes = await db.query("recipes");
    if (recipes.isNotEmpty) {
      final random = math.Random();
      final randomIndex = random.nextInt(recipes.length);
      _featuredRecipe.value = recipes[randomIndex];
      _filteredRecipes.value = List.from(recipes);

      Set<String> uniqueCategories = recipes.map((recipe) => recipe['type'].toString()).toSet();
      List<String> categoryList = uniqueCategories.toList();
      categories = List.generate(categoryList.length, (index) {
        final category = categoryList[index];
        final isLastItem = index == categoryList.length - 1;
        
        return DropdownMenuItem(
          value: category,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  category.toTitleCase(),
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 15
                  ),
                ),
              ),
              if (!isLastItem) // Only add divider if not the last item
                Divider(
                  height: 1,
                  color: Colors.grey[300],
                ),
            ],
          ),
        );
      }).toList();
    }
  }

  void filterRecipes(String catergory) {
    if (catergory == '') {
      _filteredRecipes.value = List.from(recipes);
    } else {
      _filteredRecipes.value = recipes.where((recipe) {
        return recipe['type'].toString() == catergory;
      }).toList();
    }
  }

  Future<void> handleSignOut() async {
    auth.signOut();

    var prefs = await SharedPreferences.getInstance();
    prefs.remove("isUserLoggedIn");
    prefs.remove("userUID");

    // Remove all routes and navigate to LoginScreen
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
      (route) => false, // This removes all routes from the stack
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 245, 243, 241),
      drawer: Drawer(
        elevation: 4,
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 98, 124, 119),
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.person,
                  size: 40,
                  color: const Color.fromARGB(255, 98, 124, 119),
                ),
              ),
              accountName: Text(
                currentUser?.displayName ?? 'User',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              accountEmail: Text(
                context.firebaseProvider.userName ?? 'No email',
                style: TextStyle(
                  fontSize: 14,
                ),
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  // ListTile(
                  //   leading: Icon(Icons.home),
                  //   title: Text('Home'),
                  //   onTap: () {
                  //     Navigator.pop(context); // Close drawer
                  //   },
                  // ),
                  ListTile(
                    leading: Icon(Icons.person),
                    title: Text('Profile'),
                    onTap: () {
                      Navigator.pop(context); // Close drawer
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfileScreen(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.add),
                    title: Text('Add Recipe'),
                    onTap: () {
                      Navigator.pop(context); // Close drawer
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => RecipeFormScreen(
                            isUpdate: false,
                            data: {},
                          ),
                        ),
                      ).then((value) {
                        if (value == true) {
                          initLDB();
                        }
                      });
                    },
                  ),
                ],
              ),
            ),
            Divider(),
            ListTile(
              leading: Icon(
                Icons.logout,
                color: Colors.red,
              ),
              title: Text(
                'Sign Out',
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
              onTap: () {
                handleSignOut();
              },
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 98, 124, 119),
        title: Text(
          "Recipes App",
          style: TextStyle(
            color: Colors.white
          ),
        ),
        actions: [
          InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => RecipeFormScreen(
                    isUpdate: false,
                    data: {},
                  ),
                ),
              ).then((value) {
                if (value == true) {
                  initLDB();
                }
              });
            },
            child: Container(
              padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white
              ),
              child: Text(
                "Add Recipe"
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              handleSignOut();
            },
            icon: Icon(
              Icons.logout,
              color: Colors.white,
            ),
          )
        ],
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      body: ValueListenableBuilder(
        valueListenable: _isLoading,
        builder: (context, value, child) {
          if (value) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: const Color.fromARGB(255, 98, 124, 119),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Text(
                    "Downloading recipes"
                  )
                ],
              ),
            );
          }
          return Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(10)
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 98, 124, 119)
                  ),
                  height: 250.0,
                ),
              ),
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        height: 45,
                        margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
                        child: ValueListenableBuilder(
                          valueListenable: _isFilter,
                          builder: (context, value, child) {
                            if (value) {
                              return Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100),
                                  color: Colors.white,
                                  border: Border.all(
                                    color: Colors.black
                                  )
                                ),
                                child: ButtonTheme(
                                  alignedDropdown: true,
                                  child: ValueListenableBuilder(
                                    valueListenable: _typeSelected,
                                    builder: (context, value, child) {
                                      return DropdownButton(
                                        menuMaxHeight: 300,
                                        alignment: AlignmentDirectional.centerStart,
                                        isExpanded: true,
                                        isDense: true,
                                        underline: Container(),
                                        borderRadius: BorderRadius.circular(10),
                                        dropdownColor: Colors.white,
                                        padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
                                        hint: Text(
                                          value == '' ? "Filter by category" : value,
                                          style: TextStyle(
                                            color: Colors.black
                                          ),
                                        ),
                                        items: categories,
                                        onChanged: (value) {
                                          _typeSelected.value = value;
                                          filterRecipes(value);
                                        },
                                        icon: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            if (value != '')
                                            IconButton(
                                              padding: EdgeInsets.all(0),
                                              onPressed: () {
                                                _typeSelected.value = '';
                                                filterRecipes('');
                                              },
                                              icon: Icon(
                                                Icons.close
                                              ),
                                            ),
                                            IconButton(
                                              padding: EdgeInsets.all(0),
                                              onPressed: () {
                                                _isFilter.value = !_isFilter.value;
                                              },
                                              icon: Icon(
                                                Icons.filter_alt
                                              ),
                                            ),
                                            Icon(
                                              Icons.arrow_drop_down
                                            )
                                          ],
                                        ),
                                      );
                                    },
                                  )
                                ),
                              );
                            }
                            return SearchAnchor(
                              isFullScreen: false,
                              dividerColor: Color.fromARGB(171, 208, 194, 194),
                              builder: (context, controller) {
                                return SearchBar(
                                  controller: searchController,
                                  leading: Icon(Icons.search),
                                  padding: WidgetStatePropertyAll<EdgeInsets>(
                                    EdgeInsets.symmetric(
                                      horizontal: 15,
                                      vertical: 2
                                    )
                                  ),
                                  onTap: () {
                                    controller.openView();
                                  },
                                  hintText: "Search recipe",
                                  trailing: [
                                    IconButton(
                                      onPressed: () {
                                        _isFilter.value = !_isFilter.value;
                                      },
                                      icon: Icon(
                                        Icons.filter_alt_outlined
                                      ),
                                    )
                                    // Padding(
                                    //   padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                                    //   child: Icon(
                                    //     Icons.search
                                    //   ),
                                    // )
                                  ],
                                  shadowColor: WidgetStatePropertyAll(
                                      Color.fromARGB(0, 63, 60, 51)),
                                );
                              },
                              suggestionsBuilder: (context, controller) {
                                String query = controller.text.toString().toLowerCase();
                                List<Map<String, dynamic>> results = _filteredRecipes.value.where((recipe) {
                                  String name = recipe['name'].toString().toLowerCase();

                                  return name.contains(query);
                                }).toList();

                                if (results.isEmpty) {
                                  return [
                                    Container(
                                      height: 240,
                                      child: Center(
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(50, 0, 50, 0),
                                          child: Text(
                                            "No Data Found",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Colors.black.withOpacity(0.7)
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  ];
                                } else {
                                  return List.generate(results.length, (index) {
                                    var data = results[index];
                                    return Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: ListTile(
                                        contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                        title: Text(
                                          data['name'] ?? '-'
                                        ),
                                        subtitle: Text(
                                          data['type'] ?? '-'
                                        ),
                                        leading: ClipRRect(
                                          borderRadius: BorderRadius.circular(10),
                                          child: Builder(
                                            builder: (context) {
                                              try {
                                                if (kIsWeb) {
                                                  return Container(
                                                    child: Image.network(
                                                      data['imageLink'],
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (context, error, stackTrace) {
                                                        return Icon(Icons.food_bank);
                                                      },
                                                    ),
                                                  );
                                                } else {
                                                  return Container(
                                                    child: Image.file(
                                                      File(data['imagePath']),
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (context, error, stackTrace) {
                                                        return Icon(Icons.food_bank);
                                                      },
                                                    ),
                                                  );
                                                }
                                              } catch (e) {
                                                return Icon(
                                                  Icons.food_bank,
                                                  // color: Colors.red,
                                                );
                                              }
                                            },
                                          ),
                                        ),
                                        onTap: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) => RecipeDetailScreen(
                                                recipe: data,
                                              )
                                            )
                                          ).then((value) {
                                            if (value == true) {
                                              initLDB();
                                            }
                                          });
                                        },
                                      ),
                                    );
                                  });
                                }
                              },
                            );
                          },
                        )
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      ValueListenableBuilder(
                        valueListenable: _typeSelected,
                        builder:(context, value, child) {
                          if (value == '') {
                            return Column(
                              children: [
                                Text(
                                  "Featured Recipe of The Day",
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.white
                                  ),
                                ),
                                ValueListenableBuilder(
                                  valueListenable: _featuredRecipe,
                                  builder: (context, value, child) {
                                    return LayoutBuilder(
                                      builder: (context, constraints) {
                                        final isLargeScreen = constraints.maxWidth > 800;
                                        
                                        return Card(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10)
                                          ),
                                          elevation: 4,
                                          child: InkWell(
                                            onTap: () {
                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: (context) => RecipeDetailScreen(
                                                    recipe: _featuredRecipe.value,
                                                  )
                                                )
                                              ).then((value) {
                                                if (value == true) {
                                                  initLDB();
                                                }
                                              });
                                            },
                                            child: Container(
                                              padding: EdgeInsets.all(10),
                                              child: isLargeScreen
                                                  ? Row(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Expanded(
                                                          flex: 2,
                                                          child: _buildFeaturedImage(),
                                                        ),
                                                        SizedBox(width: 20),
                                                        Expanded(
                                                          flex: 3,
                                                          child: _buildFeaturedContent(),
                                                        ),
                                                      ],
                                                    )
                                                  : Column(
                                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                                      children: [
                                                        AspectRatio(
                                                          aspectRatio: 16 / 9,
                                                          child: _buildFeaturedImage(),
                                                        ),
                                                        SizedBox(height: 10),
                                                        _buildFeaturedContent(),
                                                      ],
                                                    ),
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                              ],
                            );
                          }
                          return SizedBox();
                        },
                      ),
                      Container(
                        padding: const EdgeInsets.fromLTRB(10, 10, 10, 20),
                        margin: const EdgeInsets.fromLTRB(0, 0, 0, 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10)
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              "List of Recipes",
                              style: TextStyle(
                                fontSize: 20,
                              ),
                            ),
                            ValueListenableBuilder(
                              valueListenable: _filteredRecipes,
                              builder: (context, value, child) {
                                return LayoutBuilder(
                                  builder: (context, constraints) {
                                    int crossAxisCount = constraints.maxWidth > 800 ? 4 : 2;
                                    double childAspectRatio = constraints.maxWidth > 800 ? 0.85 : 0.75;
                                    return GridView.builder(
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: crossAxisCount,
                                        childAspectRatio: childAspectRatio,
                                        crossAxisSpacing: 10,
                                        mainAxisSpacing: 10
                                      ),
                                      itemCount: value.length, 
                                      itemBuilder: (context, index) {
                                        final recipe = value[index];
                                        return Card(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10)
                                          ),
                                          elevation: 4,
                                          child: InkWell(
                                            onTap: () {
                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: (context) => RecipeDetailScreen(
                                                    recipe: recipe,
                                                  )
                                                )
                                              ).then((value) {
                                                if (value == true) {
                                                  initLDB();
                                                }
                                              });
                                            },
                                            child: Container(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                                children: [
                                                  Expanded(
                                                    flex: 2,
                                                    child: Container(
                                                      padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
                                                      child: ClipRRect(
                                                        borderRadius: BorderRadius.vertical(
                                                          top: Radius.circular(10)
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
                                                  ),
                                                  Expanded(
                                                    flex: 2,
                                                    child: Padding(
                                                      padding: const EdgeInsets.all(8.0),
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            "${recipe['name']?.toString().toUpperCase() ?? '-'}",
                                                            maxLines: 1,
                                                            overflow: TextOverflow.ellipsis,
                                                            style: TextStyle(
                                                              fontSize: 14,
                                                              fontWeight: FontWeight.bold,
                                                              color: const Color.fromARGB(255, 98, 124, 119)
                                                            ),
                                                          ),
                                                          Text(
                                                            "${recipe['type']?.toString().toTitleCase() ?? '-'}",
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                              color: Colors.grey,
                                                            ),
                                                          ),
                                                          Container(
                                                            padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                                                            margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                                                            decoration: BoxDecoration(
                                                              color: const Color.fromARGB(255, 98, 124, 119),
                                                              borderRadius: BorderRadius.circular(10)
                                                            ),
                                                            child: Text(
                                                              "${recipe['source']?.toString().toUpperCase() ?? "-"}",
                                                              style: TextStyle(
                                                                fontSize: 10,
                                                                fontWeight: FontWeight.normal,
                                                                color: Colors.white
                                                              ),
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                );
                              },
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          );
        },
      )
    );
  }

  String _formatIngredients(Map<String, dynamic> recipe) {
    final ingredients = [
      recipe['strIngredient1']?.toString(),
      recipe['strIngredient2']?.toString(),
      recipe['strIngredient3']?.toString(),
      recipe['strIngredient4']?.toString(),
    ];
    
    // Filter out null or empty ingredients and format them
    final validIngredients = ingredients
        .where((ing) => ing != null && ing.isNotEmpty)
        .map((ing) => ing!.toTitleCase())
        .toList();
        
    return validIngredients.isEmpty ? '-' : validIngredients.join(', ');
  }

  Widget _buildFeaturedImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        decoration: BoxDecoration(),
        child: Builder(
          builder: (context) {
            try {
              if (kIsWeb) {
                return Image.network(
                  _featuredRecipe.value['imageLink'],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(Icons.food_bank);
                  },
                );
              } else {
                return Image.file(
                  File('${_featuredRecipe.value['imagePath']}'),
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
    );
  }

  Widget _buildFeaturedContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                "${_featuredRecipe.value['name']?.toString().toUpperCase() ?? "-"}",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(255, 98, 124, 119)
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
              margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 98, 124, 119),
                borderRadius: BorderRadius.circular(10)
              ),
              child: Text(
                "${_featuredRecipe.value['source']?.toString().toUpperCase() ?? "-"}",
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.normal,
                  color: Colors.white
                ),
              ),
            )
          ],
        ),
        Text(
          "${_featuredRecipe.value['type']?.toString().toTitleCase() ?? "-"}",
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.normal,
            color: Colors.grey
          ),
        ),
        Text(
          "Main Ingredient:",
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.normal
          ),
        ),
        Text(
          _formatIngredients(jsonDecode(_featuredRecipe.value['datasource'])),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.normal
          ),
        ),
      ],
    );
  }
}