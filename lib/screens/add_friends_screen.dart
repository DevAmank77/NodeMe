import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:node_me/utils/app_color.dart';
import '../models/user_model.dart';
import '../resources/friend_service.dart';

class AddFriendsScreen extends StatefulWidget {
  const AddFriendsScreen({super.key});

  @override
  State<AddFriendsScreen> createState() => _AddFriendsScreenState();
}

class _AddFriendsScreenState extends State<AddFriendsScreen> {
  final currentUser = FirebaseAuth.instance.currentUser;

  List<UserModel> allUsers = [];
  Set<String> sentRequests = {};
  List<UserModel> filteredUsers = [];
  final searchController = TextEditingController();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUsersAndRequests();
    searchController.addListener(_filterUsers);
  }

  Future<void> loadUsersAndRequests() async {
    final users = await FriendService().getAllUsers();

    final sent = await FriendService().getSentFriendRequests();

    setState(() {
      allUsers = users;
      sentRequests = sent;
      filteredUsers = users.where((u) => u.uid != currentUser?.uid).toList();
      ;
      isLoading = false;
    });
  }

  void _filterUsers() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredUsers = allUsers.where((user) {
        return user.name.toLowerCase().contains(query) ||
            user.username.toLowerCase().contains(query);
      }).toList();
    });
  }

  Future<void> toggleRequest(UserModel user) async {
    final isSent = sentRequests.contains(user.uid);
    final service = FriendService();

    bool success = false;

    if (isSent) {
      success = await service.unsendFriendRequest(user.uid, context);
      if (success) {
        sentRequests.remove(user.uid);
      }
    } else {
      success = await service.sendFriendRequest(user.uid, context);
      if (success) {
        sentRequests.add(user.uid);
      }
    }

    if (success) setState(() {}); // rebuild button state
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Friends")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Search users...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: filteredUsers.isEmpty
                      ? const Center(child: Text('No users found.'))
                      : ListView.builder(
                          itemCount: filteredUsers.length,
                          itemBuilder: (context, index) {
                            final user = filteredUsers[index];
                            final isSent = sentRequests.contains(user.uid);
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundImage: NetworkImage(
                                  user.profilePicUrl,
                                ),
                              ),
                              title: Text(user.name),
                              subtitle: Text('@${user.username}'),
                              trailing: TextButton(
                                style: TextButton.styleFrom(
                                  backgroundColor: isSent
                                      ? AppColors.secondaryCard
                                      : AppColors.primary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                onPressed: () => toggleRequest(user),
                                child: Text(
                                  isSent ? 'Unsend' : 'Add',
                                  style: TextStyle(
                                    color: isSent
                                        ? AppColors.textPrimary
                                        : AppColors.background,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
