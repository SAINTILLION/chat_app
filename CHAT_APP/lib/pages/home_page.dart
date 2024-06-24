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
// instance of autb
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Sign user out
  void signOut() {
    // get auth service
    final authService = Provider.of<AuthService>(context, listen: false);
    authService.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home Page"),
        elevation: 0.0,
        actions: [
          // Sign Out Button
          IconButton(
            onPressed: signOut,
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: _buildUserList(),
    );
  }

  // build a list of users except for the current logged in user
  Widget _buildUserList() {
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection("users").snapshots(),
        builder: ((context, snapshot) {
          if (snapshot.hasError) {
            return const Text("error");
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
              mainAxisAlignment: MainAxisAlignment.center,  
              children: [
                CircularProgressIndicator(color: Colors.blue,),
                Text(
                  "loading..."
                  ),
              ],
              ),
            );
          }

          return ListView(
            children: snapshot.data!.docs
                .map<Widget>((doc) => _buildUserListItem(doc))
                .toList(),
          );
        }));
  }

  // build individual user list items
  Widget _buildUserListItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data()! as Map<String, dynamic>;

    //display all users excepT current user
    if (_auth.currentUser!.email != data["email"]) {
      return ListTile(
          title: Text(data["email"]),
          shape: const RoundedRectangleBorder(
          side: BorderSide(
            color: Colors.grey, // Customize border color
            width: 1.0,        // Adjust border thickness
          ),
        ),
          onTap: () {
            // pass the clicked user's UID to the chat page
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatPage(
                  receiverUserEmail: data["email"],
                  receiverUserID: data["uid"],
                ),
              ),
            );
          });
    } else {
      // retrun empty container
      return Container();
    }
  }
}
