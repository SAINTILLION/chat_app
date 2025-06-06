import 'package:chat_app/components/my_text_field.dart';
import 'package:chat_app/services/chat/chat_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  final String receiverUserEmail;
  final String receiverUserID;

  const ChatPage({
    super.key,
    required this.receiverUserEmail,
    required this.receiverUserID,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  final ScrollController _scrollController = ScrollController();

  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      await _chatService.sendMessage(
        widget.receiverUserID,
        _messageController.text,
      );
      _messageController.clear();
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
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
          Expanded(child: _buildMessageList()),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return StreamBuilder(
      stream: _chatService.getMessages(
        widget.receiverUserID,
        _firebaseAuth.currentUser!.uid,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        // No messages case
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              "No messages yet.\nSay hi 👋",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          );
        }

        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

        return ListView(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: snapshot.data!.docs
              .map((doc) => _buildMessageItem(doc))
              .toList(),
        );
      },
    );
  }

  Widget _buildMessageItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;

    bool isSender = data['senderId'] == _firebaseAuth.currentUser!.uid;
    Alignment alignment = isSender ? Alignment.centerLeft : Alignment.centerRight;
    Color bubbleColor = isSender ? Colors.blue.shade100 : Colors.grey.shade300;
    Color textColor = Colors.black;

    return Align(
      alignment: alignment,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          data['message'],
          style: TextStyle(color: textColor, fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: MyTextField(
              controller: _messageController,
              hintText: "Type a message...",
              obscureText: false,
            ),
          ),
          IconButton(
            onPressed: sendMessage,
            icon: const Icon(Icons.send, size: 28, color: Colors.blue),
          ),
        ],
      ),
    );
  }
}
