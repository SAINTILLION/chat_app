import 'package:chat_app/components/my_text_field.dart';
import 'package:chat_app/services/chat/chat_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  final String receiverUserEmail;
  final String receiverUserID;
  const ChatPage(
      {super.key,
      required this.receiverUserEmail,
      required this.receiverUserID});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  void sendMessage() async {
    // only send message if there is something to send
    if (_messageController.text.isNotEmpty) {
      await _chatService.sendMessage(
          widget.receiverUserID, _messageController.text);
      // clear the text controller after sending the message
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.receiverUserEmail),
        elevation: 0.0,
        ),
      body: Column(
        children: [
          // messages
          Expanded(
            child: _buildMessageList(),
          ),

          // user input
          _buildMessageInput()
        ],
      ),
    );
  }

// build message list
  _buildMessageList() {
    return StreamBuilder(
      stream: _chatService.getMessages(widget.receiverUserID, _firebaseAuth.currentUser!.uid),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error' + snapshot.error.toString());
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center, 
              children: [
                CircularProgressIndicator(),
                Text("Loading...")
              ],
            );
        }
      
      return ListView(
        cacheExtent: 5,
        children: snapshot.data!.docs.map((document)=> _buildMessageItem(document)).toList(),
      );
      }
    );
  }

// build message item
  Widget _buildMessageItem(DocumentSnapshot document) {
     Map<String, dynamic> data = document.data() as Map<String, dynamic>;

    // align the mesages to the right if the sender is the current user, otherwise to the left
    var alignment = (data['senderId'] == _firebaseAuth.currentUser!.uid)
        ? Alignment.centerLeft
        : Alignment.centerRight;
    var color = (data['senderId'] == _firebaseAuth.currentUser!.uid)
     ? Colors.blue 
     : Colors.white; 
    return InkWell(
      child: Container(
        padding: const EdgeInsets.all(8.0),
        color: color,
        alignment: alignment,
        child:Column(
          mainAxisSize: MainAxisSize.min,
          children: [  
          Text(
            data['senderEmail'],
            style: Theme.of(context).textTheme.displayMedium,
          ), 
          Text(
            data['message'],
            style: Theme.of(context).textTheme.displayMedium,
          ),
          SizedBox(height: 12)
          ]
        ),
      ),
    );
  }

//build message input
  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(children: [
        // textfield
        Expanded(
          child: MyTextField(
          controller: _messageController,
          hintText: "Enter message",
          obscureText: false,
        )),
    
        // send button
        IconButton(
          onPressed: sendMessage,
          icon: const Icon(
            Icons.arrow_upward,
            size: 40,
          ),
        ),
      ]),
    );
  }
}
