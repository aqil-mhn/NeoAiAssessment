import 'package:flutter/material.dart';
import 'package:neoai_assessment/modules/services/firebase_provider.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';

extension ContextExtensions on BuildContext {
  static OverlayEntry? _overlayEntry;
  FirebaseProvider get firebaseProvider => Provider.of<FirebaseProvider>(this, listen: false);

  void showOverlaySnackBar(BuildContext context, String message) {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: MediaQuery.of(context).padding.bottom + 15,
        left: 16,
        right: 16,
        child: Material(
          elevation: 6.0,
          borderRadius: BorderRadius.circular(8),
          color: Colors.black87,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    message,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.white, size: 16),
                  onPressed: () {
                    _overlayEntry?.remove();
                    _overlayEntry = null;
                  },
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // Show the overlay entry
    Overlay.of(context).insert(_overlayEntry!);

    // Auto-dismiss after a duration
    Future.delayed(Duration(seconds: 3)).then((_) {
      if (_overlayEntry != null) {
        _overlayEntry!.remove();
        _overlayEntry = null;
      }
    });
  }
}