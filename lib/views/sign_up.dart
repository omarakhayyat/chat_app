import 'package:chat_app/helper/sharedPrefFunctions.dart';
import 'package:chat_app/services/auth.dart';
import 'package:chat_app/services/database.dart';
import 'package:chat_app/views/chat_screen.dart';
import 'package:chat_app/widgets/widget.dart';
import 'package:flutter/material.dart';

import 'forgot_password.dart';

class SignUp extends StatefulWidget {
  final Function toggle;
  SignUp(this.toggle);

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final formKey = GlobalKey<FormState>();
  TextEditingController userNameController = new TextEditingController();
  TextEditingController emailController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();

  AuthMethods authMethods = AuthMethods();
  DatabaseMethods databaseMethods = DatabaseMethods();
  SharedPrefFunctions sharedPrefFunctions = SharedPrefFunctions();

  bool isLoading = false;
  signMeUp() {
    if (formKey.currentState.validate()) {
      setState(() {
        isLoading = true;
      });

      authMethods
          .signUpWithEmailAndPassword(
              emailController.text, passwordController.text)
          .then((value) {
        if (value != null && value.runtimeType != String) {
          databaseMethods.postUser(
              userNameController.text, value.email, value.uid);
          sharedPrefFunctions.setUserLoggedInSharedPref(true);
          sharedPrefFunctions.setUserEmailSharedPref(emailController.text);
          sharedPrefFunctions.setUserNameSharedPref(userNameController.text);
          sharedPrefFunctions.setUserIDSharedPref(value.uid);

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(),
            ),
          );
        } else {
          setState(() {
            isLoading = false;
          });
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10),
                  ),
                ),
                title: Center(
                  child: Text(
                    "Sign Up error",
                    style: TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
                content: Text(value),
                actions: [
                  FlatButton(
                    textColor: Colors.red,
                    child: Text('Ok'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  )
                ],
              );
            },
          );
        }
      }).catchError((e) {
        print("---------ERROR--------- " + e);
      });

      //databaseMethods.postUser(userNameController.text, emailController.text);

      // sharedPrefFunctions.setUserLoggedInSharedPref(true);
      // sharedPrefFunctions.setUserEmailSharedPref(emailController.text);
      // sharedPrefFunctions.setUserNameSharedPref(userNameController.text);

      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) => ChatScreen(),
      //   ),
      // );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(context),
      body: isLoading
          ? Container(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          : SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    Form(
                      key: formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            validator: (value) {
                              return value.isEmpty
                                  ? "Please enter username"
                                  : null;
                            },
                            controller: userNameController,
                            decoration: textFieldInputDecoration('Username'),
                          ),
                          TextFormField(
                            validator: (value) {
                              return RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$")
                                      .hasMatch(value)
                                  ? null
                                  : "Please Enter a valid email address";
                            },
                            controller: emailController,
                            decoration: textFieldInputDecoration('Email'),
                          ),
                          TextFormField(
                            obscureText: true,
                            validator: (value) {
                              return value.length > 6
                                  ? null
                                  : "Please enter a password with minimum 6 characters";
                            },
                            controller: passwordController,
                            decoration: textFieldInputDecoration('Password'),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ForgotPassword(),
                            ));
                        // authMethods.resetPass(emailController.text);
                      },
                      child: Container(
                        child: Text('Forgot Password?'),
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        alignment: Alignment.bottomRight,
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    GestureDetector(
                      onTap: () {
                        signMeUp();
                      },
                      child: Container(
                        alignment: Alignment.center,
                        width: MediaQuery.of(context).size.width,
                        padding: EdgeInsets.symmetric(vertical: 20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xff007ef4),
                              const Color(0xff2a75bc)
                            ],
                          ),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text('Sign Up'),
                      ),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Container(
                      alignment: Alignment.center,
                      width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        'Sign Up with Google',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Already have an account? "),
                        GestureDetector(
                          onTap: () {
                            widget.toggle();
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              "Sign in now",
                              style: TextStyle(
                                  decoration: TextDecoration.underline),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
