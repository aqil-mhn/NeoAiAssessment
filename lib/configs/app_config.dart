import 'package:flutter/material.dart';
import 'package:neoai_assessment/configs/app.dart';
import 'package:neoai_assessment/configs/app_language.dart';
import 'package:neoai_assessment/configs/app_theme.dart';
import 'package:neoai_assessment/modules/services/firebase_provider.dart';
import 'package:provider/provider.dart';

enum AppEnvironment {
  developemnt,
  production
}

class AppConfig {
  AppConfig({
    required this.appName,
    required this.environment
  });

  final String appName;
  final AppEnvironment environment;

  ThemeData _customLightTheme() {
    return ThemeData.light().copyWith(
      // Customize your theme properties here
      primaryColor: Color.fromRGBO(226, 232, 240, 1),
      primaryColorDark: Color(0xFF4A6FD8),
      primaryColorLight: Color(0xFF7F5ABD),
      colorScheme: ColorScheme.light(
        surface: Color(0xFF4A6FD8),
      ),
      highlightColor: Color.fromRGBO(193, 178, 255, 1),
      secondaryHeaderColor: Color.fromARGB(255, 117, 118, 118),
      shadowColor: Color.fromRGBO(246, 252, 255, 1),
      indicatorColor: Color.fromARGB(255, 35, 77, 95),
      // Add any other customizations you need
    );
  }

  Future run() async {
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (context) => AppTheme(
              _customLightTheme()
            )
          ),
          ChangeNotifierProvider(
            create: (context) => AppLanguage()
          ),
          ChangeNotifierProvider(
            create: (context) => FirebaseProvider(),
          )
        ],
        child: App(
          appName: appName
        ),
      )
    );
  }
}