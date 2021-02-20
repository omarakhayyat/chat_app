import 'package:chat_app/helper/constant.dart';
import 'package:chat_app/services/database.dart';
import 'package:chat_app/widgets/emoji_picker_widget.dart';
import 'package:chat_app/widgets/input_widget.dart';
import 'package:chat_app/widgets/widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker/emoji_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:intl/intl.dart';

class ConversationScreen extends StatefulWidget {
  final String chatRoomId;
  final String chatWith;
  ConversationScreen(this.chatRoomId, this.chatWith);

  @override
  _ConversationScreenState createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  TextEditingController msgController = TextEditingController();
  KeyboardVisibilityController keyboardVisibilityController =
      KeyboardVisibilityController();
  ScrollController scrollController = ScrollController();
  DatabaseMethods databaseMethods = DatabaseMethods();
  Stream chatMsgStream;
  final messages = <String>[];
  bool isEmojiVisible = false;
  bool isKeyboardVisible = false;

  Widget chatMessageList() {
    return StreamBuilder(
        stream: chatMsgStream,
        builder: (context, snapshot) {
          return snapshot.hasData
              ? ListView.builder(
                  padding: EdgeInsets.only(bottom: 50),
                  physics: BouncingScrollPhysics(),
                  //reverse: false,
                  shrinkWrap: true,
                  controller: scrollController,
                  itemCount: snapshot.data.documents.length,
                  itemBuilder: (context, index) {
                    return MessageTile(
                      snapshot.data.documents[index]["message"],
                      snapshot.data.documents[index]["sendBy"] ==
                          Constant.userName,
                      snapshot.data.documents[index]["time"],
                      // scrollController
                    );
                  },
                )
              : Container();
        });
  }

  sendMessage() {
    if (msgController.text.isNotEmpty) {
      Map<String, dynamic> messageMap = {
        "message": msgController.text,
        "sendBy": Constant.userName,
        "sendTo": widget.chatWith,
        "time": DateTime.now().millisecondsSinceEpoch,
      };
      databaseMethods.postConversationMessages(widget.chatRoomId, messageMap);
      // msgController.clear();
    }
  }

  @override
  void initState() {
    databaseMethods.getConversationMessages(widget.chatRoomId).then((value) {
      setState(() {
        chatMsgStream = value;
      });
    });

    databaseMethods.updateChattingWith(widget.chatWith);

    keyboardVisibilityController.onChange.listen((bool isKeyboardVisible) {
      if (mounted) {
        setState(() {
          this.isKeyboardVisible = isKeyboardVisible;
        });

        if (isKeyboardVisible && isEmojiVisible) {
          setState(() {
            isEmojiVisible = false;
          });
        }
      } else
        return;
    });

    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    keyboardVisibilityController.onChange
        .listen((bool isKeyboardVisible) {})
        .cancel();

    databaseMethods.updateChattingWith(null);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(context),
      body: WillPopScope(
        onWillPop: onBackPress,
        child: Column(
          children: [
            Expanded(child: chatMessageList()),
            // Container(
            //   alignment: Alignment.bottomCenter,
            //   child: Container(
            //     decoration: BoxDecoration(
            //       color: Colors.amber,
            //       borderRadius: BorderRadius.circular(30),
            //     ),
            //     //color: Colors.grey,
            //     padding: EdgeInsets.symmetric(horizontal: 18, vertical: 5),
            //     child: Row(
            //       children: [
            //         // Expanded(
            //         //   //width: MediaQuery.of(context).size.width,
            //         //   child: EmojiPicker(
            //         //     onEmojiSelected: (emoji, category) {
            //         //       print(emoji);
            //         //     },
            //         //     //rows: 7,
            //         //   ),
            //         // ),
            //         Expanded(
            //           child: TextField(
            //             controller: msgController,
            //             decoration: InputDecoration(
            //                 hintText: 'Type a message',
            //                 border: InputBorder.none),
            //           ),
            //         ),
            //         GestureDetector(
            //           onTap: () {
            //             sendMessage();
            //           },
            //           child: Container(
            //             child: Icon(Icons.send),
            //           ),
            //         ),
            //       ],
            //     ),
            //   ),
            // ),

            Container(
              alignment: Alignment.bottomCenter,
              child: InputWidget(
                onBlurred: toggleEmojiKeyboard,
                controller: msgController,
                isEmojiVisible: isEmojiVisible,
                isKeyboardVisible: isKeyboardVisible,
                onSentMessage: (message) => setState(() {
                  messages.insert(0, message);
                  sendMessage();
                }),
              ),
            ),
            Offstage(
              child: EmojiPickerWidget(
                onEmojiSelected: onEmojiSelected,
              ),
              offstage: !isEmojiVisible,
            ),
          ],
        ),
      ),
    );
  }

  void onEmojiSelected(String emoji) => setState(() {
        msgController.text = msgController.text + emoji;
      });

  Future toggleEmojiKeyboard() async {
    if (isKeyboardVisible) {
      FocusScope.of(context).unfocus();
    }

    setState(() {
      isEmojiVisible = !isEmojiVisible;
    });
  }

  Future<bool> onBackPress() {
    if (isEmojiVisible) {
      toggleEmojiKeyboard();
    } else {
      Navigator.pop(context);
    }

    return Future.value(false);
  }
}

class MessageTile extends StatelessWidget {
  final String msg;
  final bool sentByMe;
  final int timestamp;
  MessageTile(
    this.msg,
    this.sentByMe,
    this.timestamp,
  );

  String formatTimestamp(int timestamp) {
    var date = new DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat("kk:mm").format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          EdgeInsets.only(left: sentByMe ? 0 : 24, right: sentByMe ? 24 : 0),
      width: MediaQuery.of(context).size.width,
      alignment: sentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8),
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: sentByMe ? Colors.lightBlue : Colors.blueGrey,
          borderRadius: sentByMe
              ? BorderRadius.only(
                  topLeft: Radius.circular(23),
                  topRight: Radius.circular(23),
                  bottomLeft: Radius.circular(23),
                )
              : BorderRadius.only(
                  topLeft: Radius.circular(23),
                  topRight: Radius.circular(23),
                  bottomRight: Radius.circular(23),
                ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(msg),
            Text(
              formatTimestamp(timestamp),
              style: TextStyle(fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}
