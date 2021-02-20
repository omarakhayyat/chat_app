import 'package:chat_app/helper/constant.dart';
import 'package:chat_app/helper/sharedPrefFunctions.dart';
import 'package:chat_app/services/auth.dart';
import 'package:chat_app/services/database.dart';
import 'package:chat_app/views/forgot_password.dart';
import 'package:chat_app/widgets/widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'chat_screen.dart';

//TODO: googleSignIn is ready, we need to test it
//we will add/create like signMeIn method

//TODO: after finishing this part, I will add authenticate with Phone Number

class SignIn extends StatefulWidget {
  final Function toggle;
  SignIn(this.toggle);

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final formKey = GlobalKey<FormState>();
  bool isLoading = false;
  QuerySnapshot _query;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  TextEditingController emailController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();

  FocusNode myFocusNode = FocusNode();

  AuthMethods authMethods = AuthMethods();
  SharedPrefFunctions sharedPrefFunctions = SharedPrefFunctions();
  DatabaseMethods databaseMethods = DatabaseMethods();

  Future signMeIn() async {
    if (formKey.currentState.validate()) {
      setState(() {
        isLoading = true;
      });

      authMethods
          .signInWithEmailAndPassword(
              emailController.text, passwordController.text)
          .then(
        (value) {
          if (value != null && value.runtimeType != String) {
            databaseMethods.getUserByUID(value.uid).then(
              (value) async {
                _query = value;
                await sharedPrefFunctions.setUserLoggedInSharedPref(true);
                await sharedPrefFunctions
                    .setUserEmailSharedPref(_query.docs[0].data()['email']);
                await sharedPrefFunctions
                    .setUserIDSharedPref(_query.docs[0].data()['UID']);
                await sharedPrefFunctions
                    .setUserNameSharedPref(_query.docs[0].data()['username'])
                    .then(
                      (value) => {
                        Constant.userName = _query.docs[0].data()['username'],
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatScreen(),
                          ),
                        )
                      },
                    );
              },
            );
          } else {
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
                      "Sign In error",
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
            //print(value);
            // _scaffoldKey.currentState.showSnackBar(
            //   SnackBar(
            //     content: SnackBar(
            //       behavior: SnackBarBehavior.floating,
            //       backgroundColor: Colors.red[800],
            //       content: Row(
            //         children: [
            //           Icon(Icons.cancel_outlined),
            //           SizedBox(
            //             width: 8,
            //           ),
            //           Text(
            //             "aaaaa",
            //             style: TextStyle(fontSize: 15),
            //           ),
            //         ],
            //       ),
            //       duration: Duration(seconds: 3),
            //     ),
            //   ),
            // );
            //return value;
          }
        },
      );
    }
  }

  signInGoogle() {
    authMethods.googleSignIn().then((value) async => {
          if (value != null)
            {
              databaseMethods.getUserByEmail(value.email).then((user) {
                if (user == null) {
                  databaseMethods.postUser(
                      value.displayName, value.email, value.uid);
                }
              }),
              await sharedPrefFunctions.setUserLoggedInSharedPref(true),
              await sharedPrefFunctions.setUserEmailSharedPref(value.email),
              Constant.userName = value.displayName,
              await sharedPrefFunctions
                  .setUserNameSharedPref(value.displayName)
                  .then(
                    (value) => {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(),
                        ),
                      ),
                    },
                  ),
            }
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBarWidget(context),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            Form(
              key: formKey,
              child: Column(
                children: [
                  TextFormField(
                    focusNode: myFocusNode,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      return RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$")
                              .hasMatch(value)
                          ? null
                          : "Please Enter a valid email address";
                    },
                    controller: emailController,
                    decoration: TextFieldInputDecoration('Email'),
                  ),
                  TextFormField(
                    obscureText: true,
                    validator: (value) {
                      return value.length > 6
                          ? null
                          : "Please enter a password with minimum 6 characters";
                    },
                    controller: passwordController,
                    decoration: TextFieldInputDecoration('Password'),
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
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                alignment: Alignment.bottomRight,
              ),
            ),
            SizedBox(
              height: 8,
            ),
            GestureDetector(
              onTap: () async {
                FocusManager.instance.primaryFocus.unfocus();
                signMeIn();
              },
              child: Container(
                alignment: Alignment.center,
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [const Color(0xff007ef4), const Color(0xff2a75bc)],
                  ),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text('Sign In'),
              ),
            ),
            SizedBox(
              height: 16,
            ),
            GestureDetector(
              onTap: () {
                signInGoogle();
              },
              child: Container(
                alignment: Alignment.center,
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  'Sign In with Google',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            SizedBox(
              height: 16,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Don't have account? "),
                GestureDetector(
                  onTap: () {
                    widget.toggle();
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      "Register now",
                      style: TextStyle(decoration: TextDecoration.underline),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
