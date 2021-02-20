import 'package:chat_app/helper/constant.dart';
import 'package:chat_app/helper/sharedPrefFunctions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fluttertoast/fluttertoast.dart';

class DatabaseMethods {
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging();
  final FirebaseFirestore _instance = FirebaseFirestore.instance;

  Future getUser(String username) async {
    return await _instance
        .collection('users')
        .where("username", isEqualTo: username)
        .get();
  }

  Future getUserByEmail(String userEmail) async {
    return await _instance
        .collection('users')
        .where("email", isEqualTo: userEmail)
        .get();
  }

  Future getUserByUID(String uID) async {
    return await _instance
        .collection('users')
        .where("UID", isEqualTo: uID)
        .get();
  }

  postUser(String username, String email, String uid) {
    _instance.collection("users").add(
      {"username": username, "email": email, "UID": uid},
    );
  }

  updateChattingWith(String userName) async {
    String _docId = await _instance
        .collection('users')
        .where("username", isEqualTo: Constant.userName)
        .get()
        .then((value) => value.docs.first.id);

    _instance
        .collection('users')
        .doc(_docId)
        .set({'chattingWith': userName}, SetOptions(merge: true));
  }

  createChatRoom(String chatRoomID, chatRoomMap) {
    _instance
        .collection("chatRoom")
        .doc(chatRoomID)
        .set(chatRoomMap)
        .catchError((e) {
      print(e.toString());
    });
  }

  postConversationMessages(String chatRoomId, messageMap) {
    _instance
        .collection("chatRoom")
        .doc(chatRoomId)
        .collection("chats")
        .add(messageMap)
        .catchError((e) => print(e.toString()));
  }

  getConversationMessages(String chatRoomId) async {
    return await _instance
        .collection("chatRoom")
        .doc(chatRoomId)
        .collection("chats")
        .orderBy("time", descending: false)
        .snapshots();
  }

  getChatRooms(String username) async {
    return await _instance
        .collection("chatRoom")
        .where("users", arrayContains: username)
        .snapshots();
  }

  savePushToken() async {
    String _docId = await _instance
        .collection('users')
        .where("UID",
            isEqualTo: await SharedPrefFunctions().getUserIDSharedPref())
        .get()
        .then((value) => value.docs.first.id);

    firebaseMessaging.getToken().then((token) {
      print('token: $token');
      FirebaseFirestore.instance
          .collection('users')
          .doc(_docId)
          .set({'pushToken': token}, SetOptions(merge: true));
    }).catchError((err) {
      Fluttertoast.showToast(msg: err.message.toString());
    });
  }
}
