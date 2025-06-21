import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:node_me/models/user_model.dart';

class FriendListScreen extends StatefulWidget {
  const FriendListScreen({super.key});

  @override
  State<FriendListScreen> createState() => _FriendListScreenState();
}

class _FriendListScreenState extends State<FriendListScreen> {
  List<UserModel> friends = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadFriends();
  }

  Future<void> loadFriends() async {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    if (currentUid == null) return;

    final db = FirebaseDatabase.instance.ref().child(
      'users/$currentUid/firstDegreeIds',
    );
    final snapshot = await db.get();

    final ids = (snapshot.value as Map?)?.keys.toList() ?? [];

    final usersRef = FirebaseFirestore.instance.collection('users');
    final List<UserModel> loaded = [];

    for (final uid in ids) {
      final userSnap = await usersRef.doc(uid).get();
      if (userSnap.exists) {
        loaded.add(UserModel.fromJson(userSnap.data()!));
      }
    }

    setState(() {
      friends = loaded;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Your Friends")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : friends.isEmpty
          ? const Center(child: Text("You have no friends yet"))
          : ListView.builder(
              itemCount: friends.length,
              itemBuilder: (context, index) {
                final friend = friends[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(friend.profilePicUrl),
                  ),
                  title: Text(friend.name),
                  subtitle: Text('@${friend.username}'),
                );
              },
            ),
    );
  }
}
