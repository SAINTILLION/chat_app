import 'package:chat_app/model/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatService extends ChangeNotifier {
  // Firebase instances
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// SEND MESSAGE
  Future<void> sendMessage(String receiverId, String message) async {
    final currentUser = _firebaseAuth.currentUser;
    if (currentUser == null) return;

    final String currentUserId = currentUser.uid;
    final String currentUserEmail = currentUser.email ?? '';
    final Timestamp timestamp = Timestamp.now();

    // Create message model
    final newMessage = Message(
      senderId: currentUserId,
      senderEmail: currentUserEmail,
      receiverId: receiverId,
      timestamp: timestamp,
      message: message,
    );

    // Chat room ID: sorted for consistency
    final chatRoomId = _generateChatRoomId(currentUserId, receiverId);

    // Add message to Firestore
    await _firestore
        .collection("ext_chat_rooms")
        .doc(chatRoomId)
        .collection("messages")
        .add(newMessage.toMap());
  }

  /// GET MESSAGES STREAM
  Stream<QuerySnapshot> getMessages(String userId, String otherUserId) {
    final chatRoomId = _generateChatRoomId(userId, otherUserId);

    return _firestore
        .collection("ext_chat_rooms")
        .doc(chatRoomId)
        .collection("messages")
        .orderBy("timestamp", descending: false) // older messages first
        .snapshots();
  }

  /// PRIVATE: Generate consistent chat room ID
  String _generateChatRoomId(String id1, String id2) {
    final sortedIds = [id1, id2]..sort();
    return sortedIds.join("_");
  }
}
