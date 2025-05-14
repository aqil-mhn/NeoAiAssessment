import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:neoai_assessment/configs/app_theme.dart';
import 'package:neoai_assessment/modules/home_screen.dart';
import 'package:neoai_assessment/modules/logins/signup_screen.dart';
import 'package:neoai_assessment/modules/services/firebase_auth_services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  FirebaseAuthServices auth = FirebaseAuthServices();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final ValueNotifier<bool> _hidePassword = ValueNotifier<bool>(true);
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);

  Future<void> handleLogin(String email, String password) async {
    final user = await auth.logIn(
      email.trim(),
      password.trim()
    );

    if (user != null) {
      var prefs = await SharedPreferences.getInstance();
      prefs.setString("userUID", user.uid);
      prefs.setBool("isUserLoggedIn", true);

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(milliseconds: 600),
          content: Text(
            "Login Successful as ${user.email}"
          ),
          padding: EdgeInsets.fromLTRB(20, 10, 10, 10),
          margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50)
                ),
        ),
      );

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(milliseconds: 600),
          content: Text(
            "Wrong email or password. Please try again"
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
          "Login",
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
                  children: [
                    TextFormField(
                      controller: emailController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter email";
                        }
                        if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(value)) {
                          return "Enter a valid email address";
                        }
                    
                        return null;
                      },
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
                          controller: passwordController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter password";
                            }

                            return null;
                          },
                          obscureText: _hidePassword.value,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            labelText: "Password",
                            suffixIcon: IconButton(
                              onPressed: () {
                                _hidePassword.value = !_hidePassword.value;
                              },
                              icon: Icon(
                                _hidePassword.value ? Icons.visibility_off_outlined : Icons.visibility_outlined 
                              ),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)
                            )
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  text: "Don't have an account? ",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16
                  ),
                  children: [
                    TextSpan(
                      text: "Sign up",
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 16
                      ),
                      recognizer: TapGestureRecognizer()..onTap = () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const SignupScreen(),
                          ),
                        );
                      }
                    )
                  ]
                ),
              ),
              SizedBox(
                height: 30,
              ),
              ValueListenableBuilder(
                valueListenable: isLoading,
                builder: (context, value, child) {
                  return TextButton(
                    onPressed: value ? null : () async {
                      if (_formKey.currentState!.validate()) {
                        isLoading.value = true;
                        await handleLogin(emailController.text, passwordController.text);
                        isLoading.value = false;
                      }
                    },
                    style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(const Color.fromARGB(255, 98, 124, 119)),
                      foregroundColor: WidgetStatePropertyAll(Colors.white)
                    ),
                    child: value ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    ) : Text(
                      "Login"
                    ),
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}