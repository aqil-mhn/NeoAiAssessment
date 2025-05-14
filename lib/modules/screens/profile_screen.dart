import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:neoai_assessment/configs/context_extensions.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  final TextEditingController _nameController = TextEditingController();
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = context.firebaseProvider.userName ?? 'User';
  }

  Future<void> _updateDisplayName() async {
    if (_nameController.text.trim().isEmpty) return;
    try {
      await context.firebaseProvider.changeName(_nameController.text.trim());

      setState(() {
        isEditing = false;
      });

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(milliseconds: 600),
          content: Text(
            "Profile updated successfully!"
          ),
          padding: EdgeInsets.fromLTRB(20, 10, 10, 10),
          margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50)
                ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(milliseconds: 600),
          content: Text(
            "Failed to update profile"
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 98, 124, 119),
        title: Text(
          'Profile',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(20),
              color: const Color.fromARGB(255, 98, 124, 119),
              child: Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.person,
                        size: 50,
                        color: const Color.fromARGB(255, 98, 124, 119),
                      ),
                    ),
                    SizedBox(height: 20),
                    if (isEditing)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _nameController,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                              ),
                              decoration: InputDecoration(
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.check, color: Colors.white),
                            onPressed: _updateDisplayName,
                          ),
                        ],
                      )
                    else
                      ListenableBuilder(
                        listenable: context.firebaseProvider,
                        builder: (context, child) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Text(
                                  context.firebaseProvider.userName ?? 'User',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.white),
                                onPressed: () => setState(() => isEditing = true),
                              ),
                            ],
                          );
                        },
                      )
                  ],
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.email),
                    title: Text('Email'),
                    subtitle: Text(currentUser?.email ?? 'No email'),
                  ),
                  ListTile(
                    leading: Icon(Icons.access_time),
                    title: Text('Account Created'),
                    subtitle: Text(
                      DateFormat('dd MMM yyyy, h:mm a').format(currentUser!.metadata.creationTime!.toLocal()) ?? 'Unknown',
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.verified_user),
                    title: Text('Email Verified'),
                    subtitle: Text(
                      currentUser?.emailVerified ?? false ? 'Yes' : 'No',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}