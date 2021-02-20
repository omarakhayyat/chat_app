import 'package:chat_app/helper/constant.dart';
import 'package:chat_app/helper/sharedPrefFunctions.dart';
import 'package:chat_app/services/database.dart';
import 'package:chat_app/views/conversation.dart';
import 'package:chat_app/widgets/widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController searchTextController = TextEditingController();

  DatabaseMethods databaseMethods = DatabaseMethods();
  QuerySnapshot searchSnapshot;
  SharedPrefFunctions sharedPrefFunctions = SharedPrefFunctions();

  search() {
    databaseMethods.getUser(searchTextController.text).then(
      (value) {
        setState(() {
          searchSnapshot = value;
        });
      },
    );
  }

  createChat(String username) async {
    Constant.userName = await sharedPrefFunctions.getUserNameSharedPref();
    if (username != Constant.userName) {
      List<String> users = [username, Constant.userName];
      String chatRoomID = getChatRoomId(username, Constant.userName);

      Map<String, dynamic> chatRoomMap = {
        "users": users,
        "chatRoomId": chatRoomID,
      };
      databaseMethods.createChatRoom(chatRoomID, chatRoomMap);

      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ConversationScreen(chatRoomID, username)));
    } else {
      print("You Cannot Send message to your self");
    }
  }

  Widget searchList() {
    return searchSnapshot != null
        ? ListView.builder(
            shrinkWrap: true,
            itemCount: searchSnapshot.docs.length,
            itemBuilder: (context, index) {
              return SearchTile(
                userEmail: searchSnapshot.docs[index].data()['email'],
                userName: searchSnapshot.docs[index].data()['username'],
              );
            },
          )
        : Container(
            color: Colors.red,
          );
  }

  Widget SearchTile({String userName, String userEmail}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(userName),
              Text(userEmail),
            ],
          ),
          Spacer(),
          GestureDetector(
            onTap: () {
              createChat(userName);
            },
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.blue, borderRadius: BorderRadius.circular(10)),
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Text('Message'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(context),
      body: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: searchTextController,
                      decoration: InputDecoration(
                        hintText: 'Search username',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      search();
                    },
                    child: Icon(Icons.search),
                  ),
                ],
              ),
            ),
            searchList(),
          ],
        ),
      ),
    );
  }
}

getChatRoomId(String a, String b) {
  if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
    return "$b\_$a";
  } else {
    return "$a\_$b";
  }
}
