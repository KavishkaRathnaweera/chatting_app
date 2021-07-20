import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_chat/screens/login_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final fireStore = FirebaseFirestore.instance;
final FirebaseAuth _auth = FirebaseAuth.instance;
CollectionReference firebaseMessages =
    FirebaseFirestore.instance.collection('message');
User loggedInUser;

class ChatScreen extends StatefulWidget {
  static const String screenId = 'chat_screen';

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  QuerySnapshot querysnap;
  dynamic querydocsnap;
  String messages;

  final textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getUser();
  }

  void getUser() async {
    try {
      final user = await _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
        print(loggedInUser.email);
      }
    } catch (e) {
      print(e);
    }
  }

  getmessages() async {
    final msg = await firebaseMessages
        .get()
        .then((QuerySnapshot querySnapshot) => {querysnap = querySnapshot});
    //querysnap.docs.forEach((element) {
    //   print(element['text']);
    // });
    /* we can use FutureBuilder widget to show this data*/
  }

  void messageStream() async {
    await for (var snaps in firebaseMessages.snapshots()) {
      for (var msg in snaps.docs) {
        print(msg.data());
      }
    }
    /*we can use Streambuilder widget to show this data*/
  }

  //AuthResult => userCredential

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () async {
                messageStream();
                _auth.signOut();
                Navigator.pop(context);
                Navigator.pushNamed(context, LoginScreen.screenId);
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MessageStream(),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: textController,
                      onChanged: (value) {
                        messages = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      textController.clear();
                      fireStore.collection('message').add(
                        {
                          'text': messages,
                          'sender': loggedInUser.email,
                          'time': Timestamp.now(),
                        },
                      );
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageStream extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: firebaseMessages.orderBy('time').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }
        List<MessageBubble> messageWidget = [];
        if (snapshot.hasData) {
          final messages = snapshot.data.docs.reversed;
          for (var msg in messages) {
            Map<String, dynamic> msgText = msg.data() as Map<String, dynamic>;
            String senderEmail = msgText['sender'];
            String senderMessage = msgText['text'];

            final s = MessageBubble(
              sender: senderEmail,
              text: senderMessage,
              isme: loggedInUser.email == senderEmail,
            );
            messageWidget.add(s);
          }
        }
        return Expanded(
          child: ListView(
            reverse: true,
            padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            children: messageWidget,
          ),
        );
      },
    );
  }
}

class MessageBubble extends StatelessWidget {
  MessageBubble({this.sender, this.text, this.isme});
  final sender;
  final text;
  final bool isme;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment:
            isme ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            '$sender',
            style: TextStyle(fontSize: 10.0, color: Colors.black54),
          ),
          Material(
            elevation: 5.0,
            borderRadius: isme
                ? BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    bottomLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0))
                : BorderRadius.only(
                    topRight: Radius.circular(30.0),
                    bottomLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0)),
            color: isme ? Colors.lightBlue : Colors.blueGrey[50],
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
              child: Text(
                '$text',
                style: TextStyle(
                  color: isme ? Colors.white : Colors.black,
                  fontSize: 15.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
