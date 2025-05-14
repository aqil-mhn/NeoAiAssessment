import 'package:flutter/material.dart';
import 'package:neoai_assessment/modules/services/firebase_provider.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';

extension ContextExtensions on BuildContext {
  FirebaseProvider get firebaseProvider => Provider.of<FirebaseProvider>(this, listen: false);
}