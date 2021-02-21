import 'dart:async';

import 'package:chat_app/services/auth.dart';
import 'package:chat_app/widgets/widget.dart';
import 'package:flutter/material.dart';

class ForgotPassword extends StatefulWidget {
  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final TextEditingController _emailControl = TextEditingController();

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final formKey = GlobalKey<FormState>();

  bool isLoading = false;

  AuthMethods authMethods = AuthMethods();

  resetPassword() async {
    if (formKey.currentState.validate()) {
      setState(() {
        isLoading = true;
      });

      await authMethods.resetPass(_emailControl.text).then(
        (value) {
          setState(() {
            isLoading = false;
          });

          value == null
              ? print("email has been sent")
              : print("Something wrong happened");

          if (value == null) {
            _scaffoldKey.currentState.showSnackBar(
              SnackBar(
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.green[800],
                content: Row(
                  children: [
                    Icon(
                      Icons.check_circle_outline_rounded,
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Text(
                      'Email has been sent to reset password',
                      style: TextStyle(fontSize: 15),
                    ),
                  ],
                ),
                duration: Duration(seconds: 3),
              ),
            );
            Timer(Duration(seconds: 3), () {
              Navigator.pop(context);
            });
          } else {
            _scaffoldKey.currentState.showSnackBar(
              SnackBar(
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.red[800],
                content: Row(
                  children: [
                    Icon(Icons.cancel_outlined),
                    SizedBox(
                      width: 8,
                    ),
                    Flexible(
                      child: Text(
                        value,
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                  ],
                ),
                duration: Duration(seconds: 3),
              ),
            );
          }

          // Navigator.pop(context);
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
      appBar: appBarWidget(context),
      body: Container(
        child: Stack(
          children: [
            Column(
              children: [
                SizedBox(
                  height: 100,
                ),
                Text(
                  "Reset Password",
                  style: TextStyle(fontSize: 40),
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  "Enter your email address below \n to reset your password",
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Form(
                    key: formKey,
                    child: TextFormField(
                      controller: _emailControl,
                      decoration: textFieldInputDecoration("Email"),
                      validator: (value) {
                        return RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$")
                                .hasMatch(value)
                            ? null
                            : "Please Enter a valid email address";
                      },
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: () {
                      resetPassword();
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
                        'Reset Password',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
