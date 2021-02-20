import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget AppBarWidget(BuildContext context) {
  return AppBar(
    title: Text('Chat App'),
  );
}

InputDecoration TextFieldInputDecoration(String hintText) {
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
