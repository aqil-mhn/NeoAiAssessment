import 'dart:developer';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:neoai_assessment/configs/app_theme.dart';
import 'package:neoai_assessment/modules/services/firebase_auth_services.dart';
import 'package:provider/provider.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  FirebaseAuthServices auth = FirebaseAuthServices();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final ValueNotifier<bool> _hidePassword = ValueNotifier<bool>(true);
  final ValueNotifier<bool> _hideConfirmPassword = ValueNotifier<bool>(true);

  void handleSignUp(String email, String password) async {
    final user = await auth.signUp(
      email.trim(),
      password.trim()
    );

    if (user != null) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(milliseconds: 600),
          content: Text(
            "Sign Up Successful as ${user.email}"
          ),
          padding: EdgeInsets.fromLTRB(20, 10, 10, 10),
          margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50)
                ),
        ),
      );

      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(milliseconds: 600),
          content: Text(
            "Sign Up failed. Please try again"
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
    final appTheme = Provider.of<AppTheme>(context);
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 245, 243, 241),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          "Sign Up",
          style: TextStyle(
            fontSize: 30
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(30, 70, 30, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Image.asset(
                "assets/images/recipe.png",
                width: 200,
                height: 200,
              ),
              SizedBox(
                height: 20,
              ),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter email";
                        }
                        if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(value)) {
                          return "Enter a valid email address";
                        }

                        return null;
                      },
                      controller: emailController,
                      decoration: InputDecoration(
                        // hintText: "Username",
                        labelText: "Email",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)
                        )
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    ValueListenableBuilder(
                      valueListenable: _hidePassword,
                      builder: (context, value, child) {
                        return TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter password";
                            }

                            return null;
                          },
                          controller: passwordController,
                          obscureText:  _hidePassword.value,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            suffixIcon: IconButton(
                              onPressed: () {
                                _hidePassword.value = !_hidePassword.value;
                              },
                              icon: Icon(
                                _hidePassword.value ? Icons.visibility_off_outlined : Icons.visibility_outlined 
                              ),
                            ),
                            labelText: "Password",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)
                            )
                          ),
                        );
                      },
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    ValueListenableBuilder(
                      valueListenable: _hideConfirmPassword,
                      builder: (context, value, child) {
                        return TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please retype the password";
                            }
                            if (value != passwordController.text) {
                              return "Must be same as password";
                            }

                            return null;
                          },
                          controller: confirmPasswordController,
                          obscureText: _hideConfirmPassword.value,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            labelText: "Confirm Password",
                            suffixIcon: IconButton(
                              onPressed: () {
                                _hideConfirmPassword.value = !_hideConfirmPassword.value;
                              },
                              icon: Icon(
                                _hideConfirmPassword.value ? Icons.visibility_off_outlined : Icons.visibility_outlined
                              ),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)
                            )
                          ),
                        );
                      },
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    TextButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          handleSignUp(emailController.text, passwordController.text);
                        }
                      },
                      style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(const Color.fromARGB(255, 98, 124, 119)),
                        foregroundColor: WidgetStatePropertyAll(Colors.white)
                      ),
                      child: Text(
                        "Sign Up"
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}