import 'package:flutter/material.dart';

class AppTheme extends ChangeNotifier {
  ThemeData _themeData;
  AppTheme(this._themeData);
  ThemeData get themeData => _themeData;

  static ThemeData myTheme1 = ThemeData(
    primaryColor: Color.fromARGB(255, 241, 255, 250),
    primaryColorDark: Color.fromARGB(255, 103, 192, 126),
    primaryColorLight: Color.fromARGB(255, 91, 205, 220),
    colorScheme: ColorScheme.light(surface: Color(0xFF21996c)),
    highlightColor: Color.fromARGB(255, 202, 224, 217),
    secondaryHeaderColor: Color.fromARGB(255, 49, 123, 98),
    shadowColor: Color.fromARGB(255, 173, 243, 219),
    indicatorColor: Color.fromARGB(255, 35, 95, 75),
  );

  static ThemeData myTheme3 = ThemeData(
    primaryColor: Color.fromRGBO(226, 232, 240, 1),
    primaryColorDark: Color(0xFF4A6FD8),
    primaryColorLight: Color(0xFF7F5ABD),
    colorScheme: ColorScheme.light(
      surface: Color(0xFF4A6FD8),
    ),
    highlightColor: Color.fromRGBO(193, 178, 255, 1),
    secondaryHeaderColor: Color.fromARGB(255, 117, 118, 118),
    shadowColor: Color.fromRGBO(246, 252, 255, 1),
    indicatorColor: Color.fromARGB(255, 44, 94, 168),
  );

  void setThemeData(ThemeData themeData) {
    _themeData = themeData;
    notifyListeners();
  }
}