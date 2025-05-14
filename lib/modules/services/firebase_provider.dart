import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class FirebaseProvider extends ChangeNotifier {
  FirebaseProvider() {
    _startListening();
  }

  String _userName = '';
  String get userName => _userName;
  final User? currentUser = FirebaseAuth.instance.currentUser;

  _startListening() {
    _userName = currentUser!.displayName.toString();

    notifyListeners();
  }

  changeName(String name) async {
    try {
      await currentUser?.updateDisplayName(name);
      _userName = name;
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to update name: $e');
    }
  }
}