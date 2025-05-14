import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLanguage extends ChangeNotifier {
  Locale _appLocale = const Locale('id');
  Locale get appLocal => _appLocale;

  void changeLanguage(Locale type) async {
    var prefs = await SharedPreferences.getInstance();

    // If same language selected, return nothing
    if (_appLocale == type) {
      return;
    }

    if (type == const Locale('my')) {
      _appLocale = type;
      await prefs.setString('languageLocale', 'my');
      print('Bahasa Malaysia Selected | type ${type.toString()}');
    } else {
      _appLocale = type;
      await prefs.setString('languageLocale', 'my');
      print('Bahasa Malaysia Selected | type ${type.toString()}');
    }
  }
}