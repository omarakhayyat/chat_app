import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget appBarWidget(BuildContext context) {
  return AppBar(
    title: Text('Chat App'),
  );
}

InputDecoration textFieldInputDecoration(String hintText) {
  return InputDecoration(
    hintText: hintText,
    focusedBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: Colors.black),
    ),
    enabledBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: Colors.black),
    ),
  );
}
