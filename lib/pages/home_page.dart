import 'package:chat_app/pages/chat_page.dart';
import 'package:chat_app/services/auth/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void signOut() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Log Out"),
      content: const Text("Do you want to log out?"),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(), // Close dialog
          child: const Text("No"),
        ),
        TextButton(
          onPressed: () {
            final authService = Provider.of<AuthService>(context, listen: false);
            authService.signOut();
            Navigator.of(context).pop(); // Close dialog
          },
          child: const Text("Yes"),
        ),
      ],
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          "Chats",
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: signOut,
            icon: const Icon(Icons.logout, color: Colors.black),
          ),
        ],
      ),
      body: _buildUserList(),
    );
  }

  Widget _buildUserList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection("users").snapshots(),
      builder: ((context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text("Something went wrong."));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Colors.blue),
                SizedBox(height: 16),
                Text("Loading users..."),
              ],
            ),
          );
        }

        final userDocs = snapshot.data!.docs;
        final users = userDocs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return _auth.currentUser!.email != data["email"];
        }).toList();

        if (users.isEmpty) {
          return const Center(child: Text("No users found."));
        }

        return ListView.builder(
          itemCount: users.length,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          itemBuilder: (context, index) =>
              _buildUserListItem(users[index]),
        );
      }),
    );
  }

  Widget _buildUserListItem(DocumentSnapshot document) {
    final data = document.data()! as Map<String, dynamic>;
    final userEmail = data["email"];
    final userId = data["uid"];

    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blueAccent,
          child: Text(
            userEmail[0].toUpperCase(),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(
          userEmail,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
        trailing: const Icon(Icons.chat_bubble_outline, color: Colors.grey),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatPage(
                receiverUserEmail: userEmail,
                receiverUserID: userId,
              ),
            ),
          );
        },
      ),
    );
  }
}
