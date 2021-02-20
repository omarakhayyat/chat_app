import 'package:chat_app/helper/authenticate.dart';
import 'package:chat_app/helper/constant.dart';
import 'package:chat_app/helper/sharedPrefFunctions.dart';
import 'package:chat_app/views/chat_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

bool loggedIn;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await SharedPrefFunctions().getUserLoggedInSharedPref().then((value) {
    if (value == null) {
      loggedIn = false;
    } else {
      loggedIn = value;
    }
  });
  if (loggedIn) {
    await SharedPrefFunctions()
        .getUserNameSharedPref()
        .then((value) => Constant.userName = value);
  }

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: loggedIn ? ChatScreen() : Authenticate(),
    );
  }
}
